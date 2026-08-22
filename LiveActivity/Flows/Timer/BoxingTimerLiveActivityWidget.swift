import ActivityKit
import SwiftUI
import WidgetKit

struct BoxingTimerLiveActivityWidget: Widget {
    // MARK: - Layout

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BoxingTimerActivityAttributes.self) { context in
            LiveActivityLockScreenView(
                state: context.state,
                isStale: context.isStale
            )
            .activityBackgroundTint(.clear)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            LiveActivityDynamicIsland(
                state: context.state,
                isStale: context.isStale
            ).configuration
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Preparation", as: .content, using: BoxingTimerActivityAttributes(sessionID: UUID())) {
    BoxingTimerLiveActivityWidget()
} contentStates: {
    BoxingTimerActivityAttributes.ContentState(
        phase: .preparation,
        currentRound: 1,
        totalRounds: 3,
        phaseEndDate: .now.addingTimeInterval(5),
        pausedRemaining: nil,
        isPaused: false
    )
}

#Preview("Paused", as: .content, using: BoxingTimerActivityAttributes(sessionID: UUID())) {
    BoxingTimerLiveActivityWidget()
} contentStates: {
    BoxingTimerActivityAttributes.ContentState(
        phase: .round,
        currentRound: 1,
        totalRounds: 3,
        phaseEndDate: nil,
        pausedRemaining: 65,
        isPaused: true
    )
}
#endif
