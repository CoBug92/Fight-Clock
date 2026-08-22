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
            Text(Localizations.Activity.round)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(.liveActivitySecondaryTextOpacity))
            Text("\(state.currentRound)\(TechnicalString.slash)\(state.totalRounds)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Constants

private extension Double {
    static let liveActivitySecondaryTextOpacity = 0.7
}
