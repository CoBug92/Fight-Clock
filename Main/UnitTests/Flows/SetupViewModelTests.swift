import XCTest
@testable import Main

@MainActor
final class SetupViewModelTests: XCTestCase {
    // MARK: - Configuration

    func testUpdatePersistsConfigurationThroughDedicatedViewModel() {
        let fixture = Fixture()

        fixture.setupViewModel.update(
            roundCount: 4,
            roundDuration: 150,
            restDuration: 75,
            preparationDuration: 25,
            roundWarning: .thirtySeconds
        )

        XCTAssertEqual(
            fixture.configurationRepository.value,
            TimerConfiguration(
                roundCount: 4,
                roundDuration: 150,
                restDuration: 75,
                preparationDuration: 25,
                roundWarning: .thirtySeconds
            )
        )
    }

    func testInvalidUpdateKeepsLastValidConfiguration() {
        let fixture = Fixture()
        let initial = fixture.setupViewModel.configuration

        fixture.setupViewModel.update(roundDuration: 11)

        XCTAssertEqual(fixture.setupViewModel.configuration, initial)
        XCTAssertEqual(fixture.configurationRepository.value, initial)
    }

    func testUpdateIsIgnoredWhileSessionIsActive() throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let session = try XCTUnwrap(SessionEngine().start(configuration: .defaultValue, at: start))
        let fixture = Fixture(initialSession: session, date: start)

        fixture.setupViewModel.update(roundCount: 4)

        XCTAssertEqual(fixture.setupViewModel.configuration, .defaultValue)
        XCTAssertEqual(fixture.configurationRepository.value, .defaultValue)
    }

    // MARK: - Permission

    func testRefreshPermissionBuildsDeniedCardAndActionOpensSettings() async {
        let fixture = Fixture()
        fixture.notificationScheduler.currentPermission = .denied

        await fixture.setupViewModel.refreshNotificationPermission()
        await fixture.setupViewModel.performNotificationPermissionCardAction()

        XCTAssertNotNil(fixture.setupViewModel.notificationPermissionCard)
        XCTAssertEqual(fixture.appSettingsOpener.openCallCount, 1)
    }

    func testPermissionRequestTracksReturnedResult() async {
        let fixture = Fixture()
        fixture.notificationScheduler.currentPermission = .allowed

        await fixture.setupViewModel.performNotificationPermissionCardAction()

        XCTAssertNil(fixture.setupViewModel.notificationPermissionCard)
        XCTAssertEqual(fixture.analyticsTracker.events, [.notificationPermissionUpdated(.allowed)])
    }
}
