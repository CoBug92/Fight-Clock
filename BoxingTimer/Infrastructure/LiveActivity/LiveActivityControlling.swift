import Foundation

/// Синхронизирует системную Live Activity с текущей сессией.
protocol LiveActivityControlling: Sendable {
    /// Создаёт Activity, если системная политика это разрешает.
    func start(for state: SessionState) async

    /// Обновляет отображаемое состояние всех Activity приложения.
    func update(for state: SessionState) async

    /// Завершает все Activity приложения и удаляет их системное представление.
    func end() async

    /// Завершает Activity только указанной сессии.
    func end(sessionID: UUID) async
}
