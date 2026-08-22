import ActivityKit
import AppIntents
import Foundation

struct PauseSessionIntent: LiveActivityIntent {
    // MARK: - Properties

    static let title: LocalizedStringResource = "intent.pause"
    static let openAppWhenRun = false

    // MARK: - Public methods

    @MainActor
    func perform() async throws -> some IntentResult {
        await SessionIntentHandler().setPaused(true)
        return .result()
    }
}

struct ResumeSessionIntent: LiveActivityIntent {
    // MARK: - Properties

    static let title: LocalizedStringResource = "intent.resume"
    static let openAppWhenRun = false

    // MARK: - Public methods

    @MainActor
    func perform() async throws -> some IntentResult {
        await SessionIntentHandler().setPaused(false)
        return .result()
    }
}

struct OpenBoxingTimerIntent: LiveActivityIntent {
    // MARK: - Properties

    static let title: LocalizedStringResource = "intent.open_app"
    static let openAppWhenRun = true

    // MARK: - Public methods

    func perform() async throws -> some IntentResult {
        .result()
    }
}

@MainActor
private struct SessionIntentHandler {
    // MARK: - Properties

    private let repository = UserDefaultsSessionRepository()
    private let engine = SessionEngine()
    private let scheduler = NotificationScheduler()

    // MARK: - Public methods

    func setPaused(_ shouldPause: Bool) async {
        guard let state = repository.load(), state.isPaused != shouldPause else { return }
        let now = Date()
        scheduler.cancel(for: state)
        let resolution = engine.resolve(state, at: now)
        guard let resolved = resolution.state else {
            repository.clear()
            await endActivity(sessionID: state.id)
            return
        }
        guard resolved.isPaused != shouldPause else { return }
        let updated = shouldPause ? engine.pause(resolved, at: now) : engine.resume(resolved, at: now)
        repository.save(updated)

        if !shouldPause {
            await scheduler.schedule(for: updated, now: now)
            guard isCurrentNotificationSchedule(for: updated) else {
                scheduler.cancel(for: updated)
                return
            }
        }

        let contentState = BoxingTimerActivityAttributes.ContentState(
            phase: updated.phase,
            currentRound: updated.currentRound,
            totalRounds: updated.configuration.roundCount,
            phaseEndDate: updated.phaseEndDate,
            pausedRemaining: updated.pausedRemaining.map { Int(ceil($0)) },
            isPaused: updated.isPaused
        )
        let content = ActivityContent(state: contentState, staleDate: updated.phaseEndDate)
        for activity in Activity<BoxingTimerActivityAttributes>.activities {
            guard activity.attributes.sessionID == updated.id else { continue }
            await activity.update(content)
        }
    }

    // MARK: - Private methods

    private func isCurrentNotificationSchedule(for state: SessionState) -> Bool {
        guard let persisted = repository.load() else { return false }
        return persisted.id == state.id
            && persisted.notificationRevision == state.notificationRevision
            && persisted.isPaused == state.isPaused
    }

    private func endActivity(sessionID: UUID) async {
        for activity in Activity<BoxingTimerActivityAttributes>.activities {
            guard activity.attributes.sessionID == sessionID else { continue }
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
