/// Воспроизводит различимый короткий сигнал, пока приложение активно.
@MainActor
protocol SignalPlaying: AnyObject {
    /// Воспроизводит соответствующий границе сессии звук без блокировки UI.
    func play(_ signal: SessionSignal)
}
