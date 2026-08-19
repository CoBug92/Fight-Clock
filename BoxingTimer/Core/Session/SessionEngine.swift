import Foundation

struct SessionEngine: Sendable {
    func start(configuration: TimerConfiguration, at date: Date) -> SessionState? {
        guard configuration.isValid else { return nil }

        return SessionState(
            id: UUID(),
            notificationRevision: UUID(),
            configuration: configuration,
            phase: configuration.preparationDuration > 0 ? .preparation : .round,
            currentRound: 1,
            phaseEndDate: date.addingTimeInterval(
                TimeInterval(configuration.preparationDuration > 0
                    ? configuration.preparationDuration
                    : configuration.roundDuration)
            ),
            isPaused: false,
            pausedRemaining: nil,
            hasPlayedRoundWarning: false,
            updatedAt: date
        )
    }

    func resolve(_ state: SessionState, at date: Date) -> SessionResolution {
        guard !state.isPaused else {
            return SessionResolution(state: state, signals: [])
        }

        guard var boundary = state.phaseEndDate else {
            return SessionResolution(state: nil, signals: [])
        }

        var current = state
        var signals: [SessionSignal] = []

        while date >= boundary {
            appendRoundWarningIfNeeded(state: &current, boundary: boundary, signals: &signals)
            switch current.phase {
            case .preparation:
                current.phase = .round
                boundary = boundary.addingTimeInterval(TimeInterval(current.configuration.roundDuration))
                signals.append(.roundStarted)
            case .round where current.currentRound == current.configuration.roundCount:
                signals.append(.workoutCompleted)
                return SessionResolution(state: nil, signals: signals)
            case .round where current.configuration.restDuration > 0:
                current.phase = .rest
                current.hasPlayedRoundWarning = false
                boundary = boundary.addingTimeInterval(TimeInterval(current.configuration.restDuration))
                signals.append(.restStarted)
            case .round:
                current.currentRound += 1
                current.hasPlayedRoundWarning = false
                boundary = boundary.addingTimeInterval(TimeInterval(current.configuration.roundDuration))
                signals.append(.roundStarted)
            case .rest:
                current.phase = .round
                current.currentRound += 1
                current.hasPlayedRoundWarning = false
                boundary = boundary.addingTimeInterval(TimeInterval(current.configuration.roundDuration))
                signals.append(.roundStarted)
            }
        }

        if current.phase == .round,
           date >= boundary.addingTimeInterval(-TimeInterval(current.configuration.roundWarning.rawValue)) {
            appendRoundWarningIfNeeded(state: &current, boundary: boundary, signals: &signals)
        }

        current.phaseEndDate = boundary
        if !signals.isEmpty { current.notificationRevision = UUID() }
        current.updatedAt = date
        return SessionResolution(state: current, signals: signals)
    }

    func pause(_ state: SessionState, at date: Date) -> SessionState {
        guard !state.isPaused, let phaseEndDate = state.phaseEndDate else { return state }

        var paused = state
        paused.isPaused = true
        paused.notificationRevision = UUID()
        paused.pausedRemaining = max(0, phaseEndDate.timeIntervalSince(date))
        paused.phaseEndDate = nil
        paused.updatedAt = date
        return paused
    }

    func resume(_ state: SessionState, at date: Date) -> SessionState {
        guard state.isPaused, let remaining = state.pausedRemaining else { return state }

        var resumed = state
        resumed.isPaused = false
        resumed.notificationRevision = UUID()
        resumed.phaseEndDate = date.addingTimeInterval(remaining)
        resumed.pausedRemaining = nil
        resumed.updatedAt = date
        return resumed
    }

    func remainingSeconds(for state: SessionState, at date: Date) -> Int {
        let remaining = state.isPaused
            ? state.pausedRemaining ?? 0
            : state.phaseEndDate?.timeIntervalSince(date) ?? 0
        return max(0, Int(ceil(remaining)))
    }

    private func appendRoundWarningIfNeeded(
        state: inout SessionState,
        boundary: Date,
        signals: inout [SessionSignal]
    ) {
        let seconds = state.configuration.roundWarning.rawValue
        guard state.phase == .round,
              seconds > 0,
              state.configuration.roundDuration > seconds,
              !state.hasPlayedRoundWarning else { return }
        state.hasPlayedRoundWarning = true
        signals.append(.roundEnding(seconds: seconds))
    }
}
