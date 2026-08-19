import Foundation

struct TimerConfiguration: Codable, Equatable, Sendable {
    static let defaultValue = TimerConfiguration(
        roundCount: 3,
        roundDuration: 180,
        restDuration: 60,
        preparationDuration: 10,
        roundWarning: .tenSeconds,
        soundConfiguration: .defaultValue
    )

    let roundCount: Int
    let roundDuration: Int
    let restDuration: Int
    let preparationDuration: Int
    let roundWarning: RoundWarning
    let soundConfiguration: TimerSoundConfiguration

    init(
        roundCount: Int,
        roundDuration: Int,
        restDuration: Int,
        preparationDuration: Int = 0,
        roundWarning: RoundWarning = .disabled,
        soundConfiguration: TimerSoundConfiguration = .defaultValue
    ) {
        self.roundCount = roundCount
        self.roundDuration = roundDuration
        self.restDuration = restDuration
        self.preparationDuration = preparationDuration
        self.roundWarning = roundWarning
        self.soundConfiguration = soundConfiguration
    }

    var isValid: Bool {
        (1...15).contains(roundCount)
            && (10...900).contains(roundDuration)
            && (0...300).contains(restDuration)
            && (0...300).contains(preparationDuration)
            && roundDuration.isMultiple(of: 5)
            && restDuration.isMultiple(of: 5)
            && preparationDuration.isMultiple(of: 5)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roundCount = try container.decode(Int.self, forKey: .roundCount)
        roundDuration = try container.decode(Int.self, forKey: .roundDuration)
        restDuration = try container.decode(Int.self, forKey: .restDuration)
        preparationDuration = try container.decodeIfPresent(Int.self, forKey: .preparationDuration) ?? 0
        roundWarning = try container.decodeIfPresent(RoundWarning.self, forKey: .roundWarning) ?? .disabled
        soundConfiguration = try container.decodeIfPresent(
            TimerSoundConfiguration.self,
            forKey: .soundConfiguration
        ) ?? .defaultValue
    }
}
