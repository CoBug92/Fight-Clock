struct DurationPickerOptions: Sendable {
    let range: ClosedRange<Int>

    var minutes: [Int] {
        Array((range.lowerBound / .durationPickerOptionsSecondsPerMinute)...(range.upperBound / .durationPickerOptionsSecondsPerMinute))
    }

    func seconds(for minutes: Int) -> [Int] {
        stride(
            from: .zero,
            through: .durationPickerOptionsMaximumSeconds,
            by: .durationPickerOptionsStep
        ).filter {
            range.contains(minutes * .durationPickerOptionsSecondsPerMinute + $0)
        }
    }
}

// MARK: - Constants

private extension Int {
    static let durationPickerOptionsSecondsPerMinute = 60
    static let durationPickerOptionsMaximumSeconds = 55
    static let durationPickerOptionsStep = 5
}
