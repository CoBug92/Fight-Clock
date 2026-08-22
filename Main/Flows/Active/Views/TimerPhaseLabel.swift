import SwiftUI

struct TimerPhaseLabel: View {
    // MARK: - Properties

    let title: String

    // MARK: - Layout

    var body: some View {
        Text(title)
            .font(
                .system(
                    .title,
                    design: .rounded,
                    weight: .black
                )
            )
            .tracking(.timerPhaseLabelTracking)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let timerPhaseLabelTracking: CGFloat = 2
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
#endif

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
