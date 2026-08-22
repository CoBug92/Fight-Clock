import Foundation

final class UserDefaultsSetupPickerStateRepository: SetupPickerStateRepository, @unchecked Sendable {
    // MARK: - Properties

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Init

    init(defaults: UserDefaults = SharedDefaults.store) {
        self.defaults = defaults
    }

    // MARK: - Public methods

    func load() -> SetupPickerState {
        guard
            let data = defaults.data(forKey: SharedDefaults.setupPickerStateKey),
            let state = try? decoder.decode(SetupPickerState.self, from: data)
        else {
            return .defaultValue
        }
        return state
    }

    func save(_ state: SetupPickerState) {
        guard let data = try? encoder.encode(state) else { return }
        defaults.set(data, forKey: SharedDefaults.setupPickerStateKey)
    }
}
