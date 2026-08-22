import SwiftUI

struct TimerProgressView: View {
    // MARK: - Properties

    let formattedTime: String
    let progress: CGFloat
    let diameter: CGFloat

    // MARK: - Layout

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    .primary.opacity(.timerTrackOpacity),
                    lineWidth: .timerRingWidth
                )

            Circle()
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
                    .linear(duration: .progressAnimationDuration),
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
                .contentTransition(.numericText(countsDown: true))
        }
        .frame(
            width: diameter,
            height: diameter
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Localizations.Accessibility.remainingTime)
        .accessibilityValue(formattedTime)
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
    static let timerProgressRingRotationAngle = -90.0
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(traits: .sizeThatFitsLayout) {
    TimerProgressView(
        formattedTime: "2:45",
        progress: 0.75,
        diameter: 280
    )
    .padding()
}
#endif
