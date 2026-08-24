/// Отправляет продуктовые события в подключённый сервис аналитики.
@MainActor
protocol AnalyticsTracking {
    /// Регистрирует одно пользовательское событие без идентификатора, создаваемого приложением.
    ///
    /// - Parameter event: Событие жизненного цикла тренировки или разрешения.
    func track(_ event: AnalyticsEvent)
}

enum AnalyticsEvent: Equatable, Sendable {
    /// Пользователь начал тренировку с указанной конфигурацией.
    case workoutStarted(TimerConfiguration)
    /// Пользователь приостановил активную тренировку.
    case workoutPaused(SessionState)
    /// Пользователь продолжил ранее приостановленную тренировку.
    case workoutResumed(SessionState)
    /// Пользователь досрочно завершил активную тренировку.
    case workoutStopped(SessionState)
    /// Тренировка завершилась после последнего раунда.
    case workoutCompleted(SessionState)
    /// Пользователь получил результат системного запроса разрешения на уведомления.
    case notificationPermissionUpdated(NotificationPermission)
}
