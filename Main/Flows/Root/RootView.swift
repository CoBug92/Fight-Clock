import SwiftUI

struct RootView: View {
    // MARK: - Observable properties

    @ObservedObject var viewModel: RootViewModel
    @State private var showsLaunchOverlay = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Layout

    var body: some View {
        ZStack {
            Group {
                if viewModel.session == nil {
                    NavigationStack {
                        SetupView(
                            viewModel: viewModel.setupViewModel,
                            soundSettingsViewModel: viewModel.soundSettingsViewModel,
                            didCompleteWorkout: viewModel.didCompleteWorkout
                        )
                    }
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: .rootSetupTransitionScale)))
                } else {
                    ActiveTimerView(viewModel: viewModel.activeTimerViewModel)
                        .transition(reduceMotion ? .identity : .opacity)
                }
            }
            .accessibilityHidden(isShowingLaunchOverlay)

            if isShowingLaunchOverlay {
                AppLaunchOverlayView()
                    .transition(reduceMotion ? .identity : .opacity)
                    .zIndex(.rootOverlayZIndex)
            }
        }
        .task {
            guard showsLaunchOverlay else { return }
            do {
                try await Task.sleep(for: AppLaunchOverlayView.displayDuration)
            } catch {
                return
            }
            withAnimation(reduceMotion ? nil : .easeOut(duration: .rootLaunchOverlayFadeDuration)) {
                showsLaunchOverlay = false
            }
        }
        .animation(
            reduceMotion ? nil : .easeOut(duration: .rootSessionTransitionDuration),
            value: viewModel.session == nil
        )
        .onChange(of: viewModel.didCompleteWorkout) { _, didCompleteWorkout in
            guard didCompleteWorkout, voiceOverEnabled, scenePhase == .active else { return }
            AccessibilityNotification.Announcement(Localizations.Notification.complete).post()
        }
    }

    private var isShowingLaunchOverlay: Bool { showsLaunchOverlay && !voiceOverEnabled }
}

// MARK: - Constants

private extension CGFloat {
    static let rootSetupTransitionScale = 0.98
}

private extension Double {
    static let rootOverlayZIndex: Double = 1
    static let rootLaunchOverlayFadeDuration = 0.45
    static let rootSessionTransitionDuration = 0.25
}

// MARK: - Preview

#if DEBUG && targetEnvironment(simulator)
#Preview {
    RootView(viewModel: AppDependencies().makeRootViewModel())
}
#endif
