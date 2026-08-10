import Foundation

struct TimerConfiguration: Codable, Equatable, Sendable {
    static let defaultValue = TimerConfiguration(
        roundCount: 3,
        roundDuration: 180,
        restDuration: 60,
        roundWarning: .disabled
    )

    let roundCount: Int
    let roundDuration: Int
    let restDuration: Int
    let roundWarning: RoundWarning

    init(roundCount: Int, roundDuration: Int, restDuration: Int, roundWarning: RoundWarning = .disabled) {
        self.roundCount = roundCount
        self.roundDuration = roundDuration
        self.restDuration = restDuration
        self.roundWarning = roundWarning
    }

    var isValid: Bool {
        (1...15).contains(roundCount)
            && (10...900).contains(roundDuration)
            && (0...300).contains(restDuration)
            && roundDuration.isMultiple(of: 5)
            && restDuration.isMultiple(of: 5)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roundCount = try container.decode(Int.self, forKey: .roundCount)
        roundDuration = try container.decode(Int.self, forKey: .roundDuration)
        restDuration = try container.decode(Int.self, forKey: .restDuration)
        roundWarning = try container.decodeIfPresent(RoundWarning.self, forKey: .roundWarning) ?? .disabled
    }
}
