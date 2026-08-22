import SwiftUI

@main
struct BoxingTimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = AppDependencies().makeRootViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
                .task {
                    await viewModel.launch(sceneIsActive: scenePhase == .active)
                }
        }
        .onChange(of: scenePhase) { _, phase in
            Task { await viewModel.setSceneActive(phase == .active) }
        }
    }
}
