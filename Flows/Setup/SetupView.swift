import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var pickerState: SetupPickerState

    private let pickerStateRepository: SetupPickerStateRepository

    init(
        viewModel: TimerViewModel,
        pickerStateRepository: SetupPickerStateRepository = UserDefaultsSetupPickerStateRepository()
    ) {
        self.viewModel = viewModel
        self.pickerStateRepository = pickerStateRepository
        _pickerState = State(initialValue: pickerStateRepository.load())
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: Margin.section) {
                    header
                    roundsPicker
                    DurationPicker(
                        title: Localizations.Setup.preparationDuration,
                        duration: preparationDurationBinding,
                        range: 0...300,
                        isExpanded: preparationExpandedBinding
                    )
                    DurationPicker(
                        title: Localizations.Setup.roundDuration,
                        duration: roundDurationBinding,
                        range: 10...900,
                        isExpanded: roundDurationExpandedBinding
                    )
                    DurationPicker(
                        title: Localizations.Setup.restDuration,
                        duration: restDurationBinding,
                        range: 0...300,
                        isExpanded: restExpandedBinding
                    )
                    warningPicker
                    soundSettingsLink
                    notificationNotice
                    startButton
                }
                .frame(maxWidth: 620)
                .frame(minHeight: proxy.size.height)
                .padding(.horizontal, Margin.screen)
                .padding(.vertical, Margin.section)
                .frame(maxWidth: .infinity)
            }
            .background(background)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: pickerState) { _, newValue in
            pickerStateRepository.save(newValue)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Margin.compact) {
            Text(Localizations.App.name)
                .font(.system(size: 42, weight: .black, design: .rounded))
            Text(Localizations.Setup.tagline)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var roundsPicker: some View {
        CollapsiblePickerCard(
            title: Localizations.Setup.rounds,
            summary: viewModel.roundCount.formatted(),
            isExpanded: roundsExpandedBinding
        ) {
            Picker(Localizations.Setup.rounds, selection: roundCountBinding) {
                ForEach(1...15, id: \.self) { count in
                    Text(count.formatted()).tag(count)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 122)
            .clipped()
            .accessibilityValue(viewModel.roundCount.formatted())
        }
    }

    private var warningPicker: some View {
        CollapsiblePickerCard(
            title: Localizations.Setup.Warning.title,
            summary: roundWarningSummary,
            isExpanded: warningExpandedBinding
        ) {
            Picker(Localizations.Setup.Warning.title, selection: roundWarningBinding) {
                Text(Localizations.Setup.Warning.disabled).tag(RoundWarning.disabled)
                Text(Localizations.Setup.Warning.tenSeconds).tag(RoundWarning.tenSeconds)
                Text(Localizations.Setup.Warning.thirtySeconds).tag(RoundWarning.thirtySeconds)
            }
            .pickerStyle(.segmented)
        }
    }

    private var soundSettingsLink: some View {
        NavigationLink {
            SoundSettingsView(viewModel: viewModel)
        } label: {
            HStack(spacing: Margin.standard) {
                VStack(alignment: .leading, spacing: Margin.compact) {
                    Text(Localizations.Setup.Sound.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text(soundSettingsSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: Margin.standard)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding(Margin.standard)
            .background(Color(.cardBackground), in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var notificationNotice: some View {
        if viewModel.notificationPermission != .allowed {
            VStack(alignment: .leading, spacing: Margin.compact) {
                Label(Localizations.Permission.title, systemImage: "bell.badge")
                    .font(.headline)
                Text(Localizations.Permission.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if viewModel.notificationPermission == .notDetermined {
                    Button(Localizations.Permission.allow) {
                        Task { await viewModel.requestNotifications() }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var startButton: some View {
        Button {
            Task { await viewModel.start() }
        } label: {
            Text(Localizations.Action.start)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, Margin.compact)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .controlSize(.large)
        .accessibilityHint(Localizations.Accessibility.startHint)
    }

    private var background: some View {
        ZStack {
            Color(.launchBackground)
            RadialGradient(
                colors: [Color(.setupGlow), .clear],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 440
            )
        }
        .ignoresSafeArea()
    }

    private var roundCountBinding: Binding<Int> {
        Binding(get: { viewModel.roundCount }, set: { viewModel.update(roundCount: $0) })
    }

    private var roundDurationBinding: Binding<Int> {
        Binding(get: { viewModel.roundDuration }, set: { viewModel.update(roundDuration: $0) })
    }

    private var preparationDurationBinding: Binding<Int> {
        Binding(
            get: { viewModel.preparationDuration },
            set: { viewModel.update(preparationDuration: $0) }
        )
    }

    private var restDurationBinding: Binding<Int> {
        Binding(get: { viewModel.restDuration }, set: { viewModel.update(restDuration: $0) })
    }

    private var roundWarningBinding: Binding<RoundWarning> {
        Binding(get: { viewModel.roundWarning }, set: { viewModel.update(roundWarning: $0) })
    }

    private var preparationExpandedBinding: Binding<Bool> {
        Binding(
            get: { pickerState.isPreparationExpanded },
            set: { pickerState.isPreparationExpanded = $0 }
        )
    }

    private var roundsExpandedBinding: Binding<Bool> {
        Binding(get: { pickerState.isRoundsExpanded }, set: { pickerState.isRoundsExpanded = $0 })
    }

    private var roundDurationExpandedBinding: Binding<Bool> {
        Binding(
            get: { pickerState.isRoundDurationExpanded },
            set: { pickerState.isRoundDurationExpanded = $0 }
        )
    }

    private var restExpandedBinding: Binding<Bool> {
        Binding(get: { pickerState.isRestExpanded }, set: { pickerState.isRestExpanded = $0 })
    }

    private var warningExpandedBinding: Binding<Bool> {
        Binding(get: { pickerState.isWarningExpanded }, set: { pickerState.isWarningExpanded = $0 })
    }

    private var roundWarningSummary: String {
        switch viewModel.roundWarning {
        case .disabled:
            Localizations.Setup.Warning.disabled
        case .tenSeconds:
            Localizations.Setup.Warning.tenSeconds
        case .thirtySeconds:
            Localizations.Setup.Warning.thirtySeconds
        }
    }

    private var soundSettingsSummary: String {
        [
            soundTitle(for: viewModel.roundStartSound),
            soundTitle(for: viewModel.roundTransitionSound),
            soundTitle(for: viewModel.warningSound)
        ].joined(separator: " · ")
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

// MARK: - Preview

#Preview {
    SetupView(viewModel: AppDependencies().makeTimerViewModel())
}
