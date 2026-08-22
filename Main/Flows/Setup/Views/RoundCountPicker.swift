import SwiftUI

struct RoundCountPicker: View {
    // MARK: - Observable properties

    @Binding var count: Int
    @Binding var isExpanded: Bool

    // MARK: - Layout

    var body: some View {
        CollapsiblePickerCard(
            title: Localizations.Setup.rounds,
            summary: count.formatted(),
            isExpanded: $isExpanded
        ) {
            Picker(
                Localizations.Setup.rounds,
                selection: $count
            ) {
                ForEach(
                    Int.roundCountPickerMinimum...Int.roundCountPickerMaximum,
                    id: \.self
                ) { value in
                    Text(value.formatted()).tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: .roundCountPickerWheelHeight)
            .clipped()
            .accessibilityValue(count.formatted())
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
