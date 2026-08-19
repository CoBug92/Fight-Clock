struct DurationPickerOptions: Sendable {
    let range: ClosedRange<Int>

    var minutes: [Int] {
        Array((range.lowerBound / 60)...(range.upperBound / 60))
    }

    func seconds(for minutes: Int) -> [Int] {
        stride(from: 0, through: 55, by: 5).filter {
            range.contains(minutes * 60 + $0)
        }
    }
}
