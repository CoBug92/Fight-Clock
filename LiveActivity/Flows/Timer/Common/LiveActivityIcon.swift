enum LiveActivityIcon {
    static func phaseTitle(for phase: SessionPhase) -> String {
        switch phase {
        case .preparation: Localizations.Activity.preparation
        case .round: Localizations.Activity.round
        case .rest: Localizations.Activity.rest
        }
    }

    static func accessibilityLabel(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> String {
        if isStale { return Localizations.Activity.stale.capitalized }
        let phase = phaseTitle(for: state.phase).capitalized
        if state.isPaused {
            return Localizations.Accessibility.pairedStatus(Localizations.Activity.paused.capitalized, phase)
        }
        return phase
    }

    static func systemName(
        for state: BoxingTimerActivityAttributes.ContentState,
        isStale: Bool
    ) -> String {
        if isStale { return SFSymbol.arrowClockwiseCircleFill }
        if state.isPaused { return SFSymbol.pauseCircleFill }

        switch state.phase {
        case .preparation: return SFSymbol.figureCooldown
        case .round: return SFSymbol.figureBoxing
        case .rest: return SFSymbol.heartCircleFill
        }
    }
}
