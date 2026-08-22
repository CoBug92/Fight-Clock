import SwiftUI

struct DurationPicker: View {
    // MARK: - Properties

    let title: String
    @Binding var duration: Int
    let range: ClosedRange<Int>
    @Binding var isExpanded: Bool

    // MARK: - Computed properties

    private var options: DurationPickerOptions { DurationPickerOptions(range: range) }

    // MARK: - Layout

    var body: some View {
        CollapsiblePickerCard(
            title: title,
            summary: formattedDuration,
            isExpanded: $isExpanded
        ) {
            HStack(spacing: .zero) {
                wheel(
                    selection: minuteBinding,
                    values: options.minutes,
                    label: Localizations.Time.minutes
                )
                Text(TechnicalString.colon)
                    .font(.largeTitle.bold())
                wheel(
                    selection: secondBinding,
                    values: options.seconds(for: duration / .durationPickerSecondsPerMinute),
                    label: Localizations.Time.seconds
                )
            }
            .frame(height: .durationPickerWheelHeight)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(formattedDuration)
        }
    }

    // MARK: - Private methods

    private func wheel(selection: Binding<Int>, values: [Int], label: String) -> some View {
        Picker(
            label,
            selection: selection
        ) {
            ForEach(
                values,
                id: \.self
            ) { value in
                Text(value.formatted(.number.precision(.integerLength(.durationPickerMinimumIntegerDigits)))).tag(value)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    // MARK: - Computed properties

    private var minuteBinding: Binding<Int> {
        Binding(
            get: { duration / .durationPickerSecondsPerMinute },
            set: { minutes in
                set(
                    minutes: minutes,
                    seconds: duration % .durationPickerSecondsPerMinute
                )
            }
        )
    }

    private var secondBinding: Binding<Int> {
        Binding(
            get: { duration % .durationPickerSecondsPerMinute },
            set: { seconds in
                set(
                    minutes: duration / .durationPickerSecondsPerMinute,
                    seconds: seconds
                )
            }
        )
    }

    private var formattedDuration: String {
        String(
            format: TechnicalString.timerFormat,
            duration / .durationPickerSecondsPerMinute,
            duration % .durationPickerSecondsPerMinute
        )
    }

    // MARK: - Private methods

    private func set(minutes: Int, seconds: Int) {
        let candidate = minutes * .durationPickerSecondsPerMinute + seconds
        duration = min(
            range.upperBound,
            max(
                range.lowerBound,
                candidate
            )
        )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let durationPickerWheelHeight: CGFloat = 122
}

private extension Int {
    static let durationPickerSecondsPerMinute = 60
    static let durationPickerMinimumIntegerDigits = 2
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var duration = 150
    @Previewable @State var isExpanded = true

    DurationPicker(
        title: "Round",
        duration: $duration,
        range: 10...900,
        isExpanded: $isExpanded
    )
    .padding()
}
#endif
