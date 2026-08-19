import Foundation

struct SessionSoundResolver: Sendable {
    func sound(for signal: SessionSignal, configuration: TimerConfiguration) -> BundledTimerSound {
        switch signal {
        case .roundStarted:
            configuration.soundConfiguration.roundStartSound
        case .roundEnding:
            configuration.soundConfiguration.warningSound
        case .restStarted, .workoutCompleted:
            configuration.soundConfiguration.roundTransitionSound
        }
    }

    func resourceName(for signal: SessionSignal, configuration: TimerConfiguration) -> String {
        sound(for: signal, configuration: configuration).resourceName
    }

    func notificationSoundName(for signal: SessionSignal, configuration: TimerConfiguration) -> String {
        let selectedSound = sound(for: signal, configuration: configuration)
        guard selectedSound.fileExtension == "mp3" else {
            return selectedSound.fileName
        }

        let fallbackSound: BundledTimerSound
        switch signal {
        case .roundStarted:
            fallbackSound = .singleGong
        case .roundEnding:
            fallbackSound = .brightBell
        case .restStarted, .workoutCompleted:
            fallbackSound = .tripleGong
        }
        return fallbackSound.fileName
    }
}
