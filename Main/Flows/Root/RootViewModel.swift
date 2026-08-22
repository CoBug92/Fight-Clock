import Combine
import Foundation

@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Observable properties

    @Published private(set) var configuration: TimerConfiguration
    @Published private(set) var session: SessionState?
    @Published private(set) var remainingSeconds: Int = .zero
    @Published private(set) var notificationPermission: NotificationPermission = .notDetermined

    // MARK: - Properties

    private let configurationRepository: ConfigurationRepository
    private let sessionRepository: SessionRepository
    private let notificationScheduler: NotificationScheduling
    private let signalPlayer: SignalPlaying
    private let liveActivityController: LiveActivityControlling
    private let idleTimerController: IdleTimerControlling
    private let appSettingsOpener: AppSettingsOpening
    private let dateProvider: DateProviding
    private let engine = SessionEngine()
    private var timerTask: Task<Void, Never>?
    private var operationGeneration: Int = .zero
    private var isSceneActive = false

    // MARK: - Init / Deinit

    init(
        configurationRepository: ConfigurationRepository,
        sessionRepository: SessionRepository,
        notificationScheduler: NotificationScheduling,
        signalPlayer: SignalPlaying,
        liveActivityController: LiveActivityControlling,
        idleTimerController: IdleTimerControlling,
        appSettingsOpener: AppSettingsOpening,
        dateProvider: DateProviding
    ) {
        self.configurationRepository = configurationRepository
        self.sessionRepository = sessionRepository
        self.notificationScheduler = notificationScheduler
        self.signalPlayer = signalPlayer
        self.liveActivityController = liveActivityController
        self.idleTimerController = idleTimerController
        self.appSettingsOpener = appSettingsOpener
        self.dateProvider = dateProvider
        configuration = configurationRepository.load()
        session = sessionRepository.load()
    }

    deinit {
        timerTask?.cancel()
    }

    // MARK: - Computed properties

    var roundCount: Int { configuration.roundCount }
    var roundDuration: Int { configuration.roundDuration }
    var restDuration: Int { configuration.restDuration }
    var preparationDuration: Int { configuration.preparationDuration }
    var roundWarning: RoundWarning { configuration.roundWarning }
    var soundConfiguration: TimerSoundConfiguration { configuration.soundConfiguration }
    var roundStartSound: BundledTimerSound { configuration.soundConfiguration.roundStartSound }
    var roundTransitionSound: BundledTimerSound { configuration.soundConfiguration.roundTransitionSound }
    var warningSound: BundledTimerSound { configuration.soundConfiguration.warningSound }
    var notificationPermissionCard: NotificationPermissionCardViewData? {
        switch notificationPermission {
        case .notDetermined:
            NotificationPermissionCardViewData(
                explanation: Localizations.Permission.explanation,
                action: .button(title: Localizations.Permission.allow)
            )
        case .allowed:
            nil
        case .denied:
            NotificationPermissionCardViewData(
                explanation: Localizations.Permission.deniedExplanation,
                action: .cardTap
            )
        }
    }

    // MARK: - Public methods

    func launch(sceneIsActive: Bool) async {
        isSceneActive = sceneIsActive
        notificationPermission = await notificationScheduler.permission()
        await synchronize(playSignal: false)
        startTickerIfNeeded()
    }

    func update(
        roundCount: Int? = nil,
        roundDuration: Int? = nil,
        restDuration: Int? = nil,
        preparationDuration: Int? = nil,
        roundWarning: RoundWarning? = nil,
        roundStartSound: BundledTimerSound? = nil,
        roundTransitionSound: BundledTimerSound? = nil,
        warningSound: BundledTimerSound? = nil,
        soundConfiguration: TimerSoundConfiguration? = nil
    ) {
        guard session == nil else { return }
        let candidateSoundConfiguration = soundConfiguration ?? TimerSoundConfiguration(
            roundStartSound: roundStartSound ?? configuration.soundConfiguration.roundStartSound,
            roundTransitionSound: roundTransitionSound ?? configuration.soundConfiguration.roundTransitionSound,
            warningSound: warningSound ?? configuration.soundConfiguration.warningSound
        )
        let candidate = TimerConfiguration(
            roundCount: roundCount ?? configuration.roundCount,
            roundDuration: roundDuration ?? configuration.roundDuration,
            restDuration: restDuration ?? configuration.restDuration,
            preparationDuration: preparationDuration ?? configuration.preparationDuration,
            roundWarning: roundWarning ?? configuration.roundWarning,
            soundConfiguration: candidateSoundConfiguration
        )
        guard candidate.isValid else { return }
        configuration = candidate
        configurationRepository.save(candidate)
    }

    func preview(_ sound: BundledTimerSound) {
        signalPlayer.preview(sound)
    }

    func performNotificationPermissionCardAction() async {
        switch notificationPermission {
        case .notDetermined:
            notificationPermission = await notificationScheduler.requestPermission()
        case .allowed:
            break
        case .denied:
            appSettingsOpener.openAppSettings()
        }
    }

    func start() async {
        let now = dateProvider.now()
        guard session == nil, let state = engine.start(configuration: configuration, at: now) else { return }
        let generation = beginOperation()
        apply(state, at: now)
        if isSceneActive, state.phase == .round {
            signalPlayer.play(.roundStarted, configuration: state.configuration)
        }
        idleTimerController.setDisabled(true)

        await notificationScheduler.schedule(for: state, now: now)
        guard isCurrent(generation, sessionID: state.id) else {
            notificationScheduler.cancel(for: state)
            return
        }

        await liveActivityController.start(for: state)
        guard isCurrent(generation, sessionID: state.id) else {
            await liveActivityController.end(sessionID: state.id)
            return
        }
        startTickerIfNeeded()
    }

    func togglePause() async {
        guard let initial = session else { return }
        let now = dateProvider.now()
        notificationScheduler.cancel(for: initial)
        let resolution = engine.resolve(initial, at: now)
        guard let resolved = resolution.state else {
            await complete(playSignal: true, state: initial)
            return
        }

        let updated = resolved.isPaused ? engine.resume(resolved, at: now) : engine.pause(resolved, at: now)
        let generation = beginOperation()
        apply(updated, at: now)

        if updated.isPaused {
            notificationScheduler.cancel(for: resolved)
        } else {
            await notificationScheduler.schedule(for: updated, now: now)
            guard isCurrent(generation, sessionID: updated.id) else {
                notificationScheduler.cancel(for: updated)
                return
            }
        }

        await liveActivityController.update(for: updated)
        guard isCurrent(generation, sessionID: updated.id) else {
            await reconcileActivity(sessionID: updated.id)
            return
        }
    }

    func stop() async {
        let stoppedSession = session
        _ = beginOperation()
        timerTask?.cancel()
        timerTask = nil
        session = nil
        remainingSeconds = .zero
        sessionRepository.clear()
        if let stoppedSession { notificationScheduler.cancel(for: stoppedSession) }
        idleTimerController.setDisabled(false)
        if let stoppedSession {
            await liveActivityController.end(sessionID: stoppedSession.id)
        }
    }

    func setSceneActive(_ isActive: Bool) async {
        isSceneActive = isActive
        guard isActive else {
            if session != nil {
                idleTimerController.setDisabled(false)
            }
            return
        }

        await synchronize(playSignal: false)
        startTickerIfNeeded()
    }

    // MARK: - Private methods

    private func synchronize(playSignal: Bool) async {
        let now = dateProvider.now()

        if let external = sessionRepository.load(), external.updatedAt > (session?.updatedAt ?? .distantPast) {
            session = external
            _ = beginOperation()
        }

        guard let current = session else {
            idleTimerController.setDisabled(false)
            return
        }

        let previousBoundary = current.phaseEndDate
        let resolution = engine.resolve(current, at: now)
        guard let resolved = resolution.state else {
            let isRecent = previousBoundary.map { now.timeIntervalSince($0) < .rootViewModelRecentBoundaryThreshold } == true
            await complete(playSignal: playSignal && isRecent, state: current)
            return
        }

        apply(resolved, at: now)
        idleTimerController.setDisabled(isSceneActive)
        let isRecentBoundary = previousBoundary.map { now.timeIntervalSince($0) < .rootViewModelRecentBoundaryThreshold } == true
        if playSignal,
           isSceneActive,
           let signal = signalToPlay(from: resolution.signals, isRecentBoundary: isRecentBoundary) {
            signalPlayer.play(signal, configuration: resolved.configuration)
        }

        guard !resolution.signals.isEmpty else { return }
        notificationScheduler.cancel(for: current)
        let generation = beginOperation()
        await notificationScheduler.schedule(for: resolved, now: now)
        guard isCurrent(generation, sessionID: resolved.id) else {
            notificationScheduler.cancel(for: resolved)
            return
        }
        await liveActivityController.update(for: resolved)
        guard isCurrent(generation, sessionID: resolved.id) else {
            await reconcileActivity(sessionID: resolved.id)
            return
        }
    }

    private func apply(_ state: SessionState, at date: Date) {
        session = state
        remainingSeconds = engine.remainingSeconds(for: state, at: date)
        sessionRepository.save(state)
    }

    private func complete(playSignal: Bool, state: SessionState) async {
        _ = beginOperation()
        if playSignal, isSceneActive {
            signalPlayer.play(.workoutCompleted, configuration: state.configuration)
        }
        timerTask?.cancel()
        timerTask = nil
        session = nil
        remainingSeconds = .zero
        sessionRepository.clear()
        notificationScheduler.cancel(for: state)
        idleTimerController.setDisabled(false)
        await liveActivityController.end(sessionID: state.id)
    }

    private func reconcileActivity(sessionID: UUID) async {
        guard let current = session, current.id == sessionID else {
            await liveActivityController.end(sessionID: sessionID)
            return
        }
        await liveActivityController.update(for: current)
    }

    private func beginOperation() -> Int {
        operationGeneration += 1
        return operationGeneration
    }

    private func isCurrent(_ generation: Int, sessionID: UUID) -> Bool {
        operationGeneration == generation && session?.id == sessionID
    }

    private func startTickerIfNeeded() {
        guard session != nil, timerTask == nil else { return }
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(.rootViewModelTickIntervalMilliseconds))
                guard let self, !Task.isCancelled else { return }
                await self.synchronize(playSignal: true)
                if self.session == nil { return }
            }
        }
    }

    private func signalToPlay(from signals: [SessionSignal], isRecentBoundary: Bool) -> SessionSignal? {
        guard !signals.isEmpty else { return nil }

        if signals.count == 1, let signal = signals.first {
            if case .roundEnding = signal {
                return signal
            }
            return isRecentBoundary ? signal : nil
        }

        guard isRecentBoundary else { return nil }
        return signals.last {
            if case .roundEnding = $0 {
                return false
            }
            return true
        }
    }
}

// MARK: - Constants

private extension Double {
    static let rootViewModelRecentBoundaryThreshold = 1.5
    static let rootViewModelTickIntervalMilliseconds = 200.0
}
