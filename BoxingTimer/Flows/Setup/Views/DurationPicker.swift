import SwiftUI

struct DurationPicker: View {
    let title: String
    @Binding var duration: Int
    let range: ClosedRange<Int>
    @Binding var isExpanded: Bool

    private var options: DurationPickerOptions { DurationPickerOptions(range: range) }

    var body: some View {
        CollapsiblePickerCard(title: title, summary: formattedDuration, isExpanded: $isExpanded) {
            HStack(spacing: 0) {
                wheel(selection: minuteBinding, values: options.minutes, label: Localizations.Time.minutes)
                Text(":")
                    .font(.largeTitle.bold())
                wheel(
                    selection: secondBinding,
                    values: options.seconds(for: duration / 60),
                    label: Localizations.Time.seconds
                )
            }
            .frame(height: 122)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(formattedDuration)
        }
    }

    private func wheel(selection: Binding<Int>, values: [Int], label: String) -> some View {
        Picker(label, selection: selection) {
            ForEach(values, id: \.self) { value in
                Text(value.formatted(.number.precision(.integerLength(2)))).tag(value)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var minuteBinding: Binding<Int> {
        Binding(
            get: { duration / 60 },
            set: { minutes in set(minutes: minutes, seconds: duration % 60) }
        )
    }

    private var secondBinding: Binding<Int> {
        Binding(
            get: { duration % 60 },
            set: { seconds in set(minutes: duration / 60, seconds: seconds) }
        )
    }

    private var formattedDuration: String {
        String(format: "%d:%02d", duration / 60, duration % 60)
    }

    private func set(minutes: Int, seconds: Int) {
        let candidate = minutes * 60 + seconds
        duration = min(range.upperBound, max(range.lowerBound, candidate))
    }
}

// MARK: - Preview

#Preview {
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
