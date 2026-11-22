import SwiftUI

struct LiveActivityLockScreenView: View {
    // MARK: - Properties

    let state: BoxingTimerActivityAttributes.ContentState
    let isStale: Bool
    @ScaledMetric(relativeTo: .largeTitle) private var countdownFontSize = CGFloat.liveActivityExpandedFontSize

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
            .accessibilityHidden(true)

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
                        size: min(countdownFontSize, .liveActivityMaximumFontSize),
                        weight: .heavy,
                        design: .rounded
                    )
                    .monospacedDigit()
                )
                .lineLimit(1)
                .minimumScaleFactor(.liveActivityMaximumTextMinimumScale)
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
    static let liveActivityMaximumFontSize: CGFloat = 50
    static let liveActivityMaximumTextMinimumScale: CGFloat = 0.65
}
