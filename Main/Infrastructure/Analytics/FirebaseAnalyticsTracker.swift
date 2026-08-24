import FirebaseAnalytics
import FirebaseCore

@MainActor
final class FirebaseAnalyticsTracker: AnalyticsTracking {
    func track(_ event: AnalyticsEvent) {
        guard FirebaseApp.app() != nil else { return }
        Analytics.logEvent(event.firebaseName, parameters: event.firebaseParameters)
    }
}

extension AnalyticsEvent {
    var firebaseName: String {
        switch self {
        case .workoutStarted: "workout_started"
        case .workoutPaused: "workout_paused"
        case .workoutResumed: "workout_resumed"
        case .workoutStopped: "workout_stopped"
        case .workoutCompleted: "workout_completed"
        case .notificationPermissionUpdated: "notification_permission_updated"
        }
    }

    var firebaseParameters: [String: Any] {
        switch self {
        case let .workoutStarted(configuration):
            configuration.analyticsParameters
        case let .workoutPaused(session), let .workoutResumed(session), let .workoutStopped(session), let .workoutCompleted(session):
            ["round_number": session.currentRound, "round_count": session.configuration.roundCount]
        case let .notificationPermissionUpdated(permission):
            ["status": permission.analyticsValue]
        }
    }
}

private extension TimerConfiguration {
    var analyticsParameters: [String: Any] {
        [
            "round_count": roundCount,
            "round_duration_seconds": roundDuration,
            "rest_duration_seconds": restDuration,
            "preparation_duration_seconds": preparationDuration,
            "round_warning_seconds": roundWarning.analyticsValue
        ]
    }
}

private extension RoundWarning {
    var analyticsValue: Int {
        switch self {
        case .disabled: .zero
        case .tenSeconds: 10
        case .thirtySeconds: 30
        }
    }
}

private extension NotificationPermission {
    var analyticsValue: String {
        switch self {
        case .notDetermined: "not_determined"
        case .allowed: "allowed"
        case .denied: "denied"
        }
    }
}
