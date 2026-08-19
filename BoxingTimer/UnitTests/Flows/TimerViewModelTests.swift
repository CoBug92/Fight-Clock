import XCTest
@testable import BoxingTimer

@MainActor
final class TimerViewModelTests: XCTestCase {
    func testUpdatePersistsValidConfiguration() {
        let fixture = Fixture()

        fixture.viewModel.update(
            roundCount: 4,
            roundDuration: 150,
            restDuration: 75,
            preparationDuration: 25,
            roundWarning: .thirtySeconds
        )

        XCTAssertEqual(
            fixture.configurationRepository.value,
            TimerConfiguration(
                roundCount: 4,
                roundDuration: 150,
                restDuration: 75,
                preparationDuration: 25,
                roundWarning: .thirtySeconds
            )
        )
    }

    func testSoundUpdatePersistsConfiguration() {
        let fixture = Fixture()

        fixture.viewModel.update(
            roundStartSound: .brightBell,
            roundTransitionSound: .tripleGong,
            warningSound: .rhythmicPattern
        )

        XCTAssertEqual(
            fixture.configurationRepository.value.soundConfiguration,
            TimerSoundConfiguration(
                roundStartSound: .brightBell,
                roundTransitionSound: .tripleGong,
                warningSound: .rhythmicPattern
            )
        )
    }

    func testPreviewDelegatesToSignalPlayer() {
        let fixture = Fixture()

        fixture.viewModel.preview(.brightBell)

        XCTAssertEqual(fixture.signalPlayer.previewedSounds, [.brightBell])
    }

    func testWarningPlaysOnceWhenThresholdIsCrossed() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(
            roundCount: 1,
            roundDuration: 60,
            restDuration: 0,
            roundWarning: .tenSeconds
        )
        let state = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: state, date: start)
        await fixture.viewModel.sceneBecameActive()

        fixture.dateProvider.value = start.addingTimeInterval(50)
        try await Task.sleep(for: .milliseconds(300))
        fixture.dateProvider.value = start.addingTimeInterval(51)
        try await Task.sleep(for: .milliseconds(300))

        XCTAssertEqual(
            fixture.signalPlayer.playRequests,
            [.init(signal: .roundEnding(seconds: 10), configuration: configuration)]
        )
        await fixture.viewModel.stop()
    }

    func testStartCreatesSessionAndSideEffectsWhenSceneIsActive() async {
        let fixture = Fixture()
        await fixture.viewModel.sceneBecameActive()

        await fixture.viewModel.start()

        XCTAssertNotNil(fixture.sessionRepository.value)
        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        XCTAssertEqual(fixture.notificationScheduler.scheduledStates.count, 1)
        let startedStates = await fixture.liveActivityController.startedStates
        XCTAssertEqual(startedStates.count, 1)
        XCTAssertTrue(fixture.idleTimerController.isDisabled)
    }

    func testStartDoesNotPlaySignalWhileSceneIsInactive() async {
        let fixture = Fixture()

        await fixture.viewModel.start()

        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
    }

    func testStopClearsSessionWithoutCompletionSignal() async {
        let fixture = Fixture()
        await fixture.viewModel.sceneBecameActive()
        await fixture.viewModel.start()

        await fixture.viewModel.stop()

        XCTAssertNil(fixture.sessionRepository.value)
        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        let endedSessionIDs = await fixture.liveActivityController.endedSessionIDs
        XCTAssertEqual(endedSessionIDs.count, 1)
        XCTAssertFalse(fixture.idleTimerController.isDisabled)
    }

    func testPauseResolvesExpiredBoundaryBeforePausing() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(roundCount: 2, roundDuration: 10, restDuration: 5)
        let initial = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: initial, date: start.addingTimeInterval(11))

        await fixture.viewModel.togglePause()

        let paused = try XCTUnwrap(fixture.viewModel.session)
        XCTAssertTrue(paused.isPaused)
        XCTAssertEqual(paused.phase, .rest)
        XCTAssertEqual(paused.currentRound, 1)
        XCTAssertEqual(paused.pausedRemaining, 4)
    }

    func testPauseAfterExpiredFinalRoundCompletesSession() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(roundCount: 1, roundDuration: 10, restDuration: 5)
        let initial = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: initial, date: start.addingTimeInterval(11))
        await fixture.viewModel.sceneBecameActive()

        await fixture.viewModel.togglePause()

        XCTAssertNil(fixture.viewModel.session)
        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        let endedSessionIDs = await fixture.liveActivityController.endedSessionIDs
        XCTAssertEqual(endedSessionIDs, [initial.id])
    }

    func testStopDuringSuspendedStartRemovesStaleSideEffects() async {
        let fixture = Fixture()
        fixture.notificationScheduler.shouldSuspendNextSchedule = true

        let startTask = Task { await fixture.viewModel.start() }
        await fixture.notificationScheduler.waitUntilSuspended()
        await fixture.viewModel.stop()
        fixture.notificationScheduler.resumeScheduling()
        await startTask.value

        XCTAssertNil(fixture.viewModel.session)
        XCTAssertTrue(fixture.notificationScheduler.activeRevisions.isEmpty)
        let startedStates = await fixture.liveActivityController.startedStates
        XCTAssertTrue(startedStates.isEmpty)
    }

    func testPauseDuringSuspendedResumeDoesNotRestoreStaleNotifications() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let running = try XCTUnwrap(SessionEngine().start(configuration: .defaultValue, at: start))
        let paused = SessionEngine().pause(running, at: start.addingTimeInterval(20))
        let fixture = Fixture(initialSession: paused, date: start.addingTimeInterval(30))
        fixture.notificationScheduler.shouldSuspendNextSchedule = true

        let resumeTask = Task { await fixture.viewModel.togglePause() }
        await fixture.notificationScheduler.waitUntilSuspended()
        await fixture.viewModel.togglePause()
        fixture.notificationScheduler.resumeScheduling()
        await resumeTask.value

        XCTAssertEqual(fixture.viewModel.session?.isPaused, true)
        XCTAssertTrue(fixture.notificationScheduler.activeRevisions.isEmpty)
        let updatedStates = await fixture.liveActivityController.updatedStates
        XCTAssertEqual(updatedStates.last?.isPaused, true)
    }

    func testBoundaryDoesNotPlaySignalAfterSceneBecomesInactive() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(roundCount: 2, roundDuration: 10, restDuration: 5)
        let state = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: state, date: start)
        await fixture.viewModel.launch()
        fixture.viewModel.sceneBecameInactive()

        fixture.dateProvider.value = start.addingTimeInterval(10)
        try await Task.sleep(for: .milliseconds(300))

        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        await fixture.viewModel.stop()
    }

}

