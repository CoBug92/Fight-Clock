import SwiftUI

struct RoundCountPicker: View {
    // MARK: - Observable properties

    @Binding var count: Int
    @Binding var isExpanded: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Layout

    var body: some View {
        CollapsiblePickerCard(
            title: Localizations.Setup.rounds,
            summary: count.formatted(),
            accessibleSummary: count.spelledOutForAccessibility,
            isExpanded: $isExpanded
        ) {
            if dynamicTypeSize.isAccessibilitySize {
                LargeTextPicker(
                    title: Localizations.Setup.rounds,
                    selectionTitle: count.formatted(),
                    controlTitle: Localizations.Accessibility.intervalCount,
                    spokenSelectionTitle: count.spelledOutForAccessibility,
                    showsTitle: false,
                    selection: $count
                ) {
                    options
                }
            } else {
                AccessibleNumberWheel(
                    title: Localizations.Accessibility.intervalCount,
                    selection: $count,
                    values: Array(Int.roundCountPickerMinimum...Int.roundCountPickerMaximum)
                )
                .frame(height: .roundCountPickerWheelHeight)
                .clipped()
            }
        }
        .contextMenu {
            Picker(
                Localizations.Accessibility.intervalCount,
                selection: $count
            ) {
                options
            }
        }
    }

    private var options: some View {
        ForEach(
            Int.roundCountPickerMinimum...Int.roundCountPickerMaximum,
            id: \.self
        ) { value in
            Text(value.formatted()).tag(value)
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let roundCountPickerWheelHeight: CGFloat = 122
}

private extension Int {
    static let roundCountPickerMinimum = 1
    static let roundCountPickerMaximum = 15
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var count = 3
    @Previewable @State var isExpanded = true

    RoundCountPicker(
        count: $count,
        isExpanded: $isExpanded
    )
    .padding()
}
#endif
