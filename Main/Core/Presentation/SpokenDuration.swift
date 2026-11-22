import Foundation

// MARK: - SpokenDuration

enum SpokenDuration {
    static func format(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.autoupdatingCurrent
        let locale = Bundle.main.accessibilityLocale
        calendar.locale = locale
        formatter.calendar = calendar
        formatter.allowedUnits = [.minute, .second]
        // Spelled-out English keeps the device voice from reading bare digits in another language.
        formatter.unitsStyle = locale.language.languageCode?.identifier == "en" ? .spellOut : .full
        formatter.zeroFormattingBehavior = seconds == .zero ? .dropLeading : .dropAll
        return formatter.string(from: TimeInterval(seconds)) ?? seconds.formatted()
    }
}

// MARK: - Spoken numbers

extension Int {
    var spelledOutForAccessibility: String {
        let formatter = NumberFormatter()
        formatter.locale = Bundle.main.accessibilityLocale
        formatter.numberStyle = .spellOut
        return formatter.string(for: self) ?? formatted()
    }
}

// MARK: - Spoken round progress

extension Localizations.Accessibility {
    static func spokenRoundProgress(_ currentRound: Int, _ totalRounds: Int) -> String {
        roundProgress(currentRound.spelledOutForAccessibility, totalRounds.spelledOutForAccessibility)
    }
}

private extension Bundle {
    var accessibilityLocale: Locale {
        preferredLocalizations.first.map(Locale.init(identifier:)) ?? .autoupdatingCurrent
    }
}
