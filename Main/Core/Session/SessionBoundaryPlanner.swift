import Foundation

struct SessionBoundaryPlanner: Sendable {
    // MARK: - Public methods

    func futureBoundaries(from state: SessionState, after date: Date) -> [SessionBoundary] {
        guard !state.isPaused, var boundary = state.phaseEndDate else { return [] }

        var phase = state.phase
        var round = state.currentRound
        var isCurrentPhase = true
        var result: [SessionBoundary] = []

        while true {
            if phase == .preparation {
                result.append(SessionBoundary(date: boundary, signal: .roundStarted, round: 1))
                phase = .round
                isCurrentPhase = false
                boundary = boundary.addingTimeInterval(TimeInterval(state.configuration.roundDuration))
                continue
            }

            if phase == .round {
                appendWarningIfNeeded(
                    to: &result,
                    boundary: boundary,
                    round: round,
                    configuration: state.configuration,
                    isAlreadyPlayed: isCurrentPhase && state.hasPlayedRoundWarning
                )
            }

            if phase == .round, round == state.configuration.roundCount {
                result.append(SessionBoundary(date: boundary, signal: .workoutCompleted, round: round))
                break
            }

            if phase == .round, state.configuration.restDuration > .zero {
                result.append(SessionBoundary(date: boundary, signal: .restStarted, round: round))
                phase = .rest
                isCurrentPhase = false
                boundary = boundary.addingTimeInterval(TimeInterval(state.configuration.restDuration))
            } else {
                round += 1
                result.append(SessionBoundary(date: boundary, signal: .roundStarted, round: round))
                phase = .round
                isCurrentPhase = false
                boundary = boundary.addingTimeInterval(TimeInterval(state.configuration.roundDuration))
            }
        }

        return result.filter { $0.date > date }
    }

    // MARK: - Private methods

    private func appendWarningIfNeeded(
        to result: inout [SessionBoundary],
        boundary: Date,
        round: Int,
        configuration: TimerConfiguration,
        isAlreadyPlayed: Bool
    ) {
        let seconds = configuration.roundWarning.rawValue
        guard seconds > .zero, configuration.roundDuration > seconds, !isAlreadyPlayed else { return }
        result.append(
            SessionBoundary(
                date: boundary.addingTimeInterval(-TimeInterval(seconds)),
                signal: .roundEnding(seconds: seconds),
                round: round
            )
        )
    }
}
