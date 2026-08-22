import SwiftUI

struct SoundSettingsView: View {
    // MARK: - Observable properties

    @ObservedObject var viewModel: RootViewModel
    @State private var isRoundStartExpanded = true
    @State private var isRoundTransitionExpanded = true
    @State private var isWarningExpanded = true

    // MARK: - Layout

    var body: some View {
        ScrollView {
            VStack(spacing: Margin.x10) {
                SoundSettingSection(
                    title: Localizations.SoundSettings.roundStart,
                    footer: Localizations.SoundSettings.roundStartFooter,
                    selection: roundStartBinding,
                    isExpanded: $isRoundStartExpanded
                )
                SoundSettingSection(
                    title: Localizations.SoundSettings.roundTransition,
                    footer: Localizations.SoundSettings.roundTransitionFooter,
                    selection: roundTransitionBinding,
                    isExpanded: $isRoundTransitionExpanded
                )
                SoundSettingSection(
                    title: Localizations.SoundSettings.warning,
                    footer: Localizations.SoundSettings.warningFooter,
                    selection: warningBinding,
                    isExpanded: $isWarningExpanded
                )
            }
            .padding(
                .horizontal,
                .soundSettingsContentHorizontalPadding
            )
            .padding(
                .vertical,
                Margin.x10
            )
            .frame(maxWidth: .soundSettingsContentMaximumWidth)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.Background.launchBackground).ignoresSafeArea())
        .navigationTitle(Localizations.SoundSettings.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Computed properties

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

}

// MARK: - Constants

private extension CGFloat {
    static let soundSettingsContentMaximumWidth: CGFloat = 620
    static let soundSettingsContentHorizontalPadding = Margin.x(14)
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview {
    NavigationStack {
        SoundSettingsView(viewModel: AppDependencies().makeRootViewModel())
    }
}
#endif
