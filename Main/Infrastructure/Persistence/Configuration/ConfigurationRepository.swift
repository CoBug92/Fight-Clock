import Foundation

/// Сохраняет последнюю валидную конфигурацию таймера локально.
protocol ConfigurationRepository: Sendable {
    /// Загружает сохранённую конфигурацию либо значения по умолчанию.
    func load() -> TimerConfiguration

    /// Сохраняет конфигурацию, если она валидна.
    func save(_ configuration: TimerConfiguration)
}
