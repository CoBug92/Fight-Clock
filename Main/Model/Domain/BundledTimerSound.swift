import Foundation

enum BundledTimerSound: String, CaseIterable, Codable, Equatable, Sendable {
    // MARK: - Cases

    case singleGong
    case tripleGong
    case brightBell
    case bongoDrumTrill
    case clickQuartetRhythm
    case rhythmicPattern

    // MARK: - Computed properties

    var resourceName: String {
        switch self {
        case .singleGong:
            Self.placeholderRoundSound
        case .tripleGong:
            Self.placeholderCompleteSound
        case .brightBell:
            Self.placeholderBrightSound
        case .bongoDrumTrill:
            Self.bongoDrumTrillSound
        case .clickQuartetRhythm:
            Self.clickQuartetRhythmSound
        case .rhythmicPattern:
            Self.rhythmicPatternSound
        }
    }

    var fileExtension: String {
        TechnicalString.wav
    }

    var fileName: String {
        resourceName + TechnicalString.period + fileExtension
    }
}

// MARK: - Constants

private extension BundledTimerSound {
    static let placeholderRoundSound = "placeholder_round"
    static let placeholderCompleteSound = "placeholder_complete"
    static let placeholderBrightSound = "placeholder_bright"
    static let bongoDrumTrillSound = "bongo_drum_trill"
    static let clickQuartetRhythmSound = "click_quartet_rhythm"
    static let rhythmicPatternSound = "rhythmic_pattern"
}
