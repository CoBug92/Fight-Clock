import Combine
import Foundation

@MainActor
final class SetupViewModel: ObservableObject {
    // MARK: - Observable properties

    @Published private(set) var notificationPermission: NotificationPermission = .notDetermined

    // MARK: - Properties

    private let configurationController: TimerConfigurationController
    private let sessionController: WorkoutSessionController
    private let notificationScheduler: NotificationScheduling
    private let appSettingsOpener: AppSettingsOpening
    private let analyticsTracker: AnalyticsTracking
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        configurationController: TimerConfigurationController,
        sessionController: WorkoutSessionController,
        notificationScheduler: NotificationScheduling,
        appSettingsOpener: AppSettingsOpening,
        analyticsTracker: AnalyticsTracking
    ) {
        self.configurationController = configurationController
        self.sessionController = sessionController
        self.notificationScheduler = notificationScheduler
        self.appSettingsOpener = appSettingsOpener
        self.analyticsTracker = analyticsTracker
        configurationController.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Computed properties

    var configuration: TimerConfiguration { configurationController.configuration }
    var roundCount: Int { configuration.roundCount }
    var roundDuration: Int { configuration.roundDuration }
    var restDuration: Int { configuration.restDuration }
    var preparationDuration: Int { configuration.preparationDuration }
    var roundWarning: RoundWarning { configuration.roundWarning }
    var notificationPermissionCard: NotificationPermissionCardViewData? {
        switch notificationPermission {
        case .notDetermined:
            NotificationPermissionCardViewData(
                explanation: Localizations.Permission.explanation,
                action: .button(title: Localizations.Permission.allow)
            )
        case .allowed: nil
        case .denied: NotificationPermissionCardViewData(explanation: Localizations.Permission.deniedExplanation, action: .cardTap)
        }
    }

    // MARK: - Public methods

    func refreshNotificationPermission() async {
        notificationPermission = await notificationScheduler.permission()
    }

    func update(
        roundCount: Int? = nil,
        roundDuration: Int? = nil,
        restDuration: Int? = nil,
        preparationDuration: Int? = nil,
        roundWarning: RoundWarning? = nil
    ) {
        guard sessionController.session == nil else { return }
        configurationController.update(
            roundCount: roundCount,
            roundDuration: roundDuration,
            restDuration: restDuration,
            preparationDuration: preparationDuration,
            roundWarning: roundWarning
        )
    }

    func performNotificationPermissionCardAction() async {
        switch notificationPermission {
        case .notDetermined:
            notificationPermission = await notificationScheduler.requestPermission()
            analyticsTracker.track(.notificationPermissionUpdated(notificationPermission))
        case .allowed: break
        case .denied: appSettingsOpener.openAppSettings()
        }
    }

    func start() async {
        await sessionController.start(configuration: configurationController.configuration)
    }
}
