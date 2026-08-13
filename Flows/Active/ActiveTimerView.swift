import SwiftUI

struct ActiveTimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var showsStopConfirmation = false

    var body: some View {
        GeometryReader { proxy in
            Group {
                if proxy.size.width > proxy.size.height {
                    landscapeLayout
                } else {
                    portraitLayout
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

    private var portraitLayout: some View {
        VStack(spacing: Margin.section) {
            phaseLabel
            Spacer()
            timeLabel
            roundLabel
            Spacer()
            controls
        }
    }

    private var landscapeLayout: some View {
        HStack(spacing: Margin.section) {
            VStack(alignment: .leading, spacing: Margin.compact) {
                phaseLabel
                roundLabel
            }
            Spacer(minLength: Margin.standard)
            timeLabel
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

    private var timeLabel: some View {
        Text(formattedTime)
            .font(.system(size: 96, weight: .black, design: .rounded))
            .monospacedDigit()
            .minimumScaleFactor(0.45)
            .lineLimit(1)
            .contentTransition(.numericText(countsDown: true))
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

// MARK: - Preview

#Preview {
    ActiveTimerView(viewModel: AppDependencies().makeTimerViewModel())
}
