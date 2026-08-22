import Foundation

@MainActor
extension RootViewModel {
    // MARK: - Preview

    static func preview(
        phase: SessionPhase,
        isPaused: Bool = false,
        remainingSeconds: Int
    ) -> RootViewModel {
        let configuration = TimerConfiguration(roundCount: 3, roundDuration: 180, restDuration: 60, preparationDuration: 30)
        let now = Date()
        let session = SessionState(
            id: UUID(), notificationRevision: UUID(), configuration: configuration, phase: phase, currentRound: 2,
            phaseEndDate: isPaused ? nil : now.addingTimeInterval(TimeInterval(remainingSeconds)), isPaused: isPaused,
            pausedRemaining: isPaused ? TimeInterval(remainingSeconds) : nil, hasPlayedRoundWarning: false, updatedAt: now
        )

        return RootViewModel(
            configurationRepository: PreviewConfigurationRepository(configuration: configuration),
            sessionRepository: PreviewSessionRepository(session: session), notificationScheduler: PreviewNotificationScheduler(),
            signalPlayer: PreviewSignalPlayer(), liveActivityController: PreviewLiveActivityController(),
            idleTimerController: PreviewIdleTimerController(), appSettingsOpener: PreviewAppSettingsOpener(),
            dateProvider: PreviewDateProvider(date: now)
        )
    }
}

private final class PreviewConfigurationRepository: ConfigurationRepository, @unchecked Sendable {
    // MARK: - Properties

    private let configuration: TimerConfiguration

    // MARK: - Init

    init(configuration: TimerConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Public methods

    func load() -> TimerConfiguration { configuration }
    func save(_ configuration: TimerConfiguration) {}
}

private final class PreviewSessionRepository: SessionRepository, @unchecked Sendable {
    // MARK: - Properties

    private var session: SessionState?

    // MARK: - Init

    init(session: SessionState) {
        self.session = session
    }

    // MARK: - Public methods

    func load() -> SessionState? { session }
    func save(_ state: SessionState) { session = state }
    func clear() { session = nil }
}

@MainActor
private final class PreviewNotificationScheduler: NotificationScheduling {
    // MARK: - Public methods

    func permission() async -> NotificationPermission { .allowed }
    func requestPermission() async -> NotificationPermission { .allowed }
    func schedule(for state: SessionState, now: Date) async {}
    func cancelAll() {}
    func cancel(for state: SessionState) {}
}

@MainActor
private final class PreviewSignalPlayer: SignalPlaying {
    // MARK: - Public methods

    func play(_ signal: SessionSignal, configuration: TimerConfiguration) {}
    func preview(_ sound: BundledTimerSound) {}
}

private final class PreviewLiveActivityController: LiveActivityControlling, Sendable {
    // MARK: - Public methods

    func start(for state: SessionState) async {}
    func update(for state: SessionState) async {}
    func end() async {}
    func end(sessionID: UUID) async {}
}

@MainActor
private final class PreviewIdleTimerController: IdleTimerControlling {
    // MARK: - Public methods

    func setDisabled(_ isDisabled: Bool) {}
}

@MainActor
private final class PreviewAppSettingsOpener: AppSettingsOpening {
    // MARK: - Public methods

    func openAppSettings() {}
}

private final class PreviewDateProvider: DateProviding, Sendable {
    // MARK: - Properties

    private let date: Date

    // MARK: - Init

    init(date: Date) {
        self.date = date
    }

    // MARK: - Public methods

    func now() -> Date { date }
}
