import SwiftUI

// MARK: - LargeTextPicker

struct LargeTextPicker<Selection: Hashable, Options: View>: View {
    let title: String
    let selectionTitle: String
    var controlTitle: String?
    var spokenSelectionTitle: String?
    var showsTitle = true
    @Binding var selection: Selection
    @ViewBuilder let options: () -> Options

    // MARK: - Layout

    var body: some View {
        Menu {
            Picker(
                title,
                selection: $selection,
                content: options
            )
            .pickerStyle(.inline)
        } label: {
            HStack(spacing: Margin.x4) {
                VStack(
                    alignment: .leading,
                    spacing: Margin.x1
                ) {
                    if showsTitle {
                        Text(title)
                            .font(.subheadline)
                            .foregroundStyle(Color(.Text.secondaryForeground))
                    }
                    Text(selectionTitle)
                        .font(.body.weight(.semibold))
                }
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .multilineTextAlignment(.leading)
                Spacer(minLength: Margin.x4)
                Image(systemName: SFSymbol.chevronDown)
                    .font(.caption.bold())
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: .pickerMinimumTouchHeight)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(controlTitle ?? title)
        .accessibilityInputLabels([Text(controlTitle ?? title)])
        .accessibilityValue(spokenSelectionTitle ?? selectionTitle)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let pickerMinimumTouchHeight: CGFloat = 44
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selection = 3

    LargeTextPicker(
        title: Localizations.Setup.rounds,
        selectionTitle: selection.formatted(),
        selection: $selection
    ) {
        ForEach(1...15, id: \.self) { value in
            Text(value.formatted()).tag(value)
        }
    }
    .environment(\.dynamicTypeSize, .accessibility5)
    .padding()
}
#endif
