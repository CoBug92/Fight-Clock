import Foundation

struct TimerConfiguration: Codable, Equatable, Sendable {
    // MARK: - Properties

    static let defaultValue = TimerConfiguration(
        roundCount: .timerConfigurationDefaultRoundCount,
        roundDuration: .timerConfigurationDefaultRoundDuration,
        restDuration: .timerConfigurationDefaultRestDuration,
        preparationDuration: .timerConfigurationDefaultPreparationDuration,
        roundWarning: .tenSeconds,
        soundConfiguration: .defaultValue
    )

    let roundCount: Int
    let roundDuration: Int
    let restDuration: Int
    let preparationDuration: Int
    let roundWarning: RoundWarning
    let soundConfiguration: TimerSoundConfiguration

    // MARK: - Init

    init(
        roundCount: Int,
        roundDuration: Int,
        restDuration: Int,
        preparationDuration: Int = .zero,
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

    // MARK: - Computed properties

    var isValid: Bool {
        (Int.timerConfigurationMinimumRoundCount...Int.timerConfigurationMaximumRoundCount).contains(roundCount)
            && (Int.timerConfigurationMinimumRoundDuration...Int.timerConfigurationMaximumRoundDuration).contains(roundDuration)
            && (.zero...Int.timerConfigurationMaximumRestDuration).contains(restDuration)
            && (.zero...Int.timerConfigurationMaximumPreparationDuration).contains(preparationDuration)
            && roundDuration.isMultiple(of: .timerConfigurationDurationStep)
            && restDuration.isMultiple(of: .timerConfigurationDurationStep)
            && preparationDuration.isMultiple(of: .timerConfigurationDurationStep)
    }

    // MARK: - Decoding

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roundCount = try container.decode(Int.self, forKey: .roundCount)
        roundDuration = try container.decode(Int.self, forKey: .roundDuration)
        restDuration = try container.decode(Int.self, forKey: .restDuration)
        preparationDuration = try container.decodeIfPresent(Int.self, forKey: .preparationDuration) ?? .zero
        roundWarning = try container.decodeIfPresent(RoundWarning.self, forKey: .roundWarning) ?? .disabled
        soundConfiguration = try container.decodeIfPresent(
            TimerSoundConfiguration.self,
            forKey: .soundConfiguration
        ) ?? .defaultValue
    }
}

// MARK: - Constants

private extension Int {
    static let timerConfigurationDefaultRoundCount = 3
    static let timerConfigurationDefaultRoundDuration = 180
    static let timerConfigurationDefaultRestDuration = 60
    static let timerConfigurationDefaultPreparationDuration = 10
    static let timerConfigurationMinimumRoundCount = 1
    static let timerConfigurationMaximumRoundCount = 15
    static let timerConfigurationMinimumRoundDuration = 10
    static let timerConfigurationMaximumRoundDuration = 900
    static let timerConfigurationMaximumRestDuration = 300
    static let timerConfigurationMaximumPreparationDuration = 300
    static let timerConfigurationDurationStep = 5
}
