import Foundation

/// Управляет разрешением и будущими системными сигналами границ сессии.
@MainActor
protocol NotificationScheduling: AnyObject {
    /// Возвращает текущий статус разрешения без показа системного диалога.
    func permission() async -> NotificationPermission

    /// Запрашивает alert и sound; отказ не считается ошибкой запуска таймера.
    func requestPermission() async -> NotificationPermission

    /// Заменяет все будущие уведомления текущей сессии.
    func schedule(for state: SessionState, now: Date) async

    /// Удаляет все будущие уведомления Fight Clock.
    func cancelAll()

    /// Удаляет уведомления только указанной ревизии временной линии.
    func cancel(for state: SessionState)
}
