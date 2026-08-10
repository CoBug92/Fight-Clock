import Foundation

enum SharedDefaults {
    static let suiteName = "group.ru.kostyuchenko.fightclock"
    static let configurationKey = "timer.configuration"
    static let sessionKey = "timer.activeSession"

    static var store: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
}
