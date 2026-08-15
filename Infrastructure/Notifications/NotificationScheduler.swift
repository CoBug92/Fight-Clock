import Foundation
import UserNotifications

@MainActor
final class NotificationScheduler: NotificationScheduling {
    private let center: UNUserNotificationCenter
    private let planner = SessionBoundaryPlanner()
    private let soundResolver: SessionSoundResolver

    init(
        center: UNUserNotificationCenter = .current(),
        soundResolver: SessionSoundResolver = SessionSoundResolver()
    ) {
        self.center = center
        self.soundResolver = soundResolver
    }

    func permission() async -> NotificationPermission {
        let settings = await center.notificationSettings()
        return permission(from: settings.authorizationStatus)
    }

    func requestPermission() async -> NotificationPermission {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return .denied
        }
        return await permission()
    }

    func schedule(for state: SessionState, now: Date) async {
        cancel(for: state)
        guard await permission() == .allowed else { return }

        for (index, boundary) in planner.futureBoundaries(from: state, after: now).enumerated() {
            let content = content(for: boundary, configuration: state.configuration)
            let interval = max(1, boundary.date.timeIntervalSince(now))
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifier(state: state, index: index),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    func cancel(for state: SessionState) {
        let identifiers = (0...Self.maximumBoundaryCount).map {
            identifier(state: state, index: $0)
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func content(
        for boundary: SessionBoundary,
        configuration: TimerConfiguration
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Localizations.Notification.title

        switch boundary.signal {
        case .roundStarted:
            content.body = Localizations.Notification.round
            content.sound = UNNotificationSound(
                named: .init(soundResolver.notificationSoundName(for: boundary.signal, configuration: configuration))
            )
        case let .roundEnding(seconds):
            content.body = Localizations.Notification.warning(seconds)
            content.sound = UNNotificationSound(
                named: .init(soundResolver.notificationSoundName(for: boundary.signal, configuration: configuration))
            )
        case .restStarted:
            content.body = Localizations.Notification.rest
            content.sound = UNNotificationSound(
                named: .init(soundResolver.notificationSoundName(for: boundary.signal, configuration: configuration))
            )
        case .workoutCompleted:
            content.body = Localizations.Notification.complete
            content.sound = UNNotificationSound(
                named: .init(soundResolver.notificationSoundName(for: boundary.signal, configuration: configuration))
            )
        }
        return content
    }

    private func permission(from status: UNAuthorizationStatus) -> NotificationPermission {
        switch status {
        case .authorized, .provisional, .ephemeral:
            .allowed
        case .denied:
            .denied
        case .notDetermined:
            .notDetermined
        @unknown default:
            .denied
        }
    }

    private func identifier(state: SessionState, index: Int) -> String {
        Self.identifierPrefix + state.id.uuidString + "." + state.notificationRevision.uuidString + "." + String(index)
    }
}

private extension NotificationScheduler {
    static let identifierPrefix = "boxing-timer.boundary."
    static let maximumBoundaryCount = 44
}
