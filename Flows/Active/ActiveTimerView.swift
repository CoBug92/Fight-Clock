import SwiftUI

struct ActiveTimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var showsStopConfirmation = false

    var body: some View {
        GeometryReader { proxy in
            Group {
                if proxy.size.width > proxy.size.height {
                    landscapeLayout(
                        timerDiameter: min(
                            proxy.size.height - Margin.screen * 2,
                            proxy.size.width * 0.38
                        )
                    )
                } else {
                    portraitLayout(
                        timerDiameter: min(
                            proxy.size.width - Margin.screen * 2,
                            proxy.size.height * 0.47
                        )
                    )
                }
            }
            .padding(Margin.screen)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
        }
        .confirmationDialog(
            Localizations.Stop.title,
            isPresented: $showsStopConfirmation,
            titleVisibility: .visible
        ) {
            Button(Localizations.Stop.confirm, role: .destructive) {
                Task { await viewModel.stop() }
            }
            Button(Localizations.Action.cancel, role: .cancel) {}
        } message: {
            Text(Localizations.Stop.message)
        }
    }

    private func portraitLayout(timerDiameter: CGFloat) -> some View {
        VStack(spacing: Margin.section) {
            phaseLabel
            Spacer()
            timeDisplay(diameter: timerDiameter)
            roundLabel
            Spacer()
            controls
        }
    }

    private func landscapeLayout(timerDiameter: CGFloat) -> some View {
        HStack(spacing: Margin.section) {
            VStack(alignment: .leading, spacing: Margin.compact) {
                phaseLabel
                roundLabel
            }
            Spacer(minLength: Margin.standard)
            timeDisplay(diameter: timerDiameter)
            Spacer(minLength: Margin.standard)
            controls
                .frame(maxWidth: 190)
        }
    }

    private var phaseLabel: some View {
        Text(phaseTitle)
            .font(.system(.title, design: .rounded, weight: .black))
            .tracking(2)
            .accessibilityAddTraits(.isHeader)
    }

    private func timeDisplay(diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(.primary.opacity(.timerTrackOpacity), lineWidth: .timerRingWidth)

            Circle()
                .trim(from: 0, to: phaseProgress)
                .stroke(
                    .primary,
                    style: StrokeStyle(lineWidth: .timerRingWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: .progressAnimationDuration), value: phaseProgress)

            Text(formattedTime)
                .font(.system(size: .timerFontSize, weight: .black, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(.timerMinimumScaleFactor)
                .lineLimit(1)
                .padding(.horizontal, Margin.section)
                .contentTransition(.numericText(countsDown: true))
        }
        .frame(width: diameter, height: diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Localizations.Accessibility.remainingTime)
        .accessibilityValue(formattedTime)
    }

    private var roundLabel: some View {
        Text(
            Localizations.Active.roundProgress(
                viewModel.session?.currentRound ?? 0,
                viewModel.session?.configuration.roundCount ?? 0
            )
        )
        .font(.title2.bold())
    }

    private var controls: some View {
        VStack(spacing: Margin.standard) {
            Button {
                Task { await viewModel.togglePause() }
            } label: {
                Label(pauseActionTitle, systemImage: isPaused ? "play.fill" : "pause.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(.timerActionBackground))
            .foregroundStyle(Color(.timerActionForeground))
            .controlSize(.large)

            Button(Localizations.Action.stop, role: .destructive) {
                showsStopConfirmation = true
            }
            .font(.headline)
            .frame(minHeight: 44)
        }
    }

    private var phaseTitle: String {
        guard let session = viewModel.session else { return "" }
        if session.isPaused { return Localizations.Active.paused }
        switch session.phase {
        case .preparation: return Localizations.Active.preparation
        case .round: return Localizations.Active.round
        case .rest: return Localizations.Active.rest
        }
    }

    private var pauseActionTitle: String {
        isPaused ? Localizations.Action.resume : Localizations.Action.pause
    }

    private var isPaused: Bool { viewModel.session?.isPaused == true }

    private var formattedTime: String {
        String(format: "%d:%02d", viewModel.remainingSeconds / 60, viewModel.remainingSeconds % 60)
    }

    private var phaseProgress: CGFloat {
        guard let session = viewModel.session else { return 0 }

        let duration: Int
        switch session.phase {
        case .preparation:
            duration = session.configuration.preparationDuration
        case .round:
            duration = session.configuration.roundDuration
        case .rest:
            duration = session.configuration.restDuration
        }

        guard duration > 0 else { return 0 }
        return min(1, max(0, CGFloat(viewModel.remainingSeconds) / CGFloat(duration)))
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
        case .rest: return [Color(.restPhaseBackground), Color(.timerBackgroundEnd)]
        case .preparation: return [Color(.preparationPhaseBackground), Color(.timerBackgroundEnd)]
        default: return [Color(.roundPhaseBackground), Color(.timerBackgroundEnd)]
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let timerFontSize: CGFloat = 180
    static let timerMinimumScaleFactor: CGFloat = 0.5
    static let timerRingWidth: CGFloat = 14
}

private extension Double {
    static let timerTrackOpacity = 0.2
    static let progressAnimationDuration = 0.25
}

// MARK: - Preview

#Preview {
    ActiveTimerView(viewModel: AppDependencies().makeTimerViewModel())
}
