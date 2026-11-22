import SwiftUI

// MARK: - AccessibleNumberWheel

struct AccessibleNumberWheel: View {
    let title: String
    @Binding var selection: Int
    let values: [Int]
    var minimumIntegerDigits = 1
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    // MARK: - Layout

    var body: some View {
        let wheel = Picker(
            title,
            selection: $selection
        ) {
            ForEach(values, id: \.self) { value in
                Text(value.formatted(.number.precision(.integerLength(minimumIntegerDigits))))
                    .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .accessibilityInputLabels([Text(title)])

        if voiceOverEnabled {
            // The system wheel announces the selected number without its label.
            wheel.accessibilityRepresentation {
                Text(title)
                    .accessibilityValue(selection.spelledOutForAccessibility)
                    .accessibilityInputLabels([Text(title)])
                    .accessibilityAdjustableAction(adjust)
            }
        } else {
            wheel
        }
    }

    // MARK: - Private methods

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        guard let index = values.firstIndex(of: selection) else { return }

        let nextIndex: Int
        switch direction {
        case .increment: nextIndex = index + 1
        case .decrement: nextIndex = index - 1
        @unknown default: return
        }

        guard values.indices.contains(nextIndex) else { return }
        selection = values[nextIndex]
    }
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var count = 3

    AccessibleNumberWheel(
        title: Localizations.Setup.rounds,
        selection: $count,
        values: Array(1...15)
    )
}
#endif
