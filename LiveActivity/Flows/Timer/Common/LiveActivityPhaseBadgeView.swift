import SwiftUI

struct LiveActivityPhaseBadgeView: View {
    // MARK: - Properties

    let state: BoxingTimerActivityAttributes.ContentState
    let isStale: Bool

    // MARK: - Layout

    var body: some View {
        Label {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(.liveActivityBadgeMinimumScale)
        } icon: {
            Image(
                systemName: LiveActivityIcon.systemName(
                    for: state,
                    isStale: isStale
                )
            )
            .font(.caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(
            .horizontal,
            Margin.x5
        )
        .padding(
            .vertical,
            Margin.x3
        )
        .background(
            .white.opacity(.liveActivityBadgeOpacity),
            in: Capsule()
        )
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(LiveActivityIcon.accessibilityLabel(for: state, isStale: isStale))
    }

    // MARK: - Computed properties

    private var title: String {
        if isStale { return Localizations.Activity.staleShort }
        if state.isPaused { return Localizations.Activity.paused }

        return LiveActivityIcon.phaseTitle(for: state.phase)
    }
}

// MARK: - Constants

private extension Double {
    static let liveActivityBadgeOpacity = 0.18
}

private extension CGFloat {
    static let liveActivityBadgeMinimumScale: CGFloat = 0.65
}
