import SwiftUI

struct SoundSettingSection: View {
    // MARK: - Properties

    let title: String
    let footer: String
    @Binding var selection: BundledTimerSound
    @Binding var isExpanded: Bool

    // MARK: - Layout

    var body: some View {
        CollapsiblePickerCard(
            title: title,
            summary: selection.localizedTitle,
            isExpanded: $isExpanded
        ) {
            VStack(
                alignment: .leading,
                spacing: Margin.x4
            ) {
                ForEach(
                    BundledTimerSound.allCases,
                    id: \.self
                ) { sound in
                    SoundOptionRow(
                        sound: sound,
                        isSelected: sound == selection
                    ) {
                        selection = sound
                    }
                }

                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(
                        .top,
                        Margin.x4
                    )
            }
        }
    }
}

// MARK: - Localized title

extension BundledTimerSound {
    var localizedTitle: String {
        switch self {
        case .singleGong:
            Localizations.SoundSettings.Sound.singleGong
        case .tripleGong:
            Localizations.SoundSettings.Sound.tripleGong
        case .brightBell:
            Localizations.SoundSettings.Sound.brightBell
        case .bongoDrumTrill:
            Localizations.SoundSettings.Sound.bongoDrumTrill
        case .clickQuartetRhythm:
            Localizations.SoundSettings.Sound.clickQuartetRhythm
        case .rhythmicPattern:
            Localizations.SoundSettings.Sound.rhythmicPattern
        }
    }
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selection = BundledTimerSound.brightBell
    @Previewable @State var isExpanded = true

    SoundSettingSection(
        title: Localizations.SoundSettings.roundStart,
        footer: Localizations.SoundSettings.roundStartFooter,
        selection: $selection,
        isExpanded: $isExpanded
    )
    .padding()
}
#endif
