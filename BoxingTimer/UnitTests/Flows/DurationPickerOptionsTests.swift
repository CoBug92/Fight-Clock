import XCTest
@testable import BoxingTimer

final class DurationPickerOptionsTests: XCTestCase {
    func testRoundOptionsExcludeValuesBelowMinimum() {
        let options = DurationPickerOptions(range: 10...900)

        XCTAssertEqual(options.seconds(for: 0), Array(stride(from: 10, through: 55, by: 5)))
    }

    func testRoundOptionsExcludeValuesAboveMaximum() {
        let options = DurationPickerOptions(range: 10...900)

        XCTAssertEqual(options.seconds(for: 15), [0])
    }

    func testRestOptionsAllowZeroButNotValuesAboveFiveMinutes() {
        let options = DurationPickerOptions(range: 0...300)

        XCTAssertTrue(options.seconds(for: 0).contains(0))
        XCTAssertEqual(options.seconds(for: 5), [0])
    }
}
