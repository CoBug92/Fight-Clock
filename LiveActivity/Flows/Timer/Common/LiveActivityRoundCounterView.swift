import SwiftUI

struct LiveActivityRoundCounterView: View {
    // MARK: - Properties

    let state: BoxingTimerActivityAttributes.ContentState

    // MARK: - Layout

    var body: some View {
        VStack(
            alignment: .trailing,
            spacing: Margin.x1
        ) {
            Text(Localizations.Activity.interval)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(.liveActivitySecondaryTextOpacity))
            Text("\(state.currentRound)\(TechnicalString.slash)\(state.totalRounds)")
                .font(.headline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .lineLimit(1)
        .minimumScaleFactor(.liveActivityRoundMinimumScale)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Localizations.Accessibility.spokenRoundProgress(state.currentRound, state.totalRounds))
    }
}

// MARK: - Constants

private extension Double {
    static let liveActivitySecondaryTextOpacity = 0.7
}

private extension CGFloat {
    static let liveActivityRoundMinimumScale: CGFloat = 0.65
}
