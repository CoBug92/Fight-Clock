import Foundation

@MainActor
struct AppDependencies {
    func makeTimerViewModel() -> TimerViewModel {
        TimerViewModel(
            configurationRepository: UserDefaultsConfigurationRepository(),
            sessionRepository: UserDefaultsSessionRepository(),
            notificationScheduler: NotificationScheduler(),
            signalPlayer: ForegroundSignalPlayer(),
            liveActivityController: LiveActivityController(),
            idleTimerController: IdleTimerController(),
            dateProvider: SystemDateProvider()
        )
    }
}
