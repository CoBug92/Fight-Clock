import ActivityKit
import SwiftUI
import WidgetKit

struct LiveActivityDynamicIsland {
    // MARK: - Properties

    let state: BoxingTimerActivityAttributes.ContentState
    let isStale: Bool
    @ScaledMetric(relativeTo: .title) private var countdownFontSize = CGFloat.liveActivityDynamicIslandFontSize

    // MARK: - Layout

    var configuration: DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                LiveActivityPhaseBadgeView(
                    state: state,
                    isStale: isStale
                )
            }
            DynamicIslandExpandedRegion(.trailing) {
                LiveActivityRoundCounterView(state: state)
            }
            DynamicIslandExpandedRegion(.bottom) {
                LiveActivityCountdownView(
                    state: state,
                    isStale: isStale
                )
                .font(
                    .system(
                        size: min(countdownFontSize, .liveActivityDynamicIslandMaximumFontSize),
                        weight: .heavy,
                        design: .rounded
                    )
                    .monospacedDigit()
                )
                .lineLimit(1)
                .minimumScaleFactor(.liveActivityCountdownMinimumScale)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        } compactLeading: {
            phaseIcon
        } compactTrailing: {
            if isStale {
                Image(systemName: SFSymbol.compactTimerWarning)
                    .accessibilityHidden(true)
            } else {
                LiveActivityCountdownView(
                    state: state,
                    isStale: false
                )
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(.liveActivityCountdownMinimumScale)
            }
        } minimal: {
            phaseIcon
        }
        .keylineTint(
            LiveActivityPalette(
                state: state,
                isStale: isStale
            ).accent
        )
    }

    private var phaseIcon: some View {
        Image(
            systemName: LiveActivityIcon.systemName(
                for: state,
                isStale: isStale
            )
        )
        .accessibilityLabel(LiveActivityIcon.accessibilityLabel(for: state, isStale: isStale))
    }
}

// MARK: - Constants

private extension CGFloat {
    static let liveActivityDynamicIslandFontSize: CGFloat = 34
    static let liveActivityDynamicIslandMaximumFontSize: CGFloat = 44
    static let liveActivityCountdownMinimumScale: CGFloat = 0.5
}
