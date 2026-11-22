import SwiftUI

struct ActiveTimerView: View {
    // MARK: - Observable properties

    @ObservedObject var viewModel: ActiveTimerViewModel
    @State private var showsStopConfirmation = false
    @State private var showsLargeTextStopConfirmation = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Layout

    var body: some View {
        GeometryReader { proxy in
            let width = max(.zero, proxy.size.width - .activeTimerContentPadding * 2)
            let height = max(.zero, proxy.size.height - verticalContentPadding * 2)
            let isCompactHeight = height < .activeTimerCompactHeightThreshold

            Group {
                if width > height && width >= .activeTimerLandscapeMinimumWidth {
                    let diameter = min(height, width * .activeTimerLandscapeDiameterWidthMultiplier)
                    if usesLargeTextLayout {
                        largeTextLandscapeLayout(timerDiameter: diameter)
                    } else {
                        let columnWidth = (width - diameter - Margin.x6 * 2) / 2
                        landscapeLayout(timerDiameter: diameter, columnWidth: columnWidth)
                    }
                } else {
                    let multiplier = isCompactHeight || usesLargeTextLayout
                        ? CGFloat.activeTimerCompactDiameterHeightMultiplier
                        : .activeTimerPortraitDiameterHeightMultiplier
                    let diameter = min(width, height * multiplier)
                    if usesLargeTextLayout {
                        VStack(spacing: Margin.x6) {
                            scrollableStatus(alignment: .center)
                            countdown(diameter: diameter)
                            controls
                                .frame(maxWidth: .activeTimerStackedControlsMaximumWidth)
                        }
                    } else {
                        ViewThatFits(in: .vertical) {
                            portraitLayout(timerDiameter: diameter, isCompactHeight: isCompactHeight)
                            ScrollView {
                                portraitLayout(timerDiameter: diameter, isCompactHeight: isCompactHeight)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .padding(
                .horizontal,
                .activeTimerContentPadding
            )
            .padding(
                .vertical,
                verticalContentPadding
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(background)
            #if DEBUG
            .overlay(alignment: .topTrailing) {
                if !usesLargeTextLayout {
                    nextPhaseButton
                        .padding(Margin.x4)
                }
            }
            #endif
        }
        .confirmationDialog(
            Localizations.Stop.title,
            isPresented: $showsStopConfirmation,
            titleVisibility: .visible
        ) {
            Button(Localizations.Stop.confirm, role: .destructive, action: stopWorkout)
            Button(
                Localizations.Action.cancel,
                role: .cancel
            ) {}
        } message: {
            Text(Localizations.Stop.message)
        }
        .sheet(isPresented: $showsLargeTextStopConfirmation) {
            StopWorkoutConfirmationView(
                onConfirm: stopWorkout,
                onCancel: { showsLargeTextStopConfirmation = false }
            )
        }
        .onChange(of: viewModel.session) { previous, current in
            announceChange(from: previous, to: current)
        }
    }

    private func portraitLayout(timerDiameter: CGFloat, isCompactHeight: Bool) -> some View {
        VStack(spacing: isCompactHeight ? Margin.x3 : Margin.x10) {
            phaseStatus
            if !isCompactHeight {
                Spacer(minLength: .zero)
            }
            countdown(diameter: timerDiameter)
            roundLabel
            if !isCompactHeight {
                Spacer(minLength: .zero)
            }
            controls
                .frame(maxWidth: .activeTimerStackedControlsMaximumWidth)
        }
    }

    private func landscapeLayout(timerDiameter: CGFloat, columnWidth: CGFloat) -> some View {
        let sideWidth = min(columnWidth, .activeTimerControlsMaximumWidth)
        return HStack(spacing: Margin.x6) {
            VStack(
                alignment: .leading,
                spacing: Margin.x4
            ) {
                phaseStatus
                roundLabel
            }
            .frame(width: sideWidth, alignment: .leading)
            countdown(diameter: timerDiameter)
            controls
                .frame(width: sideWidth)
        }
    }

    private func largeTextLandscapeLayout(timerDiameter: CGFloat) -> some View {
        HStack(spacing: Margin.x10) {
            countdown(diameter: timerDiameter)

            VStack(spacing: Margin.x6) {
                scrollableStatus()
                controls
            }
        }
    }

    private func scrollableStatus(alignment: Alignment = .leading) -> some View {
        ScrollView {
            VStack(spacing: Margin.x6) {
                phaseStatus
                roundLabel
                #if DEBUG
                nextPhaseButton
                #endif
            }
            .frame(
                maxWidth: .infinity,
                alignment: alignment
            )
        }
    }

    private var phaseStatus: some View {
        VStack(spacing: Margin.x3) {
            TimerPhaseLabel(
                title: isPaused ? Localizations.Active.paused : phaseTitle,
                subtitle: isPaused ? phaseTitle.capitalized : nil
            )
            .accessibilitySortPriority(3)
            if showsRoundWarning || (!usesLargeTextLayout && canShowRoundWarning) {
                Label {
                    Text(Localizations.Active.roundEnding)
                        .lineLimit(1)
                        .minimumScaleFactor(.activeTimerWarningMinimumScale)
                } icon: {
                    Image(systemName: SFSymbol.exclamationmarkCircle)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .accessibilityHidden(true)
                }
                .font(.subheadline.weight(.semibold))
                .accessibilitySortPriority(2)
                .opacity(showsRoundWarning ? 1 : .zero)
                .accessibilityHidden(!showsRoundWarning)
            }
        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )
    }

    private var roundLabel: some View {
        TimerRoundLabel(
            currentRound: viewModel.session?.currentRound ?? .zero,
            roundCount: viewModel.session?.configuration.roundCount ?? .zero
        )
    }

    private var controls: some View {
        TimerControls(
            isPaused: isPaused,
            onTogglePause: { Task { await viewModel.togglePause() } },
            onStop: showStopConfirmation
        )
    }

    private func countdown(diameter: CGFloat) -> some View {
        TimerProgressView(
            remainingSeconds: viewModel.remainingSeconds,
            progress: phaseProgress,
            diameter: diameter
        )
        .accessibilitySortPriority(1)
    }

    #if DEBUG
    private var nextPhaseButton: some View {
        Button {
            Task { await viewModel.advanceToNextPhase() }
        } label: {
            Label(
                Localizations.Action.nextPhase,
                systemImage: SFSymbol.forwardEndFill
            )
            .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .accessibilitySortPriority(-1)
    }
    #endif

    // MARK: - Computed properties

    private var usesLargeTextLayout: Bool { dynamicTypeSize >= .xxxLarge }

    private var verticalContentPadding: CGFloat { usesLargeTextLayout ? Margin.x8 : .activeTimerContentPadding }

    private var phaseTitle: String {
        guard let phase = viewModel.session?.phase else { return TechnicalString.empty }
        return title(for: phase)
    }

    private var isPaused: Bool { viewModel.session?.isPaused == true }

    private var canShowRoundWarning: Bool {
        guard let session = viewModel.session, session.phase == .round else { return false }
        let configuration = session.configuration
        return configuration.roundWarning != .disabled && configuration.roundDuration > configuration.roundWarning.rawValue
    }

    private var showsRoundWarning: Bool {
        guard let session = viewModel.session else { return false }
        return session.phase == .round && session.hasPlayedRoundWarning && !session.isPaused
    }

    private var phaseProgress: CGFloat {
        guard let session = viewModel.session else { return .zero }

        let duration: Int
        switch session.phase {
        case .preparation:
            duration = session.configuration.preparationDuration
        case .round:
            duration = session.configuration.roundDuration
        case .rest:
            duration = session.configuration.restDuration
        }

        guard duration > .zero else { return .zero }
        return min(1, max(.zero, CGFloat(viewModel.remainingSeconds) / CGFloat(duration)))
    }

    private var background: some View {
        let phase = viewModel.session?.phase
        return LinearGradient(
            colors: backgroundColors(for: phase),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func backgroundColors(for phase: SessionPhase?) -> [Color] {
        switch phase {
        case .rest: return [Color(.Background.restPhaseBackground), Color(.Background.timerBackgroundEnd)]
        case .preparation: return [Color(.Background.preparationPhaseBackground), Color(.Background.timerBackgroundEnd)]
        default: return [Color(.Background.roundPhaseBackground), Color(.Background.timerBackgroundEnd)]
        }
    }

    // MARK: - Private methods

    private func showStopConfirmation() {
        if dynamicTypeSize.isAccessibilitySize {
            showsLargeTextStopConfirmation = true
        } else {
            showsStopConfirmation = true
        }
    }

    private func stopWorkout() {
        showsLargeTextStopConfirmation = false
        Task { await viewModel.stop() }
    }

    private func title(for phase: SessionPhase) -> String {
        switch phase {
        case .preparation: Localizations.Active.preparation
        case .round: Localizations.Active.round
        case .rest: Localizations.Active.rest
        }
    }

    private func announceChange(from previous: SessionState?, to current: SessionState?) {
        guard voiceOverEnabled, scenePhase == .active,
              let previous, let current, previous.id == current.id else { return }

        let message: String
        if previous.isPaused != current.isPaused, current.isPaused {
            message = Localizations.Active.paused.capitalized
        } else if previous.phase != current.phase
            || previous.currentRound != current.currentRound
            || (previous.isPaused && !current.isPaused) {
            message = Localizations.Accessibility.pairedStatus(
                title(for: current.phase).capitalized,
                Localizations.Accessibility.spokenRoundProgress(current.currentRound, current.configuration.roundCount)
            )
        } else if current.phase == .round, !current.isPaused, current.hasPlayedRoundWarning, !previous.hasPlayedRoundWarning {
            message = Localizations.Active.roundEnding
        } else {
            return
        }
        AccessibilityNotification.Announcement(message).post()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let activeTimerContentPadding = Margin.x(14)
    static let activeTimerLandscapeMinimumWidth: CGFloat = 500
    static let activeTimerCompactHeightThreshold: CGFloat = 500
    static let activeTimerLandscapeDiameterWidthMultiplier: CGFloat = 0.38
    static let activeTimerPortraitDiameterHeightMultiplier: CGFloat = 0.47
    static let activeTimerCompactDiameterHeightMultiplier: CGFloat = 0.30
    static let activeTimerControlsMaximumWidth: CGFloat = 190
    static let activeTimerStackedControlsMaximumWidth: CGFloat = 400
    static let activeTimerWarningMinimumScale: CGFloat = 0.75
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview("Подготовка", traits: .portrait) {
    ActiveTimerView(
        viewModel: .preview(
            phase: .preparation,
            isPaused: true,
            remainingSeconds: 74
        )
    )
}

#Preview("Раунд", traits: .portrait) {
    ActiveTimerView(
        viewModel: .preview(
            phase: .round,
            remainingSeconds: 125
        )
    )
}

#Preview("Отдых", traits: .portrait) {
    ActiveTimerView(
        viewModel: .preview(
            phase: .rest,
            remainingSeconds: 42
        )
    )
}

#Preview("Раунд · landscape", traits: .landscapeLeft) {
    ActiveTimerView(
        viewModel: .preview(
            phase: .round,
            remainingSeconds: 125
        )
    )
}
#endif
