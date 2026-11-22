import SwiftUI

struct DurationPicker: View {
    // MARK: - Properties

    let title: String
    @Binding var duration: Int
    let range: ClosedRange<Int>
    @Binding var isExpanded: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Computed properties

    private var options: DurationPickerOptions { DurationPickerOptions(range: range) }

    // MARK: - Layout

    var body: some View {
        CollapsiblePickerCard(
            title: title,
            summary: formattedDuration,
            accessibleSummary: SpokenDuration.format(duration),
            isExpanded: $isExpanded
        ) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: Margin.x4) {
                    durationComponent(
                        selection: minuteBinding,
                        values: options.minutes,
                        label: Localizations.Time.minutes
                    )
                    durationComponent(
                        selection: secondBinding,
                        values: options.seconds(for: minuteBinding.wrappedValue),
                        label: Localizations.Time.seconds
                    )
                }
            } else {
                HStack(spacing: .zero) {
                    durationComponent(
                        selection: minuteBinding,
                        values: options.minutes,
                        label: Localizations.Time.minutes
                    )
                    Text(TechnicalString.colon)
                        .font(.largeTitle.bold())
                        .accessibilityHidden(true)
                    durationComponent(
                        selection: secondBinding,
                        values: options.seconds(for: minuteBinding.wrappedValue),
                        label: Localizations.Time.seconds
                    )
                }
                .frame(height: .durationPickerWheelHeight)
            }
        }
        .contextMenu {
            durationMenu(
                title: Localizations.Time.minutes,
                selection: minuteBinding,
                values: options.minutes
            )
            durationMenu(
                title: Localizations.Time.seconds,
                selection: secondBinding,
                values: options.seconds(for: minuteBinding.wrappedValue)
            )
        }
    }

    // MARK: - Private methods

    private func durationMenu(title: String, selection: Binding<Int>, values: [Int]) -> some View {
        Menu(title) {
            Picker(
                title,
                selection: selection
            ) {
                durationOptions(values)
            }
            .pickerStyle(.inline)
        }
    }

    @ViewBuilder
    private func durationComponent(selection: Binding<Int>, values: [Int], label: String) -> some View {
        let accessibilityLabel = Localizations.Accessibility.durationComponent(title, label)
        if dynamicTypeSize.isAccessibilitySize {
            LargeTextPicker(
                title: label,
                selectionTitle: selection.wrappedValue.formatted(),
                controlTitle: accessibilityLabel,
                spokenSelectionTitle: selection.wrappedValue.spelledOutForAccessibility,
                selection: selection
            ) {
                durationOptions(values)
            }
        } else {
            AccessibleNumberWheel(
                title: accessibilityLabel,
                selection: selection,
                values: values,
                minimumIntegerDigits: .durationPickerMinimumIntegerDigits
            )
            .frame(maxWidth: .infinity)
            .clipped()
        }
    }

    private func durationOptions(_ values: [Int]) -> some View {
        ForEach(
            values,
            id: \.self
        ) { value in
            Text(value.formatted(.number.precision(.integerLength(.durationPickerMinimumIntegerDigits))))
                .tag(value)
        }
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
