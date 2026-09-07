import Foundation

@MainActor
struct AppDependencies {
    func makeRootViewModel() -> RootViewModel {
        let configurationController = TimerConfigurationController(repository: UserDefaultsConfigurationRepository())
        let notificationScheduler = NotificationScheduler()
        let signalPlayer = ForegroundSignalPlayer()
        let sessionController = WorkoutSessionController(
            sessionRepository: UserDefaultsSessionRepository(),
            notificationScheduler: notificationScheduler,
            signalPlayer: signalPlayer,
            liveActivityController: LiveActivityController(),
            idleTimerController: IdleTimerController(),
            dateProvider: SystemDateProvider(),
            analyticsTracker: FirebaseAnalyticsTracker()
        )
        let setupViewModel = SetupViewModel(
            configurationController: configurationController,
            sessionController: sessionController,
            notificationScheduler: notificationScheduler,
            appSettingsOpener: AppSettingsOpener(),
            analyticsTracker: FirebaseAnalyticsTracker()
        )
        return RootViewModel(
            sessionController: sessionController,
            setupViewModel: setupViewModel,
            soundSettingsViewModel: SoundSettingsViewModel(configurationController: configurationController, signalPlayer: signalPlayer),
            activeTimerViewModel: ActiveTimerViewModel(sessionController: sessionController)
        )
    }
}
