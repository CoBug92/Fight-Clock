import SwiftUI

struct TimerProgressView: View {
    // MARK: - Properties

    let remainingSeconds: Int
    let progress: CGFloat
    let diameter: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    // MARK: - Layout

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    .primary.opacity(contrast == .increased ? .timerHighContrastTrackOpacity : .timerTrackOpacity),
                    lineWidth: .timerRingWidth
                )

            Circle()
                .inset(by: .timerRingWidth / 2)
                .trim(
                    from: .zero,
                    to: progress
                )
                .stroke(
                    .primary,
                    style: StrokeStyle(
                        lineWidth: .timerRingWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(.timerProgressRingRotationAngle))
                .animation(
                    reduceMotion ? nil : .linear(duration: .progressAnimationDuration),
                    value: progress
                )

            Text(formattedTime)
                .font(
                    .system(
                        size: .timerFontSize,
                        weight: .black,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .minimumScaleFactor(.timerMinimumScaleFactor)
                .lineLimit(1)
                .padding(
                    .horizontal,
                    Margin.x10
                )
                .contentTransition(reduceMotion ? .identity : .numericText(countsDown: true))
        }
        .frame(
            width: diameter,
            height: diameter
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Localizations.Accessibility.remainingTime)
        .accessibilityValue(SpokenDuration.format(remainingSeconds))
    }

    private var formattedTime: String {
        String(
            format: TechnicalString.timerFormat,
            remainingSeconds / .timerSecondsPerMinute,
            remainingSeconds % .timerSecondsPerMinute
        )
    }
}

// MARK: - Constants

private extension CGFloat {
    static let timerFontSize: CGFloat = 180
    static let timerMinimumScaleFactor: CGFloat = 0.2
    static let timerRingWidth: CGFloat = 14
}

private extension Double {
    static let timerTrackOpacity = 0.2
    static let timerHighContrastTrackOpacity = 0.5
    static let progressAnimationDuration = 0.25
    static let timerProgressRingRotationAngle = -90.0
}

private extension Int {
    static let timerSecondsPerMinute = 60
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    TimerProgressView(
        remainingSeconds: 165,
        progress: 0.75,
        diameter: 280
    )
    .padding()
}
#endif
