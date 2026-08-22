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
    }

    // MARK: - Computed properties

    private var title: String {
        if isStale { return Localizations.Activity.staleShort }
        if state.isPaused { return Localizations.Activity.paused }

        switch state.phase {
        case .preparation: return Localizations.Activity.preparation
        case .round: return Localizations.Activity.round
        case .rest: return Localizations.Activity.rest
        }
    }
}

// MARK: - Constants

private extension Double {
    static let liveActivityBadgeOpacity = 0.18
}
