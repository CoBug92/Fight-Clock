import Foundation

enum BundledTimerSound: String, CaseIterable, Codable, Equatable, Sendable {
    case singleGong
    case tripleGong
    case brightBell
    case bongoDrumTrill
    case clickQuartetRhythm
    case rhythmicPattern

    var resourceName: String {
        switch self {
        case .singleGong:
            "placeholder_round"
        case .tripleGong:
            "placeholder_complete"
        case .brightBell:
            "placeholder_bright"
        case .bongoDrumTrill:
            "bongo_drum_trill"
        case .clickQuartetRhythm:
            "click_quartet_rhythm"
        case .rhythmicPattern:
            "rhythmic_pattern"
        }
    }

    var fileExtension: String {
        switch self {
        case .bongoDrumTrill, .clickQuartetRhythm, .rhythmicPattern:
            "mp3"
        default:
            "wav"
        }
    }

    var fileName: String {
        resourceName + "." + fileExtension
    }
}
