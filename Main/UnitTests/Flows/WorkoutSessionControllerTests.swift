import XCTest
@testable import Main

@MainActor
final class WorkoutSessionControllerTests: XCTestCase {
    // MARK: - Lifecycle

    func testForegroundRestoreCatchesUpAcrossSeveralBoundaries() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(roundCount: 3, roundDuration: 10, restDuration: 5)
        let session = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: session, date: start.addingTimeInterval(31))

        await fixture.sessionController.launch(sceneIsActive: true)

        XCTAssertEqual(fixture.sessionController.session?.phase, .round)
        XCTAssertEqual(fixture.sessionController.session?.currentRound, 3)
        XCTAssertEqual(fixture.sessionController.remainingSeconds, 9)
        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        await fixture.sessionController.stop()
    }

    func testExpiredSessionIsClearedWhenApplicationReturns() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(roundCount: 1, roundDuration: 10, restDuration: 5)
        let session = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: session, date: start.addingTimeInterval(30))

        await fixture.sessionController.launch(sceneIsActive: true)

        XCTAssertNil(fixture.sessionController.session)
        XCTAssertNil(fixture.sessionRepository.value)
        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        XCTAssertEqual(fixture.analyticsTracker.events, [.workoutCompleted(session)])
        let endedSessionIDs = await fixture.liveActivityController.endedSessionIDs
        XCTAssertEqual(endedSessionIDs, [session.id])
    }

    // MARK: - Ticker lifecycle

    func testPausedSessionDoesNotWriteUnchangedStateOnTickerInterval() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let running = try XCTUnwrap(SessionEngine().start(configuration: .defaultValue, at: start))
        let paused = SessionEngine().pause(running, at: start)
        let fixture = Fixture(initialSession: paused, date: start)

        await fixture.sessionController.launch(sceneIsActive: true)
        let saveCallCount = fixture.sessionRepository.saveCallCount
        try await Task.sleep(for: .milliseconds(450))

        XCTAssertEqual(fixture.sessionRepository.saveCallCount, saveCallCount)
        await fixture.sessionController.stop()
    }

    func testInactiveSceneStopsTickerAndForegroundingCatchesUp() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(roundCount: 2, roundDuration: 10, restDuration: 5)
        let session = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: session, date: start)
        await fixture.sessionController.launch(sceneIsActive: true)

        await fixture.sessionController.setSceneActive(false)
        let saveCallCount = fixture.sessionRepository.saveCallCount
        fixture.dateProvider.value = start.addingTimeInterval(11)
        try await Task.sleep(for: .milliseconds(450))

        XCTAssertEqual(fixture.sessionRepository.saveCallCount, saveCallCount)

        await fixture.sessionController.setSceneActive(true)

        XCTAssertEqual(fixture.sessionController.session?.phase, .rest)
        XCTAssertEqual(fixture.sessionController.remainingSeconds, 4)
        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        await fixture.sessionController.stop()
    }
}
