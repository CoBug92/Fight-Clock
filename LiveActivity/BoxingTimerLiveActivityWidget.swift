import ActivityKit
import SwiftUI
import WidgetKit

struct BoxingTimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BoxingTimerActivityAttributes.self) { context in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title(for: context.state, isStale: context.isStale))
                        .font(.headline.bold())
                    Text("\(context.state.currentRound)/\(context.state.totalRounds)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                countdown(for: context.state, isStale: context.isStale)
                    .font(.title.bold().monospacedDigit())
                action(for: context.state, isStale: context.isStale)
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.86))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(title(for: context.state, isStale: context.isStale)).font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdown(for: context.state, isStale: context.isStale).monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("\(context.state.currentRound)/\(context.state.totalRounds)")
                        Spacer()
                        action(for: context.state, isStale: context.isStale)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.phase == .round ? "figure.boxing" : "drop.fill")
            } compactTrailing: {
                if context.isStale {
                    Image(systemName: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                } else {
                    countdown(for: context.state, isStale: false).monospacedDigit()
                }
            } minimal: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
            }
            .keylineTint(context.state.phase == .round ? .orange : .cyan)
        }
    }

    @ViewBuilder
    private func countdown(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> some View {
        if isStale {
            Text(Localizations.Activity.staleShort)
        } else if state.isPaused {
            Text(format(seconds: state.pausedRemaining ?? 0))
        } else if let endDate = state.phaseEndDate {
            Text(timerInterval: Date()...endDate, countsDown: true)
        } else {
            Text("0:00")
        }
    }

    @ViewBuilder
    private func action(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> some View {
        if isStale {
            Button(intent: OpenBoxingTimerIntent()) {
                Label(Localizations.Activity.openApp, systemImage: "arrow.up.forward.app")
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        } else if state.isPaused {
            Button(intent: ResumeSessionIntent()) { Image(systemName: "play.fill") }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
        } else {
            Button(intent: PauseSessionIntent()) { Image(systemName: "pause.fill") }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
        }
    }

    private func title(for state: BoxingTimerActivityAttributes.ContentState, isStale: Bool) -> String {
        if isStale { return Localizations.Activity.stale }
        if state.isPaused { return Localizations.Activity.paused }
        return state.phase == .round ? Localizations.Activity.round : Localizations.Activity.rest
    }

    private func format(seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
