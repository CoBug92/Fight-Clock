import ActivityKit
import Foundation

final class LiveActivityController: LiveActivityControlling {
    func start(for state: SessionState) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        if let activity = activity(for: state.id) {
            await activity.update(content(for: state))
            return
        }
        let attributes = BoxingTimerActivityAttributes(sessionID: state.id)
        let content = content(for: state)
        _ = try? Activity.request(attributes: attributes, content: content)
    }

    func update(for state: SessionState) async {
        guard let activity = activity(for: state.id) else {
            await start(for: state)
            return
        }
        await activity.update(content(for: state))
    }

    func end() async {
        for activity in Activity<BoxingTimerActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    func end(sessionID: UUID) async {
        guard let activity = activity(for: sessionID) else { return }
        await activity.end(nil, dismissalPolicy: .immediate)
    }

    private func activity(for sessionID: UUID) -> Activity<BoxingTimerActivityAttributes>? {
        Activity<BoxingTimerActivityAttributes>.activities.first {
            $0.attributes.sessionID == sessionID
        }
    }

    private func content(for state: SessionState) -> ActivityContent<BoxingTimerActivityAttributes.ContentState> {
        ActivityContent(state: contentState(for: state), staleDate: state.phaseEndDate)
    }

    private func contentState(for state: SessionState) -> BoxingTimerActivityAttributes.ContentState {
        BoxingTimerActivityAttributes.ContentState(
            phase: state.phase,
            currentRound: state.currentRound,
            totalRounds: state.configuration.roundCount,
            phaseEndDate: state.phaseEndDate,
            pausedRemaining: state.pausedRemaining.map { Int(ceil($0)) },
            isPaused: state.isPaused
        )
    }
}
