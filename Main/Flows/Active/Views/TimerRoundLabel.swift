import SwiftUI

struct TimerRoundLabel: View {
    // MARK: - Properties

    let currentRound: Int
    let roundCount: Int

    // MARK: - Layout

    var body: some View {
        Text(
            Localizations.Active.roundProgress(
                currentRound,
                roundCount
            )
        )
            .font(.title2.bold())
    }
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
