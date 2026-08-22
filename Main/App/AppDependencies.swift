import Foundation

@MainActor
struct AppDependencies {
    func makeRootViewModel() -> RootViewModel {
        RootViewModel(
            configurationRepository: UserDefaultsConfigurationRepository(),
            sessionRepository: UserDefaultsSessionRepository(),
            notificationScheduler: NotificationScheduler(),
            signalPlayer: ForegroundSignalPlayer(),
            liveActivityController: LiveActivityController(),
            idleTimerController: IdleTimerController(),
            appSettingsOpener: AppSettingsOpener(),
            dateProvider: SystemDateProvider()
        )
    }
}
