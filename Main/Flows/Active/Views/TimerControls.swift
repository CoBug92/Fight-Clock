import SwiftUI

struct TimerControls: View {
    // MARK: - Properties

    let isPaused: Bool
    let onTogglePause: () -> Void
    let onStop: () -> Void

    // MARK: - Layout

    var body: some View {
        VStack(spacing: Margin.x8) {
            Button(action: onTogglePause) {
                Label(
                    actionTitle,
                    systemImage: isPaused ? SFSymbol.playFill : SFSymbol.pauseFill
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(.Action.timerActionBackground))
            .foregroundStyle(Color(.Text.timerActionForeground))
            .controlSize(.large)

            Button(
                Localizations.Action.stop,
                role: .destructive,
                action: onStop
            )
            .font(.headline)
            .frame(minHeight: .timerControlsMinimumHeight)
        }
    }

    // MARK: - Computed properties

    private var actionTitle: String {
        isPaused ? Localizations.Action.resume : Localizations.Action.pause
    }
}

// MARK: - Constants

private extension CGFloat {
    static let timerControlsMinimumHeight: CGFloat = 44
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(
    "Running",
    traits: .sizeThatFitsLayout
) {
    TimerControls(
        isPaused: false,
        onTogglePause: {},
        onStop: {}
    )
    .padding()
}

#Preview(
    "Paused",
    traits: .sizeThatFitsLayout
) {
    TimerControls(
        isPaused: true,
        onTogglePause: {},
        onStop: {}
    )
    .padding()
}
#endif
