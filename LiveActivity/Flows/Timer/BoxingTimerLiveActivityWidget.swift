import ActivityKit
import SwiftUI
import WidgetKit

struct BoxingTimerLiveActivityWidget: Widget {
    // MARK: - Layout

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BoxingTimerActivityAttributes.self) { context in
            ZStack {
                LinearGradient(
                    colors: palette(
                        for: context.state,
                        isStale: context.isStale
                    ).background,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(
                    alignment: .leading,
                    spacing: Margin.x5
                ) {
                    HStack(alignment: .top) {
                        phaseBadge(
                            for: context.state,
                            isStale: context.isStale
                        )
                        Spacer()
                        roundCounter(for: context.state)
                    }
                    .frame(maxWidth: .infinity)

                    countdown(
                        for: context.state,
                        isStale: context.isStale
                    )
                        .font(
                            .system(
                                size: .liveActivityExpandedFontSize,
                                weight: .heavy,
                                design: .rounded
                            )
                            .monospacedDigit()
                        )
                        .foregroundStyle(.white)
                }
                .padding(Margin.x9)
                .frame(
                    maxWidth: .infinity,
                    minHeight: .liveActivityContentHeight,
                    alignment: .topLeading
                )
            }
            .activityBackgroundTint(.clear)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    phaseBadge(
                        for: context.state,
                        isStale: context.isStale
                    )
                }
                DynamicIslandExpandedRegion(.trailing) {
                    roundCounter(for: context.state)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    countdown(
                        for: context.state,
                        isStale: context.isStale
                    )
                        .font(
                            .system(
                                size: .liveActivityCompactFontSize,
                                weight: .heavy,
                                design: .rounded
                            )
                            .monospacedDigit()
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            } compactLeading: {
                Image(
                    systemName: compactIcon(
                        for: context.state,
                        isStale: context.isStale
                    )
                )
            } compactTrailing: {
                if context.isStale {
                    Image(systemName: SFSymbol.compactTimerWarning)
                } else {
                    countdown(
                        for: context.state,
                        isStale: false
                    )
                        .monospacedDigit()
                }
            } minimal: {
                Image(
                    systemName: compactIcon(
                        for: context.state,
                        isStale: context.isStale
                    )
                )
            }
            .keylineTint(
                palette(
                    for: context.state,
                    isStale: context.isStale
                ).accent
            )
        }
    }

    // MARK: - Private methods

    @ViewBuilder
    private func countdown(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> some View {
        if isStale {
            Text(Localizations.Activity.staleShort)
        } else if state.isPaused {
            Text(format(seconds: state.pausedRemaining ?? .zero))
        } else if let endDate = state.phaseEndDate {
            Text(
                timerInterval: Date()...endDate,
                countsDown: true
            )
        } else {
            Text(format(seconds: .zero))
        }
    }

    private func title(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> String {
        if isStale { return Localizations.Activity.stale }
        if state.isPaused { return Localizations.Activity.paused }
        switch state.phase {
        case .preparation: return Localizations.Activity.preparation
        case .round: return Localizations.Activity.round
        case .rest: return Localizations.Activity.rest
        }
    }

    private func format(seconds: Int) -> String {
        String(
            format: TechnicalString.timerFormat,
            seconds / .liveActivitySecondsPerMinute,
            seconds % .liveActivitySecondsPerMinute
        )
    }

    private func phaseBadge(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> some View {
        Label {
            Text(
                isStale
                    ? Localizations.Activity.staleShort
                    : title(
                        for: state,
                        isStale: false
                    )
            )
                .font(.caption.weight(.semibold))
        } icon: {
            Image(
                systemName: compactIcon(
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

    private func roundCounter(for state: BoxingTimerActivityAttributes.ContentState) -> some View {
        VStack(
            alignment: .trailing,
            spacing: Margin.x1
        ) {
            Text(Localizations.Activity.round)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(.liveActivitySecondaryTextOpacity))
            Text("\(state.currentRound)\(TechnicalString.slash)\(state.totalRounds)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
    }

    private func compactIcon(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> String {
        if isStale { return SFSymbol.arrowClockwiseCircleFill }
        if state.isPaused { return SFSymbol.pauseCircleFill }
        switch state.phase {
        case .preparation: return SFSymbol.figureCooldown
        case .round: return SFSymbol.figureBoxing
        case .rest: return SFSymbol.heartCircleFill
        }
    }

    private func palette(
        for state: BoxingTimerActivityAttributes.ContentState,
        isStale: Bool
    ) -> (background: [Color], accent: Color) {
        if isStale {
            return (
                [
                    Color(
                        red: .liveActivityStaleBackgroundStartRed,
                        green: .liveActivityStaleBackgroundStartGreen,
                        blue: .liveActivityStaleBackgroundStartBlue
                    ),
                    Color(
                        red: .liveActivityStaleBackgroundEndRed,
                        green: .liveActivityStaleBackgroundEndGreen,
                        blue: .liveActivityStaleBackgroundEndBlue
                    )
                ],
                Color(
                    red: .liveActivityStaleAccentRed,
                    green: .liveActivityStaleAccentGreen,
                    blue: .liveActivityStaleAccentBlue
                )
            )
        }

        switch state.phase {
        case .preparation:
            return (
                [
                    Color(
                        red: .liveActivityPreparationBackgroundRed,
                        green: .liveActivityPreparationBackgroundGreen,
                        blue: .liveActivityPreparationBackgroundBlue
                    ),
                    .black
                ],
                Color(
                    red: .liveActivityPreparationAccentRed,
                    green: .liveActivityPreparationAccentGreen,
                    blue: .liveActivityPreparationAccentBlue
                )
            )
        case .round:
            return (
                [
                    Color(
                        red: .liveActivityRoundBackgroundRed,
                        green: .liveActivityRoundBackgroundGreen,
                        blue: .liveActivityRoundBackgroundBlue
                    ),
                    .black
                ],
                Color(
                    red: .liveActivityRoundAccentRed,
                    green: .liveActivityRoundAccentGreen,
                    blue: .liveActivityRoundAccentBlue
                )
            )
        case .rest:
            return (
                [
                    Color(
                        red: .liveActivityRestBackgroundRed,
                        green: .liveActivityRestBackgroundGreen,
                        blue: .liveActivityRestBackgroundBlue
                    ),
                    .black
                ],
                Color(
                    red: .liveActivityRestAccentRed,
                    green: .liveActivityRestAccentGreen,
                    blue: .liveActivityRestAccentBlue
                )
            )
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let liveActivityContentHeight: CGFloat = 112
    static let liveActivityExpandedFontSize: CGFloat = 42
    static let liveActivityCompactFontSize: CGFloat = 34
}

private extension Double {
    static let liveActivityBadgeOpacity = 0.18
    static let liveActivitySecondaryTextOpacity = 0.7
    static let liveActivityStaleBackgroundStartRed = 0.19
    static let liveActivityStaleBackgroundStartGreen = 0.22
    static let liveActivityStaleBackgroundStartBlue = 0.29
    static let liveActivityStaleBackgroundEndRed = 0.09
    static let liveActivityStaleBackgroundEndGreen = 0.10
    static let liveActivityStaleBackgroundEndBlue = 0.15
    static let liveActivityStaleAccentRed = 1.0
    static let liveActivityStaleAccentGreen = 0.72
    static let liveActivityStaleAccentBlue = 0.33
    static let liveActivityPreparationBackgroundRed = 0.32
    static let liveActivityPreparationBackgroundGreen = 0.22
    static let liveActivityPreparationBackgroundBlue = 0.04
    static let liveActivityPreparationAccentRed = 1.0
    static let liveActivityPreparationAccentGreen = 0.91
    static let liveActivityPreparationAccentBlue = 0.66
    static let liveActivityRoundBackgroundRed = 0.55
    static let liveActivityRoundBackgroundGreen = 0.10
    static let liveActivityRoundBackgroundBlue = 0.04
    static let liveActivityRoundAccentRed = 1.0
    static let liveActivityRoundAccentGreen = 0.78
    static let liveActivityRoundAccentBlue = 0.70
    static let liveActivityRestBackgroundRed = 0.02
    static let liveActivityRestBackgroundGreen = 0.25
    static let liveActivityRestBackgroundBlue = 0.30
    static let liveActivityRestAccentRed = 0.72
    static let liveActivityRestAccentGreen = 0.94
    static let liveActivityRestAccentBlue = 0.96
}

private extension Int {
    static let liveActivitySecondsPerMinute = 60
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview("Preparation", as: .content, using: BoxingTimerActivityAttributes(sessionID: UUID())) {
    BoxingTimerLiveActivityWidget()
} contentStates: {
    BoxingTimerActivityAttributes.ContentState(
        phase: .preparation,
        currentRound: 1,
        totalRounds: 3,
        phaseEndDate: .now.addingTimeInterval(5),
        pausedRemaining: nil,
        isPaused: false
    )
}

#Preview("Paused", as: .content, using: BoxingTimerActivityAttributes(sessionID: UUID())) {
    BoxingTimerLiveActivityWidget()
} contentStates: {
    BoxingTimerActivityAttributes.ContentState(
        phase: .round,
        currentRound: 1,
        totalRounds: 3,
        phaseEndDate: nil,
        pausedRemaining: 65,
        isPaused: true
    )
}
#endif
