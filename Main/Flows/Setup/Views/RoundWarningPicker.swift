import SwiftUI

struct RoundWarningPicker: View {
    // MARK: - Observable properties

    @Binding var warning: RoundWarning
    @Binding var isExpanded: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Layout

    var body: some View {
        CollapsiblePickerCard(
            title: Localizations.Setup.Warning.title,
            summary: warning.title,
            accessibleSummary: warning.accessibleTitle,
            isExpanded: $isExpanded
        ) {
            if dynamicTypeSize.isAccessibilitySize {
                LargeTextPicker(
                    title: Localizations.Setup.Warning.title,
                    selectionTitle: warning.accessibleTitle,
                    showsTitle: false,
                    selection: $warning
                ) {
                    ForEach(RoundWarning.allCases, id: \.self) { option in
                        Text(option.accessibleTitle).tag(option)
                    }
                }
            } else {
                Picker(
                    Localizations.Setup.Warning.title,
                    selection: $warning
                ) {
                    ForEach(RoundWarning.allCases, id: \.self) { option in
                        Text(option.title)
                            .accessibilityLabel(option.accessibleTitle)
                            .accessibilityInputLabels([Text(option.title)])
                            .tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

// MARK: - Localized title

private extension RoundWarning {
    var accessibleTitle: String {
        self == .disabled ? title : SpokenDuration.format(rawValue)
    }

    var title: String {
        switch self {
        case .disabled:
            Localizations.Setup.Warning.disabled
        case .tenSeconds:
            Localizations.Setup.Warning.tenSeconds
        case .thirtySeconds:
            Localizations.Setup.Warning.thirtySeconds
        }
    }
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var warning = RoundWarning.tenSeconds
    @Previewable @State var isExpanded = true

    RoundWarningPicker(
        warning: $warning,
        isExpanded: $isExpanded
    )
    .padding()
}
#endif
