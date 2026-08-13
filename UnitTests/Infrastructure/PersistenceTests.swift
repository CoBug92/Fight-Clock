import XCTest
@testable import BoxingTimer

final class PersistenceTests: XCTestCase {
    private let suiteName = "PersistenceTests.\(UUID().uuidString)"
    private lazy var defaults = UserDefaults(suiteName: suiteName) ?? .standard

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testConfigurationDefaultsAndRoundTrip() {
        let repository = UserDefaultsConfigurationRepository(defaults: defaults)
        XCTAssertEqual(repository.load(), .defaultValue)

        let expected = TimerConfiguration(
            roundCount: 15,
            roundDuration: 150,
            restDuration: 75,
            roundWarning: .tenSeconds
        )
        repository.save(expected)

        XCTAssertEqual(repository.load(), expected)
    }

    func testInvalidConfigurationIsNotPersisted() {
        let repository = UserDefaultsConfigurationRepository(defaults: defaults)
        repository.save(TimerConfiguration(roundCount: 0, roundDuration: 5, restDuration: 1))

        XCTAssertEqual(repository.load(), .defaultValue)
    }

    func testLegacyConfigurationDefaultsWarningToDisabled() throws {
        let data = try XCTUnwrap(
            """
            {"roundCount":3,"roundDuration":180,"restDuration":60}
            """.data(using: .utf8)
        )

        let configuration = try JSONDecoder().decode(TimerConfiguration.self, from: data)

        XCTAssertEqual(configuration.roundWarning, .disabled)
        XCTAssertEqual(configuration.preparationDuration, 0)
    }

    func testSessionRoundTripAndClear() throws {
        let repository = UserDefaultsSessionRepository(defaults: defaults)
        let state = try XCTUnwrap(SessionEngine().start(configuration: .defaultValue, at: Date()))

        repository.save(state)
        XCTAssertEqual(repository.load(), state)
        repository.clear()
        XCTAssertNil(repository.load())
    }

    func testLegacySessionDefaultsWarningPlaybackFlagToFalse() throws {
        let state = try XCTUnwrap(SessionEngine().start(configuration: .defaultValue, at: Date()))
        let encoded = try JSONEncoder().encode(state)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "hasPlayedRoundWarning")
        let legacyData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(SessionState.self, from: legacyData)

        XCTAssertFalse(decoded.hasPlayedRoundWarning)
    }
}
