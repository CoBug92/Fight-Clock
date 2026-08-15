import Foundation

struct TimerSoundConfiguration: Codable, Equatable, Sendable {
    static let defaultValue = TimerSoundConfiguration(
        roundStartSound: .singleGong,
        roundTransitionSound: .tripleGong,
        warningSound: .bongoDrumTrill
    )

    let roundStartSound: BundledTimerSound
    let roundTransitionSound: BundledTimerSound
    let warningSound: BundledTimerSound

    init(
        roundStartSound: BundledTimerSound,
        roundTransitionSound: BundledTimerSound,
        warningSound: BundledTimerSound
    ) {
        self.roundStartSound = roundStartSound
        self.roundTransitionSound = roundTransitionSound
        self.warningSound = warningSound
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            roundStartSound: try container.decodeIfPresent(
                BundledTimerSound.self,
                forKey: .roundStartSound
            ) ?? Self.defaultValue.roundStartSound,
            roundTransitionSound: try container.decodeIfPresent(
                BundledTimerSound.self,
                forKey: .roundTransitionSound
            ) ?? Self.defaultValue.roundTransitionSound,
            warningSound: try container.decodeIfPresent(
                BundledTimerSound.self,
                forKey: .warningSound
            ) ?? Self.defaultValue.warningSound
        )
    }
}
