import Foundation
@testable import Main

@MainActor
final class Fixture {
    // MARK: - Properties

    let configurationRepository = ConfigurationRepositoryFake()
    let sessionRepository = SessionRepositoryFake()
    let notificationScheduler = NotificationSchedulerSpy()
    let signalPlayer = SignalPlayerSpy()
    let liveActivityController = LiveActivityControllerSpy()
    let idleTimerController = IdleTimerControllerSpy()
    let appSettingsOpener = AppSettingsOpenerSpy()
    let analyticsTracker = AnalyticsTrackerSpy()
    let dateProvider: DateProviderFake
    let viewModel: RootViewModel

    // MARK: - Init

    init(
        initialSession: SessionState? = nil,
        date: Date = Date(timeIntervalSince1970: 1_000)
    ) {
        dateProvider = DateProviderFake(value: date)
        sessionRepository.value = initialSession
        let configurationController = TimerConfigurationController(repository: configurationRepository)
        let sessionController = WorkoutSessionController(
            sessionRepository: sessionRepository,
            notificationScheduler: notificationScheduler,
            signalPlayer: signalPlayer,
            liveActivityController: liveActivityController,
            idleTimerController: idleTimerController,
            dateProvider: dateProvider,
            analyticsTracker: analyticsTracker
        )
        let setupViewModel = SetupViewModel(
            configurationController: configurationController,
            sessionController: sessionController,
            notificationScheduler: notificationScheduler,
            appSettingsOpener: appSettingsOpener,
            analyticsTracker: analyticsTracker
        )
        viewModel = RootViewModel(
            sessionController: sessionController,
            setupViewModel: setupViewModel,
            soundSettingsViewModel: SoundSettingsViewModel(configurationController: configurationController, signalPlayer: signalPlayer),
            activeTimerViewModel: ActiveTimerViewModel(sessionController: sessionController)
        )
    }
}

@MainActor
extension RootViewModel {
    func update(
        roundCount: Int? = nil,
        roundDuration: Int? = nil,
        restDuration: Int? = nil,
        preparationDuration: Int? = nil,
        roundWarning: RoundWarning? = nil,
        roundStartSound: BundledTimerSound? = nil,
        roundTransitionSound: BundledTimerSound? = nil,
        warningSound: BundledTimerSound? = nil
    ) {
        if roundCount != nil || roundDuration != nil || restDuration != nil || preparationDuration != nil || roundWarning != nil {
            setupViewModel.update(
                roundCount: roundCount,
                roundDuration: roundDuration,
                restDuration: restDuration,
                preparationDuration: preparationDuration,
                roundWarning: roundWarning
            )
        }
        if roundStartSound != nil || roundTransitionSound != nil || warningSound != nil {
            soundSettingsViewModel.update(
                roundStartSound: roundStartSound,
                roundTransitionSound: roundTransitionSound,
                warningSound: warningSound
            )
        }
    }

    func preview(_ sound: BundledTimerSound) { soundSettingsViewModel.preview(sound) }
    var notificationPermissionCard: NotificationPermissionCardViewData? { setupViewModel.notificationPermissionCard }
    func performNotificationPermissionCardAction() async { await setupViewModel.performNotificationPermissionCardAction() }
    func start() async { await setupViewModel.start() }
    func togglePause() async { await activeTimerViewModel.togglePause() }
    func stop() async { await activeTimerViewModel.stop() }
}

@MainActor
final class AppSettingsOpenerSpy: AppSettingsOpening {
    // MARK: - Properties

    private(set) var openCallCount: Int = .zero

    // MARK: - Public methods

    func openAppSettings() {
        openCallCount += 1
    }
}

final class ConfigurationRepositoryFake: ConfigurationRepository, @unchecked Sendable {
    // MARK: - Properties

    var value = TimerConfiguration.defaultValue

    // MARK: - Public methods

    func load() -> TimerConfiguration { value }
    func save(_ configuration: TimerConfiguration) { value = configuration }
}

final class SessionRepositoryFake: SessionRepository, @unchecked Sendable {
    // MARK: - Properties

    var value: SessionState?

    // MARK: - Public methods

    func load() -> SessionState? { value }
    func save(_ state: SessionState) { value = state }
    func clear() { value = nil }
}

@MainActor
final class NotificationSchedulerSpy: NotificationScheduling {
    // MARK: - Properties

    var shouldSuspendNextSchedule = false
    var currentPermission: NotificationPermission = .allowed
    private(set) var scheduledStates: [SessionState] = []
    private(set) var activeRevisions: Set<UUID> = []
    private var scheduleContinuation: CheckedContinuation<Void, Never>?

    // MARK: - Public methods

    func permission() async -> NotificationPermission { currentPermission }
    func requestPermission() async -> NotificationPermission { currentPermission }

    func schedule(for state: SessionState, now: Date) async {
        scheduledStates.append(state)
        if shouldSuspendNextSchedule {
            shouldSuspendNextSchedule = false
            await withCheckedContinuation { scheduleContinuation = $0 }
        }
        activeRevisions.insert(state.notificationRevision)
    }

    func cancelAll() {
        activeRevisions.removeAll()
    }

    func cancel(for state: SessionState) {
        activeRevisions.remove(state.notificationRevision)
    }

    func waitUntilSuspended() async {
        while scheduleContinuation == nil { await Task.yield() }
    }

    func resumeScheduling() {
        scheduleContinuation?.resume()
        scheduleContinuation = nil
    }
}

@MainActor
final class SignalPlayerSpy: SignalPlaying {
    // MARK: - Types

    struct PlayRequest: Equatable {
        let signal: SessionSignal
        let configuration: TimerConfiguration
    }

    // MARK: - Properties

    var playRequests: [PlayRequest] = []
    var previewedSounds: [BundledTimerSound] = []

    // MARK: - Public methods

    func play(_ signal: SessionSignal, configuration: TimerConfiguration) {
        playRequests.append(PlayRequest(signal: signal, configuration: configuration))
    }

    func preview(_ sound: BundledTimerSound) {
        previewedSounds.append(sound)
    }
}

actor LiveActivityControllerSpy: LiveActivityControlling {
    // MARK: - Properties

    private(set) var startedStates: [SessionState] = []
    private(set) var updatedStates: [SessionState] = []
    private(set) var endedSessionIDs: [UUID] = []

    // MARK: - Public methods

    func start(for state: SessionState) async { startedStates.append(state) }
    func update(for state: SessionState) async { updatedStates.append(state) }
    func end() async {}
    func end(sessionID: UUID) async { endedSessionIDs.append(sessionID) }
}

@MainActor
final class IdleTimerControllerSpy: IdleTimerControlling {
    // MARK: - Properties

    var isDisabled = false

    // MARK: - Public methods

    func setDisabled(_ isDisabled: Bool) { self.isDisabled = isDisabled }
}

final class DateProviderFake: DateProviding, @unchecked Sendable {
    // MARK: - Properties

    var value: Date

    // MARK: - Init

    init(value: Date) { self.value = value }

    // MARK: - Public methods

    func now() -> Date { value }
}

@MainActor
final class AnalyticsTrackerSpy: AnalyticsTracking {
    // MARK: - Properties

    private(set) var events: [AnalyticsEvent] = []

    // MARK: - Public methods

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}
