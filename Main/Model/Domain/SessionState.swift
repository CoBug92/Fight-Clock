import Foundation

struct SessionState: Codable, Equatable, Sendable {
    // MARK: - Properties

    let id: UUID
    var notificationRevision: UUID
    let configuration: TimerConfiguration
    var phase: SessionPhase
    var currentRound: Int
    var phaseEndDate: Date?
    var isPaused: Bool
    var pausedRemaining: TimeInterval?
    var hasPlayedRoundWarning: Bool
    var updatedAt: Date

    // MARK: - Computed properties

    var remainingReference: TimeInterval? {
        isPaused ? pausedRemaining : nil
    }

    // MARK: - Init

    init(
        id: UUID,
        notificationRevision: UUID,
        configuration: TimerConfiguration,
        phase: SessionPhase,
        currentRound: Int,
        phaseEndDate: Date?,
        isPaused: Bool,
        pausedRemaining: TimeInterval?,
        hasPlayedRoundWarning: Bool,
        updatedAt: Date
    ) {
        self.id = id
        self.notificationRevision = notificationRevision
        self.configuration = configuration
        self.phase = phase
        self.currentRound = currentRound
        self.phaseEndDate = phaseEndDate
        self.isPaused = isPaused
        self.pausedRemaining = pausedRemaining
        self.hasPlayedRoundWarning = hasPlayedRoundWarning
        self.updatedAt = updatedAt
    }

    // MARK: - Decoding

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        notificationRevision = try container.decode(UUID.self, forKey: .notificationRevision)
        configuration = try container.decode(TimerConfiguration.self, forKey: .configuration)
        phase = try container.decode(SessionPhase.self, forKey: .phase)
        currentRound = try container.decode(Int.self, forKey: .currentRound)
        phaseEndDate = try container.decodeIfPresent(Date.self, forKey: .phaseEndDate)
        isPaused = try container.decode(Bool.self, forKey: .isPaused)
        pausedRemaining = try container.decodeIfPresent(TimeInterval.self, forKey: .pausedRemaining)
        hasPlayedRoundWarning = try container.decodeIfPresent(Bool.self, forKey: .hasPlayedRoundWarning) ?? false
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
