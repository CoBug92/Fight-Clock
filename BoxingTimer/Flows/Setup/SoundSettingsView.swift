import SwiftUI

struct SoundSettingsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var isRoundStartExpanded = true
    @State private var isRoundTransitionExpanded = true
    @State private var isWarningExpanded = true

    var body: some View {
        ScrollView {
            VStack(spacing: Margin.section) {
                soundSection(
                    title: Localizations.SoundSettings.roundStart,
                    footer: Localizations.SoundSettings.roundStartFooter,
                    selection: roundStartBinding,
                    isExpanded: $isRoundStartExpanded
                )
                soundSection(
                    title: Localizations.SoundSettings.roundTransition,
                    footer: Localizations.SoundSettings.roundTransitionFooter,
                    selection: roundTransitionBinding,
                    isExpanded: $isRoundTransitionExpanded
                )
                soundSection(
                    title: Localizations.SoundSettings.warning,
                    footer: Localizations.SoundSettings.warningFooter,
                    selection: warningBinding,
                    isExpanded: $isWarningExpanded
                )
            }
            .padding(.horizontal, Margin.screen)
            .padding(.vertical, Margin.section)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.launchBackground).ignoresSafeArea())
        .navigationTitle(Localizations.SoundSettings.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func soundSection(
        title: String,
        footer: String,
        selection: Binding<BundledTimerSound>,
        isExpanded: Binding<Bool>
    ) -> some View {
        CollapsiblePickerCard(
            title: title,
            summary: soundTitle(for: selection.wrappedValue),
            isExpanded: isExpanded
        ) {
            VStack(alignment: .leading, spacing: Margin.compact) {
                ForEach(BundledTimerSound.allCases, id: \.self) { sound in
                    Button {
                        selection.wrappedValue = sound
                    } label: {
                        HStack(spacing: Margin.standard) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(soundTitle(for: sound))
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: sound == selection.wrappedValue ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(sound == selection.wrappedValue ? .orange : .secondary)
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, Margin.compact)
            }
        }
    }

    private var roundStartBinding: Binding<BundledTimerSound> {
        Binding(
            get: { viewModel.roundStartSound },
            set: {
                guard $0 != viewModel.roundStartSound else { return }
                viewModel.update(roundStartSound: $0)
                viewModel.preview($0)
            }
        )
    }

    private var roundTransitionBinding: Binding<BundledTimerSound> {
        Binding(
            get: { viewModel.roundTransitionSound },
            set: {
                guard $0 != viewModel.roundTransitionSound else { return }
                viewModel.update(roundTransitionSound: $0)
                viewModel.preview($0)
            }
        )
    }

    private var warningBinding: Binding<BundledTimerSound> {
        Binding(
            get: { viewModel.warningSound },
            set: {
                guard $0 != viewModel.warningSound else { return }
                viewModel.update(warningSound: $0)
                viewModel.preview($0)
            }
        )
    }

    private func soundTitle(for sound: BundledTimerSound) -> String {
        switch sound {
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

#Preview {
    NavigationStack {
        SoundSettingsView(viewModel: AppDependencies().makeTimerViewModel())
    }
}
