import Foundation

final class UserDefaultsConfigurationRepository: ConfigurationRepository, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = SharedDefaults.store) {
        self.defaults = defaults
    }

    func load() -> TimerConfiguration {
        guard
            let data = defaults.data(forKey: SharedDefaults.configurationKey),
            let configuration = try? decoder.decode(TimerConfiguration.self, from: data),
            configuration.isValid
        else {
            return .defaultValue
        }
        return configuration
    }

    func save(_ configuration: TimerConfiguration) {
        guard configuration.isValid, let data = try? encoder.encode(configuration) else { return }
        defaults.set(data, forKey: SharedDefaults.configurationKey)
    }
}
