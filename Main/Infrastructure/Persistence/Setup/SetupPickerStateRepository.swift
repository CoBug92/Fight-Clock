import Foundation

/// Хранит последнее выбранное состояние раскрывающихся настроек экрана подготовки.
protocol SetupPickerStateRepository: Sendable {
    /// Загружает состояние пикеров, используя значения по умолчанию при отсутствии сохранённых данных.
    func load() -> SetupPickerState

    /// Сохраняет состояние пикеров для следующего открытия экрана подготовки.
    func save(_ state: SetupPickerState)
}
