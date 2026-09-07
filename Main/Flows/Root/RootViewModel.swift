import Combine
import Foundation

@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Observable properties

    @Published private(set) var session: SessionState?

    // MARK: - Properties

    let setupViewModel: SetupViewModel
    let soundSettingsViewModel: SoundSettingsViewModel
    let activeTimerViewModel: ActiveTimerViewModel

    private let sessionController: WorkoutSessionController

    // MARK: - Init

    init(
        sessionController: WorkoutSessionController,
        setupViewModel: SetupViewModel,
        soundSettingsViewModel: SoundSettingsViewModel,
        activeTimerViewModel: ActiveTimerViewModel
    ) {
        self.sessionController = sessionController
        self.setupViewModel = setupViewModel
        self.soundSettingsViewModel = soundSettingsViewModel
        self.activeTimerViewModel = activeTimerViewModel
        session = sessionController.session
        sessionController.$session.assign(to: &$session)
    }

    // MARK: - Public methods

    func launch(sceneIsActive: Bool) async {
        await setupViewModel.refreshNotificationPermission()
        await sessionController.launch(sceneIsActive: sceneIsActive)
    }

    func setSceneActive(_ isActive: Bool) async { await sessionController.setSceneActive(isActive) }
}
