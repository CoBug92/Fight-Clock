import XCTest
@testable import BoxingTimer

final class SessionBoundaryPlannerTests: XCTestCase {
    func testMaximumConfigurationProducesTwentyNineBoundaries() throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(roundCount: 15, roundDuration: 900, restDuration: 300)
        let state = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))

        let boundaries = SessionBoundaryPlanner().futureBoundaries(from: state, after: start)

        XCTAssertEqual(boundaries.count, 29)
        XCTAssertLessThanOrEqual(boundaries.count, 64)
        XCTAssertEqual(boundaries.filter { $0.signal == .restStarted }.count, 14)
        XCTAssertEqual(boundaries.filter { $0.signal == .roundStarted }.count, 14)
        XCTAssertEqual(boundaries.last?.signal, .workoutCompleted)
    }

    func testWarningAddsOneBoundaryForEveryRound() throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(
            roundCount: 15,
            roundDuration: 900,
            restDuration: 300,
            roundWarning: .thirtySeconds
        )
        let state = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))

        let boundaries = SessionBoundaryPlanner().futureBoundaries(from: state, after: start)

        XCTAssertEqual(boundaries.count, 44)
        XCTAssertEqual(boundaries.filter { $0.signal == .roundEnding(seconds: 30) }.count, 15)
    }
}
