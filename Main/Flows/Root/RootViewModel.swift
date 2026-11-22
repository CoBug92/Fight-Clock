import Combine
import Foundation

@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Observable properties

    @Published private(set) var session: SessionState?
    @Published private(set) var didCompleteWorkout: Bool

    // MARK: - Properties

    let setupViewModel: SetupViewModel
    let soundSettingsViewModel: SoundSettingsViewModel
    let activeTimerViewModel: ActiveTimerViewModel

    private let sessionController: WorkoutSessionController
    private var reportedSceneIsActive: Bool?

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
        didCompleteWorkout = sessionController.didCompleteWorkout
        sessionController.$session.assign(to: &$session)
        sessionController.$didCompleteWorkout.assign(to: &$didCompleteWorkout)
    }

    // MARK: - Public methods

    func launch(sceneIsActive: Bool) async {
        await setupViewModel.refreshNotificationPermission()
        await sessionController.launch(sceneIsActive: reportedSceneIsActive ?? sceneIsActive)
    }

    func setSceneActive(_ isActive: Bool) async {
        reportedSceneIsActive = isActive
        await sessionController.setSceneActive(isActive)
    }
}
