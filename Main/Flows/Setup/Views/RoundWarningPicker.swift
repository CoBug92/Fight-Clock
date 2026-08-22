import SwiftUI

struct RoundWarningPicker: View {
    // MARK: - Observable properties

    @Binding var warning: RoundWarning
    @Binding var isExpanded: Bool

    // MARK: - Layout

    var body: some View {
        CollapsiblePickerCard(
            title: Localizations.Setup.Warning.title,
            summary: warning.title,
            isExpanded: $isExpanded
        ) {
            Picker(
                Localizations.Setup.Warning.title,
                selection: $warning
            ) {
                Text(Localizations.Setup.Warning.disabled).tag(RoundWarning.disabled)
                Text(Localizations.Setup.Warning.tenSeconds).tag(RoundWarning.tenSeconds)
                Text(Localizations.Setup.Warning.thirtySeconds)
                    .tag(RoundWarning.thirtySeconds)
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Localized title

private extension RoundWarning {
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
