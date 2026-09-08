import XCTest
@testable import Main

@MainActor
final class ActiveTimerViewModelTests: XCTestCase {
    // MARK: - Session state

    func testInitialSessionIsExposedByDedicatedViewModel() throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let session = try XCTUnwrap(SessionEngine().start(configuration: .defaultValue, at: start))
        let fixture = Fixture(initialSession: session, date: start)

        XCTAssertEqual(fixture.activeTimerViewModel.session, session)
        XCTAssertEqual(fixture.activeTimerViewModel.remainingSeconds, session.configuration.preparationDuration)
    }

    func testPauseAndStopActionsUpdatePublishedSession() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let session = try XCTUnwrap(SessionEngine().start(configuration: .defaultValue, at: start))
        let fixture = Fixture(initialSession: session, date: start)

        await fixture.activeTimerViewModel.togglePause()

        XCTAssertEqual(fixture.activeTimerViewModel.session?.isPaused, true)
        XCTAssertEqual(fixture.activeTimerViewModel.remainingSeconds, session.configuration.preparationDuration)

        await fixture.activeTimerViewModel.stop()

        XCTAssertNil(fixture.activeTimerViewModel.session)
        XCTAssertEqual(fixture.activeTimerViewModel.remainingSeconds, .zero)
    }
}
