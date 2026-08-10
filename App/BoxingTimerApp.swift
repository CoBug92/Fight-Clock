import SwiftUI

@main
struct BoxingTimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = AppDependencies().makeTimerViewModel()

    var body: some Scene {
        WindowGroup {
            TimerRootView(viewModel: viewModel)
                .task {
                    if scenePhase == .active { await viewModel.sceneBecameActive() }
                    await viewModel.launch()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                Task { await viewModel.sceneBecameActive() }
            case .inactive, .background:
                viewModel.sceneBecameInactive()
            @unknown default:
                break
            }
        }
    }
}
