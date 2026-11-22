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
                .accessibilityHidden(true)
        } else if !state.isPaused, let endDate = state.phaseEndDate {
            let now = Date()
            let interval = now...max(now, endDate)
            Text(
                timerInterval: interval,
                countsDown: true,
                showsHours: false
            )
            .accessibilityLabel(Localizations.Accessibility.remainingTime)
            .accessibilityValue(Text(
                timerInterval: interval,
                countsDown: true,
                showsHours: false
            ))
        } else {
            let seconds = state.pausedRemaining ?? .zero
            Text(formattedTime(seconds: seconds))
                .accessibilityLabel(Localizations.Accessibility.remainingTime)
                .accessibilityValue(SpokenDuration.format(seconds))
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
