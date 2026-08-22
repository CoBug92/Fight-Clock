import ActivityKit
import SwiftUI
import WidgetKit

struct LiveActivityDynamicIsland {
    // MARK: - Properties

    let state: BoxingTimerActivityAttributes.ContentState
    let isStale: Bool

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
                        size: .liveActivityDynamicIslandFontSize,
                        weight: .heavy,
                        design: .rounded
                    )
                    .monospacedDigit()
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        } compactLeading: {
            Image(
                systemName: LiveActivityIcon.systemName(
                    for: state,
                    isStale: isStale
                )
            )
        } compactTrailing: {
            if isStale {
                Image(systemName: SFSymbol.compactTimerWarning)
            } else {
                LiveActivityCountdownView(
                    state: state,
                    isStale: false
                )
                .monospacedDigit()
            }
        } minimal: {
            Image(
                systemName: LiveActivityIcon.systemName(
                    for: state,
                    isStale: isStale
                )
            )
        }
        .keylineTint(
            LiveActivityPalette(
                state: state,
                isStale: isStale
            ).accent
        )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let liveActivityDynamicIslandFontSize: CGFloat = 34
}
