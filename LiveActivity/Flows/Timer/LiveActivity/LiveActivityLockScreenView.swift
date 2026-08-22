import SwiftUI

struct LiveActivityLockScreenView: View {
    // MARK: - Properties

    let state: BoxingTimerActivityAttributes.ContentState
    let isStale: Bool

    // MARK: - Layout

    var body: some View {
        ZStack {
            LinearGradient(
                colors: LiveActivityPalette(
                    state: state,
                    isStale: isStale
                ).background,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(
                alignment: .leading,
                spacing: Margin.x5
            ) {
                HStack(alignment: .top) {
                    LiveActivityPhaseBadgeView(
                        state: state,
                        isStale: isStale
                    )
                    Spacer()
                    LiveActivityRoundCounterView(state: state)
                }
                .frame(maxWidth: .infinity)

                LiveActivityCountdownView(
                    state: state,
                    isStale: isStale
                )
                .font(
                    .system(
                        size: .liveActivityExpandedFontSize,
                        weight: .heavy,
                        design: .rounded
                    )
                    .monospacedDigit()
                )
                .foregroundStyle(.white)
            }
            .padding(Margin.x9)
            .frame(
                maxWidth: .infinity,
                minHeight: .liveActivityContentHeight,
                alignment: .topLeading
            )
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let liveActivityContentHeight: CGFloat = 112
    static let liveActivityExpandedFontSize: CGFloat = 42
}
