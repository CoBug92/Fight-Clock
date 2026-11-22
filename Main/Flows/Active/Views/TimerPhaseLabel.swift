import SwiftUI

struct TimerPhaseLabel: View {
    // MARK: - Properties

    let title: String
    var subtitle: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Layout

    var body: some View {
        VStack(spacing: Margin.x2) {
            Text(dynamicTypeSize.isAccessibilitySize ? title.capitalized : title)
                .font(
                    .system(
                        .title,
                        design: .rounded,
                        weight: .black
                    )
                )
                .tracking(dynamicTypeSize.isAccessibilitySize ? .zero : .timerPhaseLabelTracking)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 1 : nil)
                .minimumScaleFactor(.timerPhaseLabelMinimumScale)
            if let subtitle {
                Text(subtitle)
                    .font(.headline)
            }
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title.capitalized)
        .accessibilityValue(subtitle ?? TechnicalString.empty)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let timerPhaseLabelTracking: CGFloat = 2
    static let timerPhaseLabelMinimumScale: CGFloat = 0.7
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview(
    "Раунд",
    traits: .sizeThatFitsLayout
) {
    TimerPhaseLabel(title: "РАУНД")
        .padding()
}

#Preview(
    "Пауза",
    traits: .sizeThatFitsLayout
) {
    TimerPhaseLabel(title: "ПАУЗА")
        .padding()
}
#Preview(
    "Подготовка",
    traits: .sizeThatFitsLayout
) {
    TimerPhaseLabel(title: "ПОДГОТОВКА")
        .padding()
}

#Preview(
    "Отдых",
    traits: .sizeThatFitsLayout
) {
    TimerPhaseLabel(title: "ОТДЫХ")
        .padding()
}
#endif
