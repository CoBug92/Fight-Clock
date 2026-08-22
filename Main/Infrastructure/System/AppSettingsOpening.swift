/// Открывает системные настройки текущего приложения.
@MainActor
protocol AppSettingsOpening: AnyObject {
    /// Запрашивает открытие системного экрана настроек текущего приложения.
    func openAppSettings()
}
