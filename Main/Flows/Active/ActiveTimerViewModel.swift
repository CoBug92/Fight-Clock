import Foundation

@MainActor
final class ActiveTimerViewModel: ObservableObject {
    // MARK: - Observable properties

    @Published private(set) var session: SessionState?
    @Published private(set) var remainingSeconds: Int = .zero

    // MARK: - Properties

    private let sessionController: WorkoutSessionController

    // MARK: - Init

    init(sessionController: WorkoutSessionController) {
        self.sessionController = sessionController
        session = sessionController.session
        remainingSeconds = sessionController.remainingSeconds
        sessionController.$session.assign(to: &$session)
        sessionController.$remainingSeconds.assign(to: &$remainingSeconds)
    }

    // MARK: - Public methods

    func togglePause() async { await sessionController.togglePause() }
    func stop() async { await sessionController.stop() }
}
