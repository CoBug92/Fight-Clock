import XCTest
@testable import Main

@MainActor
final class RootViewModelTests: XCTestCase {
    // MARK: - Configuration

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

    func testLaunchHidesNotificationPermissionCardWhenPermissionIsAllowed() async {
        let fixture = Fixture()
        fixture.notificationScheduler.currentPermission = .allowed

        await fixture.viewModel.launch(sceneIsActive: false)

        XCTAssertNil(fixture.viewModel.notificationPermissionCard)
    }

    func testLaunchShowsNotificationPermissionCardWhenPermissionIsNotAllowed() async {
        let fixture = Fixture()
        fixture.notificationScheduler.currentPermission = .denied

        await fixture.viewModel.launch(sceneIsActive: false)

        XCTAssertNotNil(fixture.viewModel.notificationPermissionCard)
    }

    func testDeniedNotificationPermissionOpensAppSettings() async {
        let fixture = Fixture()
        fixture.notificationScheduler.currentPermission = .denied

        await fixture.viewModel.launch(sceneIsActive: false)
        await fixture.viewModel.performNotificationPermissionCardAction()

        XCTAssertEqual(fixture.appSettingsOpener.openCallCount, 1)
    }

    // MARK: - Session lifecycle

    func testWarningPlaysOnceWhenThresholdIsCrossed() async throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let configuration = TimerConfiguration(
            roundCount: 1,
            roundDuration: 60,
            restDuration: .zero,
            roundWarning: .tenSeconds
        )
        let state = try XCTUnwrap(SessionEngine().start(configuration: configuration, at: start))
        let fixture = Fixture(initialSession: state, date: start)
        await fixture.viewModel.setSceneActive(true)

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
        await fixture.viewModel.setSceneActive(true)

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
        await fixture.viewModel.setSceneActive(true)
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
        await fixture.viewModel.setSceneActive(true)

        await fixture.viewModel.togglePause()

        XCTAssertNil(fixture.viewModel.session)
        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        let endedSessionIDs = await fixture.liveActivityController.endedSessionIDs
        XCTAssertEqual(endedSessionIDs, [initial.id])
    }

    // MARK: - Concurrent operations

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
        await fixture.viewModel.launch(sceneIsActive: true)
        await fixture.viewModel.setSceneActive(false)

        fixture.dateProvider.value = start.addingTimeInterval(10)
        try await Task.sleep(for: .milliseconds(300))

        XCTAssertTrue(fixture.signalPlayer.playRequests.isEmpty)
        await fixture.viewModel.stop()
    }
}
