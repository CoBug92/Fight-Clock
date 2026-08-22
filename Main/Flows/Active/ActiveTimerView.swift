import SwiftUI

struct ActiveTimerView: View {
    // MARK: - Observable properties

    @ObservedObject var viewModel: RootViewModel
    @State private var showsStopConfirmation = false

    // MARK: - Layout

    var body: some View {
        GeometryReader { proxy in
            Group {
                if proxy.size.width > proxy.size.height {
                    landscapeLayout(
                        timerDiameter: min(
                            proxy.size.height - .activeTimerContentPadding * .activeTimerPaddingMultiplier,
                            proxy.size.width * .activeTimerLandscapeDiameterWidthMultiplier
                        )
                    )
                } else {
                    portraitLayout(
                        timerDiameter: min(
                            proxy.size.width - .activeTimerContentPadding * .activeTimerPaddingMultiplier,
                            proxy.size.height * .activeTimerPortraitDiameterHeightMultiplier
                        )
                    )
                }
            }
            .padding(.activeTimerContentPadding)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(background)
        }
        .confirmationDialog(
            Localizations.Stop.title,
            isPresented: $showsStopConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                Localizations.Stop.confirm,
                role: .destructive
            ) {
                Task { await viewModel.stop() }
            }
            Button(
                Localizations.Action.cancel,
                role: .cancel
            ) {}
        } message: {
            Text(Localizations.Stop.message)
        }
    }

    private func portraitLayout(timerDiameter: CGFloat) -> some View {
        VStack(spacing: Margin.x10) {
            TimerPhaseLabel(title: phaseTitle)
            Spacer()
            TimerProgressView(
                formattedTime: formattedTime,
                progress: phaseProgress,
                diameter: timerDiameter
            )
            TimerRoundLabel(
                currentRound: viewModel.session?.currentRound ?? .zero,
                roundCount: viewModel.session?.configuration.roundCount ?? .zero
            )
            Spacer()
            TimerControls(
                isPaused: isPaused,
                onTogglePause: { Task { await viewModel.togglePause() } },
                onStop: { showsStopConfirmation = true }
            )
        }
    }

    private func landscapeLayout(timerDiameter: CGFloat) -> some View {
        HStack(spacing: Margin.x10) {
            VStack(
                alignment: .leading,
                spacing: Margin.x4
            ) {
                TimerPhaseLabel(title: phaseTitle)
                TimerRoundLabel(
                    currentRound: viewModel.session?.currentRound ?? .zero,
                    roundCount: viewModel.session?.configuration.roundCount ?? .zero
                )
            }
            Spacer(minLength: Margin.x8)
            TimerProgressView(
                formattedTime: formattedTime,
                progress: phaseProgress,
                diameter: timerDiameter
            )
            Spacer(minLength: Margin.x8)
            TimerControls(
                isPaused: isPaused,
                onTogglePause: { Task { await viewModel.togglePause() } },
                onStop: { showsStopConfirmation = true }
            )
                .frame(maxWidth: .activeTimerControlsMaximumWidth)
        }
    }

    // MARK: - Computed properties

    private var phaseTitle: String {
        guard let session = viewModel.session else { return TechnicalString.empty }
        if session.isPaused { return Localizations.Active.paused }
        switch session.phase {
        case .preparation: return Localizations.Active.preparation
        case .round: return Localizations.Active.round
        case .rest: return Localizations.Active.rest
        }
    }

    private var isPaused: Bool { viewModel.session?.isPaused == true }

    private var formattedTime: String {
        String(
            format: TechnicalString.timerFormat,
            viewModel.remainingSeconds / .activeTimerSecondsPerMinute,
            viewModel.remainingSeconds % .activeTimerSecondsPerMinute
        )
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
}

// MARK: - Constants

private extension CGFloat {
    static let activeTimerContentPadding = Margin.x(14)
    static let activeTimerPaddingMultiplier: CGFloat = 2
    static let activeTimerLandscapeDiameterWidthMultiplier: CGFloat = 0.38
    static let activeTimerPortraitDiameterHeightMultiplier: CGFloat = 0.47
    static let activeTimerControlsMaximumWidth: CGFloat = 190
}

private extension Int {
    static let activeTimerSecondsPerMinute = 60
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
