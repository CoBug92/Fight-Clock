import SwiftUI

struct LiveActivityPalette {
    // MARK: - Properties

    let background: [Color]
    let accent: Color

    // MARK: - Init

    private init(background: [Color], accent: Color) {
        self.background = background
        self.accent = accent
    }

    init(
        state: BoxingTimerActivityAttributes.ContentState,
        isStale: Bool
    ) {
        if isStale {
            self = .stale
            return
        }

        switch state.phase {
        case .preparation: self = .preparation
        case .round: self = .round
        case .rest: self = .rest
        }
    }
}

// MARK: - Constants

private extension LiveActivityPalette {
    static let stale = LiveActivityPalette(
        background: [
            Color(.Background.staleStart),
            Color(.Background.staleEnd)
        ],
        accent: Color(.Accent.stale)
    )

    static let preparation = LiveActivityPalette(
        background: [
            Color(.Background.preparation),
            .black
        ],
        accent: Color(.Accent.preparation)
    )

    static let round = LiveActivityPalette(
        background: [
            Color(.Background.round),
            .black
        ],
        accent: Color(.Accent.round)
    )

    static let rest = LiveActivityPalette(
        background: [
            Color(.Background.rest),
            .black
        ],
        accent: Color(.Accent.rest)
    )
}
