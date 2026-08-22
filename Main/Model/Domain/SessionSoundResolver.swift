import Foundation

struct SessionSoundResolver: Sendable {
    // MARK: - Public methods

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
        sound(for: signal, configuration: configuration).fileName
    }
}
