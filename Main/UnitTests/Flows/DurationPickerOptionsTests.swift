import XCTest
@testable import Main

final class DurationPickerOptionsTests: XCTestCase {
    // MARK: - Options

    func testRoundOptionsExcludeValuesBelowMinimum() {
        let options = DurationPickerOptions(range: 10...900)

        XCTAssertEqual(options.seconds(for: .zero), Array(stride(from: 10, through: 55, by: 5)))
    }

    func testRoundOptionsExcludeValuesAboveMaximum() {
        let options = DurationPickerOptions(range: 10...900)

        XCTAssertEqual(options.seconds(for: 15), [.zero])
    }

    func testRestOptionsAllowZeroButNotValuesAboveFiveMinutes() {
        let options = DurationPickerOptions(range: .zero...300)

        XCTAssertTrue(options.seconds(for: .zero).contains(.zero))
        XCTAssertEqual(options.seconds(for: 5), [.zero])
    }
}
