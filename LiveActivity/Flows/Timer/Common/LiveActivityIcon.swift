enum LiveActivityIcon {
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
