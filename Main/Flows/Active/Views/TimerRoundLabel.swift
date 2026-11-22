import SwiftUI

struct TimerRoundLabel: View {
    // MARK: - Properties

    let currentRound: Int
    let roundCount: Int
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Layout

    var body: some View {
        Text(
            Localizations.Active.roundProgress(
                currentRound,
                roundCount
            )
        )
            .font(.title2.bold())
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 1 : nil)
            .minimumScaleFactor(.timerRoundLabelMinimumScale)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .accessibilityLabel(Localizations.Accessibility.spokenRoundProgress(currentRound, roundCount))
    }
}

// MARK: - Constants

private extension CGFloat {
    static let timerRoundLabelMinimumScale: CGFloat = 0.7
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    TimerRoundLabel(
        currentRound: 2,
        roundCount: 3
    )
    .padding()
}
#endif
