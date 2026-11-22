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
                Label {
                    Text(actionTitle)
                } icon: {
                    Image(systemName: isPaused ? SFSymbol.playFill : SFSymbol.pauseFill)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .accessibilityHidden(true)
                }
                .font(.headline)
                .foregroundStyle(Color(.Text.timerActionForeground))
                .frame(maxWidth: .infinity)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .multilineTextAlignment(.center)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(.Action.timerActionBackground))
            .controlSize(.large)

            Button(
                role: .destructive,
                action: onStop
            ) {
                Text(Localizations.Action.stop)
                    .font(.headline)
                    .foregroundStyle(Color(.Text.timerDestructiveForeground))
                    .frame(minHeight: .timerControlsMinimumHeight)
                    .padding(
                        .horizontal,
                        Margin.x6
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