@MainActor
private final class Fixture {
    let configurationRepository = ConfigurationRepositoryFake()
    let sessionRepository = SessionRepositoryFake()
    let notificationScheduler = NotificationSchedulerSpy()
    let signalPlayer = SignalPlayerSpy()
    let liveActivityController = LiveActivityControllerSpy()
    let idleTimerController = IdleTimerControllerSpy()
    let dateProvider: DateProviderFake
    let viewModel: TimerViewModel

    init(initialSession: SessionState? = nil, date: Date = Date(timeIntervalSince1970: 1_000)) {
        dateProvider = DateProviderFake(value: date)
        sessionRepository.value = initialSession
        viewModel = TimerViewModel(
            configurationRepository: configurationRepository,
            sessionRepository: sessionRepository,
            notificationScheduler: notificationScheduler,
            signalPlayer: signalPlayer,
            liveActivityController: liveActivityController,
            idleTimerController: idleTimerController,
            dateProvider: dateProvider
        )
    }
}

private final class ConfigurationRepositoryFake: ConfigurationRepository, @unchecked Sendable {
    var value = TimerConfiguration.defaultValue
    func load() -> TimerConfiguration { value }
    func save(_ configuration: TimerConfiguration) { value = configuration }
}

private final class SessionRepositoryFake: SessionRepository, @unchecked Sendable {
    var value: SessionState?
    func load() -> SessionState? { value }
    func save(_ state: SessionState) { value = state }
    func clear() { value = nil }
}

@MainActor
private final class NotificationSchedulerSpy: NotificationScheduling {
    var shouldSuspendNextSchedule = false
    private(set) var scheduledStates: [SessionState] = []
    private(set) var activeRevisions: Set<UUID> = []
    private var scheduleContinuation: CheckedContinuation<Void, Never>?

    func permission() async -> NotificationPermission { .allowed }
    func requestPermission() async -> NotificationPermission { .allowed }

    func schedule(for state: SessionState, now: Date) async {
        scheduledStates.append(state)
        if shouldSuspendNextSchedule {
            shouldSuspendNextSchedule = false
            await withCheckedContinuation { scheduleContinuation = $0 }
        }
        activeRevisions.insert(state.notificationRevision)
    }

    func cancelAll() {
        activeRevisions.removeAll()
    }

    func cancel(for state: SessionState) {
        activeRevisions.remove(state.notificationRevision)
    }

    func waitUntilSuspended() async {
        while scheduleContinuation == nil { await Task.yield() }
    }

    func resumeScheduling() {
        scheduleContinuation?.resume()
        scheduleContinuation = nil
    }
}

@MainActor
private final class SignalPlayerSpy: SignalPlaying {
    struct PlayRequest: Equatable {
        let signal: SessionSignal
        let configuration: TimerConfiguration
    }

    var playRequests: [PlayRequest] = []
    var previewedSounds: [BundledTimerSound] = []

    func play(_ signal: SessionSignal, configuration: TimerConfiguration) {
        playRequests.append(PlayRequest(signal: signal, configuration: configuration))
    }

    func preview(_ sound: BundledTimerSound) {
        previewedSounds.append(sound)
    }
}

private actor LiveActivityControllerSpy: LiveActivityControlling {
    private(set) var startedStates: [SessionState] = []
    private(set) var updatedStates: [SessionState] = []
    private(set) var endedSessionIDs: [UUID] = []

    func start(for state: SessionState) async { startedStates.append(state) }
    func update(for state: SessionState) async { updatedStates.append(state) }
    func end() async {}
    func end(sessionID: UUID) async { endedSessionIDs.append(sessionID) }
}

@MainActor
private final class IdleTimerControllerSpy: IdleTimerControlling {
    var isDisabled = false
    func setDisabled(_ isDisabled: Bool) { self.isDisabled = isDisabled }
}

private final class DateProviderFake: DateProviding, @unchecked Sendable {
    var value: Date
    init(value: Date) { self.value = value }
    func now() -> Date { value }
}
