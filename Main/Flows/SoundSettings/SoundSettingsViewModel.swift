import Combine
import Foundation

@MainActor
final class SoundSettingsViewModel: ObservableObject {
    // MARK: - Properties

    private let configurationController: TimerConfigurationController
    private let signalPlayer: SignalPlaying
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(configurationController: TimerConfigurationController, signalPlayer: SignalPlaying) {
        self.configurationController = configurationController
        self.signalPlayer = signalPlayer
        configurationController.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Computed properties

    var soundConfiguration: TimerSoundConfiguration {
        configurationController.configuration.soundConfiguration
    }

    // MARK: - Public methods

    func update(
        roundStartSound: BundledTimerSound? = nil,
        roundTransitionSound: BundledTimerSound? = nil,
        warningSound: BundledTimerSound? = nil
    ) {
        let current = soundConfiguration
        configurationController.update(
            soundConfiguration: TimerSoundConfiguration(
                roundStartSound: roundStartSound ?? current.roundStartSound,
                roundTransitionSound: roundTransitionSound ?? current.roundTransitionSound,
                warningSound: warningSound ?? current.warningSound
            )
        )
    }
    func preview(_ sound: BundledTimerSound) { signalPlayer.preview(sound) }
}
