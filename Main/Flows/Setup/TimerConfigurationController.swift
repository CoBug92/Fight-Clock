import Combine
import Foundation

@MainActor
final class TimerConfigurationController: ObservableObject {
    // MARK: - Observable properties

    @Published private(set) var configuration: TimerConfiguration

    // MARK: - Properties

    private let repository: ConfigurationRepository

    // MARK: - Init

    init(repository: ConfigurationRepository) {
        self.repository = repository
        configuration = repository.load()
    }

    // MARK: - Public methods

    func update(
        roundCount: Int? = nil,
        roundDuration: Int? = nil,
        restDuration: Int? = nil,
        preparationDuration: Int? = nil,
        roundWarning: RoundWarning? = nil,
        soundConfiguration: TimerSoundConfiguration? = nil
    ) {
        let candidate = TimerConfiguration(
            roundCount: roundCount ?? configuration.roundCount,
            roundDuration: roundDuration ?? configuration.roundDuration,
            restDuration: restDuration ?? configuration.restDuration,
            preparationDuration: preparationDuration ?? configuration.preparationDuration,
            roundWarning: roundWarning ?? configuration.roundWarning,
            soundConfiguration: soundConfiguration ?? configuration.soundConfiguration
        )
        guard candidate.isValid else { return }
        configuration = candidate
        repository.save(candidate)
    }
}
