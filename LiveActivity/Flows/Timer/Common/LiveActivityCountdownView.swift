import SwiftUI

struct LiveActivityCountdownView: View {
    // MARK: - Properties

    let state: BoxingTimerActivityAttributes.ContentState
    let isStale: Bool

    // MARK: - Layout

    @ViewBuilder
    var body: some View {
        if isStale {
            Text(Localizations.Activity.staleShort)
        } else if state.isPaused {
            Text(formattedTime(seconds: state.pausedRemaining ?? .zero))
        } else if let endDate = state.phaseEndDate {
            Text(
                timerInterval: Date()...endDate,
                countsDown: true
            )
        } else {
            Text(formattedTime(seconds: .zero))
        }
    }

    // MARK: - Private methods

    private func formattedTime(seconds: Int) -> String {
        String(
            format: TechnicalString.timerFormat,
            seconds / .liveActivitySecondsPerMinute,
            seconds % .liveActivitySecondsPerMinute
        )
    }
}

// MARK: - Constants

private extension Int {
    static let liveActivitySecondsPerMinute = 60
}
