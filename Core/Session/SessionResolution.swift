struct SessionResolution: Equatable, Sendable {
    let state: SessionState?
    let signals: [SessionSignal]

    var isCompleted: Bool { state == nil }
}
