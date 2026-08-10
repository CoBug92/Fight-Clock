import SwiftUI

struct TimerRootView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        Group {
            if viewModel.session == nil {
                SetupView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                ActiveTimerView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.25), value: viewModel.session == nil)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    TimerRootView(viewModel: AppDependencies().makeTimerViewModel())
}
