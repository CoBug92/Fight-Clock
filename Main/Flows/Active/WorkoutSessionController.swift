import Combine
import Foundation

@MainActor
final class WorkoutSessionController: ObservableObject {
    // MARK: - Observable properties

    @Published private(set) var session: SessionState?
    @Published private(set) var remainingSeconds: Int = .zero
    @Published private(set) var didCompleteWorkout = false

    // MARK: - Properties

    private let sessionRepository: SessionRepository
    private let notificationScheduler: NotificationScheduling
    private let signalPlayer: SignalPlaying
    private let liveActivityController: LiveActivityControlling
    private let idleTimerController: IdleTimerControlling
    private let dateProvider: DateProviding
    private let analyticsTracker: AnalyticsTracking
    private let engine = SessionEngine()
    private var timerTask: Task<Void, Never>?
    private var operationGeneration: Int = .zero
    private var isSceneActive = false

    // MARK: - Init / Deinit

    init(
        sessionRepository: SessionRepository,
        notificationScheduler: NotificationScheduling,
        signalPlayer: SignalPlaying,
        liveActivityController: LiveActivityControlling,
        idleTimerController: IdleTimerControlling,
        dateProvider: DateProviding,
        analyticsTracker: AnalyticsTracking
    ) {
        self.sessionRepository = sessionRepository
        self.notificationScheduler = notificationScheduler
        self.signalPlayer = signalPlayer
        self.liveActivityController = liveActivityController
        self.idleTimerController = idleTimerController
        self.dateProvider = dateProvider
        self.analyticsTracker = analyticsTracker
        let storedSession = sessionRepository.load()
        session = storedSession
        if let storedSession {
            remainingSeconds = engine.remainingSeconds(for: storedSession, at: dateProvider.now())
        }
    }

    deinit { timerTask?.cancel() }

    // MARK: - Public methods

    func launch(sceneIsActive: Bool) async {
        isSceneActive = sceneIsActive
        await synchronize(playSignal: false)
        startTickerIfNeeded()
    }

    // MARK: - Private methods

    func start(configuration: TimerConfiguration) async {
        let now = dateProvider.now()
        guard session == nil, let state = engine.start(configuration: configuration, at: now) else { return }
        let generation = beginOperation()
        didCompleteWorkout = false
        apply(state, at: now)
        analyticsTracker.track(.workoutStarted(state.configuration))
        if isSceneActive, state.phase == .round { signalPlayer.play(.roundStarted, configuration: state.configuration) }
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
            stopTicker()
        } else {
            startTickerIfNeeded()
        }
        analyticsTracker.track(updated.isPaused ? .workoutPaused(updated) : .workoutResumed(updated))
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

    #if DEBUG
    func advanceToNextPhase() async {
        guard let current = session else { return }
        let now = dateProvider.now()
        let resolution = engine.advanceToNextPhase(current, at: now)
        guard let next = resolution.state else {
            await complete(playSignal: !current.isPaused, state: current)
            return
        }
        apply(next, at: now)
        if isSceneActive, let signal = signalToPlay(from: resolution.signals, isRecentBoundary: true) {
            signalPlayer.play(signal, configuration: next.configuration)
        }
        await refreshPhaseEffects(from: current, to: next, at: now)
    }
    #endif

    func stop() async {
        let stoppedSession = session
        _ = beginOperation()
        stopTicker()
        session = nil
        remainingSeconds = .zero
        sessionRepository.clear()
        if let stoppedSession { analyticsTracker.track(.workoutStopped(stoppedSession)) }
        if let stoppedSession { notificationScheduler.cancel(for: stoppedSession) }
        idleTimerController.setDisabled(false)
        if let stoppedSession { await liveActivityController.end(sessionID: stoppedSession.id) }
    }

    func setSceneActive(_ isActive: Bool) async {
        isSceneActive = isActive
        guard isActive else {
            stopTicker()
            if session != nil { idleTimerController.setDisabled(false) }
            return
        }
        await synchronize(playSignal: false)
        startTickerIfNeeded()
    }

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
            let isRecent = previousBoundary.map { now.timeIntervalSince($0) < .workoutSessionRecentBoundaryThreshold } == true
            await complete(playSignal: playSignal && isRecent, state: current)
            return
        }
        apply(resolved, at: now)
        idleTimerController.setDisabled(isSceneActive)
        let isRecentBoundary = previousBoundary.map { now.timeIntervalSince($0) < .workoutSessionRecentBoundaryThreshold } == true
        if playSignal, isSceneActive,
           let signal = signalToPlay(from: resolution.signals, isRecentBoundary: isRecentBoundary) {
            signalPlayer.play(signal, configuration: resolved.configuration)
        }
        guard !resolution.signals.isEmpty else { return }
        await refreshPhaseEffects(from: current, to: resolved, at: now)
    }

    private func refreshPhaseEffects(from previous: SessionState, to next: SessionState, at date: Date) async {
        notificationScheduler.cancel(for: previous)
        let generation = beginOperation()
        if !next.isPaused {
            await notificationScheduler.schedule(for: next, now: date)
            guard isCurrent(generation, sessionID: next.id) else {
                notificationScheduler.cancel(for: next)
                return
            }
        }
        await liveActivityController.update(for: next)
        if !isCurrent(generation, sessionID: next.id) {
            await reconcileActivity(sessionID: next.id)
        }
    }

    private func apply(_ state: SessionState, at date: Date) {
        session = state
        remainingSeconds = engine.remainingSeconds(for: state, at: date)
        sessionRepository.save(state)
    }

    private func complete(playSignal: Bool, state: SessionState) async {
        _ = beginOperation()
        if playSignal, isSceneActive { signalPlayer.play(.workoutCompleted, configuration: state.configuration) }
        stopTicker()
        didCompleteWorkout = true
        session = nil
        remainingSeconds = .zero
        sessionRepository.clear()
        analyticsTracker.track(.workoutCompleted(state))
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

    private func beginOperation() -> Int { operationGeneration += 1; return operationGeneration }
    private func isCurrent(_ generation: Int, sessionID: UUID) -> Bool { operationGeneration == generation && session?.id == sessionID }

    private func startTickerIfNeeded() {
        guard isSceneActive, session?.isPaused == false, timerTask == nil else { return }
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(.workoutSessionTickIntervalMilliseconds))
                guard let self, !Task.isCancelled else { return }
                await self.synchronize(playSignal: true)
                if self.session == nil { return }
            }
        }
    }

    private func stopTicker() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func signalToPlay(from signals: [SessionSignal], isRecentBoundary: Bool) -> SessionSignal? {
        guard !signals.isEmpty else { return nil }
        if signals.count == 1, let signal = signals.first {
            if case .roundEnding = signal { return signal }
            return isRecentBoundary ? signal : nil
        }
        guard isRecentBoundary else { return nil }
        return signals.last { if case .roundEnding = $0 { return false }; return true }
    }
}

// MARK: - Constants

private extension Double {
    static let workoutSessionRecentBoundaryThreshold = 1.5
    static let workoutSessionTickIntervalMilliseconds = 200.0
}
