#if canImport(ActivityKit)
import ActivityKit
import Foundation

struct BoxingTimerActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let phase: SessionPhase
        let currentRound: Int
        let totalRounds: Int
        let phaseEndDate: Date?
        let pausedRemaining: Int?
        let isPaused: Bool
    }

    let sessionID: UUID
}
#endif
