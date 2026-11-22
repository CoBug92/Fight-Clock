import SwiftUI

struct RootView: View {
    // MARK: - Observable properties

    @ObservedObject var viewModel: RootViewModel
    @State private var showsLaunchOverlay = true

    // MARK: - Layout

    var body: some View {
        ZStack {
            Group {
                if viewModel.session == nil {
                    NavigationStack {
                        SetupView(viewModel: viewModel.setupViewModel, soundSettingsViewModel: viewModel.soundSettingsViewModel)
                    }
                        .transition(.opacity.combined(with: .scale(.rootSetupTransitionScale)))
                } else {
                    ActiveTimerView(viewModel: viewModel.activeTimerViewModel)
                        .transition(.opacity)
                }
            }

            if showsLaunchOverlay {
                AppLaunchOverlayView()
                    .transition(.opacity)
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
            withAnimation(.easeOut(duration: .rootLaunchOverlayFadeDuration)) {
                showsLaunchOverlay = false
            }
        }
        .animation(
            .easeOut(duration: .rootSessionTransitionDuration),
            value: viewModel.session == nil
        )
    }
}

// MARK: - Constants

private extension Double {
    static let rootSetupTransitionScale = 0.98
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
