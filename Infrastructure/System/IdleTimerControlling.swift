/// Управляет системной автоблокировкой только на время активной сессии.
@MainActor
protocol IdleTimerControlling: AnyObject {
    /// Включает или выключает запрет автоблокировки экрана.
    func setDisabled(_ isDisabled: Bool)
}
