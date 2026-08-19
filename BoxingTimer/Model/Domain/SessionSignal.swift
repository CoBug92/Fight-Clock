enum SessionSignal: Equatable, Sendable {
    case roundStarted
    case roundEnding(seconds: Int)
    case restStarted
    case workoutCompleted
}
