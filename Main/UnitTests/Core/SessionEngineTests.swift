import XCTest
@testable import Main

final class SessionEngineTests: XCTestCase {
    // MARK: - Properties

    private let engine = SessionEngine()
    private let start = Date(timeIntervalSince1970: 1_000)

    // MARK: - Session resolution

    func testStartCreatesPreparationWithAbsoluteBoundary() throws {
        let state = try XCTUnwrap(engine.start(configuration: .defaultValue, at: start))

        XCTAssertEqual(state.phase, .preparation)
        XCTAssertEqual(state.currentRound, 1)
        XCTAssertEqual(state.phaseEndDate, start.addingTimeInterval(10))
        XCTAssertFalse(state.isPaused)
    }

    func testPreparationTransitionsToFirstRoundWithoutDrift() throws {
        let configuration = TimerConfiguration(
            roundCount: 1,
            roundDuration: 60,
            restDuration: .zero,
            preparationDuration: 15
        )
        let state = try XCTUnwrap(engine.start(configuration: configuration, at: start))
        let resolution = engine.resolve(state, at: start.addingTimeInterval(15))

        XCTAssertEqual(resolution.state?.phase, .round)
        XCTAssertEqual(resolution.state?.currentRound, 1)
        XCTAssertEqual(resolution.state?.phaseEndDate, start.addingTimeInterval(75))
        XCTAssertEqual(resolution.signals, [.roundStarted])
    }

    func testResolveTransitionsRoundToRest() throws {
        let state = try XCTUnwrap(engine.start(configuration: configuration(), at: start))
        let resolution = engine.resolve(state, at: start.addingTimeInterval(10))

        XCTAssertEqual(resolution.state?.phase, .rest)
        XCTAssertEqual(resolution.state?.phaseEndDate, start.addingTimeInterval(15))
        XCTAssertEqual(resolution.signals, [.restStarted])
    }

    func testZeroRestTransitionsDirectlyToNextRound() throws {
        let state = try XCTUnwrap(
            engine.start(configuration: configuration(roundCount: 2, restDuration: .zero), at: start)
        )
        let resolution = engine.resolve(state, at: start.addingTimeInterval(10))

        XCTAssertEqual(resolution.state?.phase, .round)
        XCTAssertEqual(resolution.state?.currentRound, 2)
        XCTAssertEqual(resolution.signals, [.roundStarted])
    }

    func testFinalRoundCompletesWithoutRest() throws {
        let state = try XCTUnwrap(
            engine.start(configuration: configuration(roundCount: 1, restDuration: 5), at: start)
        )
        let resolution = engine.resolve(state, at: start.addingTimeInterval(10))

        XCTAssertNil(resolution.state)
        XCTAssertEqual(resolution.signals, [.workoutCompleted])
    }

    func testResolveSkipsMultipleBoundariesWithoutDrift() throws {
        let state = try XCTUnwrap(engine.start(configuration: configuration(roundCount: 3), at: start))
        let resolution = engine.resolve(state, at: start.addingTimeInterval(31))

        XCTAssertEqual(resolution.state?.phase, .round)
        XCTAssertEqual(resolution.state?.currentRound, 3)
        XCTAssertEqual(resolution.state?.phaseEndDate, start.addingTimeInterval(40))
        XCTAssertEqual(resolution.signals, [.restStarted, .roundStarted, .restStarted, .roundStarted])
    }

    func testMaximumWorkoutCompletesAtExactAbsoluteBoundaryWithoutDrift() throws {
        let configuration = TimerConfiguration(
            roundCount: 15,
            roundDuration: 900,
            restDuration: 300,
            preparationDuration: 300,
            roundWarning: .thirtySeconds
        )
        let state = try XCTUnwrap(engine.start(configuration: configuration, at: start))

        let resolution = engine.resolve(state, at: start.addingTimeInterval(18_000))

        XCTAssertNil(resolution.state)
        XCTAssertEqual(resolution.signals.count, 45)
        XCTAssertEqual(resolution.signals.last, .workoutCompleted)
    }

    func testPauseAndResumePreserveRemainingTimeAndAreIdempotent() throws {
        let state = try XCTUnwrap(engine.start(configuration: configuration(), at: start))
        let pauseDate = start.addingTimeInterval(3.25)
        let paused = engine.pause(state, at: pauseDate)

        XCTAssertEqual(try XCTUnwrap(paused.pausedRemaining), 6.75, accuracy: 0.001)
        XCTAssertEqual(engine.pause(paused, at: start.addingTimeInterval(5)), paused)

        let resumed = engine.resume(paused, at: start.addingTimeInterval(100))
        XCTAssertEqual(resumed.phaseEndDate, start.addingTimeInterval(106.75))
        XCTAssertEqual(engine.resume(resumed, at: start.addingTimeInterval(101)), resumed)
    }

    #if DEBUG
    func testAdvanceFromPausedRoundWithNoRestKeepsNextRoundPaused() throws {
        let state = try XCTUnwrap(engine.start(configuration: configuration(restDuration: .zero), at: start))
        let paused = engine.pause(state, at: start.addingTimeInterval(2))
        let advanceDate = start.addingTimeInterval(100)

        let resolution = engine.advanceToNextPhase(paused, at: advanceDate)

        let next = try XCTUnwrap(resolution.state)
        XCTAssertEqual(next.phase, .round)
        XCTAssertEqual(next.currentRound, 2)
        XCTAssertTrue(next.isPaused)
        XCTAssertNil(next.phaseEndDate)
        XCTAssertEqual(next.pausedRemaining, 10)
        XCTAssertTrue(resolution.signals.isEmpty)
        XCTAssertEqual(engine.resume(next, at: advanceDate).phaseEndDate, advanceDate.addingTimeInterval(10))
    }
    #endif

    // MARK: - Round warnings

    func testRoundWarningIsEmittedOnceBeforeRoundEnd() throws {
        let configuration = TimerConfiguration(
            roundCount: 1,
            roundDuration: 60,
            restDuration: .zero,
            roundWarning: .thirtySeconds
        )
        let state = try XCTUnwrap(engine.start(configuration: configuration, at: start))

        let warning = engine.resolve(state, at: start.addingTimeInterval(30))
        XCTAssertEqual(warning.signals, [.roundEnding(seconds: 30)])
        XCTAssertEqual(warning.state?.hasPlayedRoundWarning, true)

        let repeated = engine.resolve(try XCTUnwrap(warning.state), at: start.addingTimeInterval(31))
        XCTAssertTrue(repeated.signals.isEmpty)
    }

    func testWarningIsSkippedWhenItIsNotShorterThanRound() throws {
        let configuration = TimerConfiguration(
            roundCount: 1,
            roundDuration: 10,
            restDuration: .zero,
            roundWarning: .tenSeconds
        )
        let state = try XCTUnwrap(engine.start(configuration: configuration, at: start))

        XCTAssertTrue(engine.resolve(state, at: start.addingTimeInterval(5)).signals.isEmpty)
    }

    // MARK: - Private methods

    private func configuration(
        roundCount: Int = 3,
        roundDuration: Int = 10,
        restDuration: Int = 5
    ) -> TimerConfiguration {
        TimerConfiguration(
            roundCount: roundCount,
            roundDuration: roundDuration,
            restDuration: restDuration
        )
    }
}
