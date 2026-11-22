import SwiftUI
import UIKit

struct SetupView: View {
    // MARK: - Observable properties

    @ObservedObject var viewModel: SetupViewModel
    @ObservedObject var soundSettingsViewModel: SoundSettingsViewModel
    @State private var pickerState: SetupPickerState

    // MARK: - Properties

    private let didCompleteWorkout: Bool
    private let pickerStateRepository: SetupPickerStateRepository

    // MARK: - Init

    init(
        viewModel: SetupViewModel,
        soundSettingsViewModel: SoundSettingsViewModel,
        didCompleteWorkout: Bool = false,
        pickerStateRepository: SetupPickerStateRepository = UserDefaultsSetupPickerStateRepository()
    ) {
        self.viewModel = viewModel
        self.soundSettingsViewModel = soundSettingsViewModel
        self.didCompleteWorkout = didCompleteWorkout
        self.pickerStateRepository = pickerStateRepository
        _pickerState = State(initialValue: pickerStateRepository.load())
    }

    // MARK: - Layout

    var body: some View {
        GeometryReader { proxy in
            let isNarrowPadWindow = UIDevice.current.userInterfaceIdiom == .pad && proxy.size.width < .setupContentMaximumWidth

            ScrollView {
                VStack(spacing: Margin.x10) {
                    SetupHeaderView()
                    if didCompleteWorkout {
                        Label(
                            Localizations.Notification.complete,
                            systemImage: SFSymbol.checkmarkCircleFill
                        )
                        .font(.headline)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    }
                    if let notificationPermissionCard = viewModel.notificationPermissionCard {
                        NotificationPermissionCard(
                            viewData: notificationPermissionCard
                        ) {
                            Task { await viewModel.performNotificationPermissionCardAction() }
                        }
                    }
                    RoundCountPicker(
                        count: roundCountBinding,
                        isExpanded: roundsExpandedBinding
                    )
                    DurationPicker(
                        title: Localizations.Setup.preparationDuration,
                        duration: preparationDurationBinding,
                        range: .zero...Int.setupMaximumPreparationDuration,
                        isExpanded: preparationExpandedBinding
                    )
                    DurationPicker(
                        title: Localizations.Setup.roundDuration,
                        duration: roundDurationBinding,
                        range: Int.setupMinimumRoundDuration...Int.setupMaximumRoundDuration,
                        isExpanded: roundDurationExpandedBinding
                    )
                    DurationPicker(
                        title: Localizations.Setup.restDuration,
                        duration: restDurationBinding,
                        range: .zero...Int.setupMaximumRestDuration,
                        isExpanded: restExpandedBinding
                    )
                    RoundWarningPicker(
                        warning: roundWarningBinding,
                        isExpanded: warningExpandedBinding
                    )
                    SoundSettingsLink(summary: soundSettingsSummary) {
                        SoundSettingsView(viewModel: soundSettingsViewModel)
                    }
                    StartSessionButton {
                        Task { await viewModel.start() }
                    }
                }
                .frame(maxWidth: .setupContentMaximumWidth)
                .padding(
                    .horizontal,
                    .setupContentHorizontalPadding
                )
                .padding(
                    .vertical,
                    Margin.x10
                )
                .padding(.top, isNarrowPadWindow ? Margin.x6 : .zero)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
            }
            .background(background)
        }
        .toolbar(
            .hidden,
            for: .navigationBar
        )
        .onChange(of: pickerState) { _, newValue in
            pickerStateRepository.save(newValue)
        }
    }

    // MARK: - Computed properties

    private var background: some View {
        ZStack {
            Color(.Background.launchBackground)
            RadialGradient(
                colors: [Color(.Effect.setupGlow), .clear],
                center: .topTrailing,
                startRadius: .setupBackgroundGlowStartRadius,
                endRadius: .setupBackgroundGlowEndRadius
            )
        }
        .ignoresSafeArea()
    }

    private var roundCountBinding: Binding<Int> {
        Binding(
            get: { viewModel.roundCount },
            set: { viewModel.update(roundCount: $0) }
        )
    }

    private var roundDurationBinding: Binding<Int> {
        Binding(
            get: { viewModel.roundDuration },
            set: { viewModel.update(roundDuration: $0) }
        )
    }

    private var preparationDurationBinding: Binding<Int> {
        Binding(
            get: { viewModel.preparationDuration },
            set: { viewModel.update(preparationDuration: $0) }
        )
    }

    private var restDurationBinding: Binding<Int> {
        Binding(
            get: { viewModel.restDuration },
            set: { viewModel.update(restDuration: $0) }
        )
    }

    private var roundWarningBinding: Binding<RoundWarning> {
        Binding(
            get: { viewModel.roundWarning },
            set: { viewModel.update(roundWarning: $0) }
        )
    }

    private var preparationExpandedBinding: Binding<Bool> {
        Binding(
            get: { pickerState.isPreparationExpanded },
            set: { pickerState.isPreparationExpanded = $0 }
        )
    }

    private var roundsExpandedBinding: Binding<Bool> {
        Binding(
            get: { pickerState.isRoundsExpanded },
            set: { pickerState.isRoundsExpanded = $0 }
        )
    }

    private var roundDurationExpandedBinding: Binding<Bool> {
        Binding(
            get: { pickerState.isRoundDurationExpanded },
            set: { pickerState.isRoundDurationExpanded = $0 }
        )
    }

    private var restExpandedBinding: Binding<Bool> {
        Binding(
            get: { pickerState.isRestExpanded },
            set: { pickerState.isRestExpanded = $0 }
        )
    }

    private var warningExpandedBinding: Binding<Bool> {
        Binding(
            get: { pickerState.isWarningExpanded },
            set: { pickerState.isWarningExpanded = $0 }
        )
    }

    private var soundSettingsSummary: String {
        [
            soundSettingsViewModel.soundConfiguration.roundStartSound.localizedTitle,
            soundSettingsViewModel.soundConfiguration.roundTransitionSound.localizedTitle,
            soundSettingsViewModel.soundConfiguration.warningSound.localizedTitle
        ].joined(separator: TechnicalString.middleDotSeparator)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let setupContentMaximumWidth: CGFloat = 620
    static let setupContentHorizontalPadding = Margin.x(14)
    static let setupBackgroundGlowStartRadius: CGFloat = 30
    static let setupBackgroundGlowEndRadius: CGFloat = 440
}

private extension Int {
    static let setupMinimumRoundDuration = 10
    static let setupMaximumRoundDuration = 900
    static let setupMaximumPreparationDuration = 300
    static let setupMaximumRestDuration = 300
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview {
    let rootViewModel = AppDependencies().makeRootViewModel()
    SetupView(viewModel: rootViewModel.setupViewModel, soundSettingsViewModel: rootViewModel.soundSettingsViewModel)
}
#endif
