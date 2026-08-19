import Foundation

final class UserDefaultsSessionRepository: SessionRepository, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = SharedDefaults.store) {
        self.defaults = defaults
    }

    func load() -> SessionState? {
        guard let data = defaults.data(forKey: SharedDefaults.sessionKey) else { return nil }
        return try? decoder.decode(SessionState.self, from: data)
    }

    func save(_ state: SessionState) {
        guard let data = try? encoder.encode(state) else { return }
        defaults.set(data, forKey: SharedDefaults.sessionKey)
    }

    func clear() {
        defaults.removeObject(forKey: SharedDefaults.sessionKey)
    }
}
