import XCTest
@testable import BoxingTimer

final class SessionSoundResolverTests: XCTestCase {
    private let resolver = SessionSoundResolver()

    func testResolverMapsSignalsToConfiguredSlots() {
        let configuration = TimerConfiguration(
            roundCount: 3,
            roundDuration: 180,
            restDuration: 60,
            soundConfiguration: TimerSoundConfiguration(
                roundStartSound: .brightBell,
                roundTransitionSound: .singleGong,
                warningSound: .rhythmicPattern
            )
        )

        XCTAssertEqual(
            resolver.sound(for: .roundStarted, configuration: configuration),
            .brightBell
        )
        XCTAssertEqual(
            resolver.sound(for: .roundEnding(seconds: 10), configuration: configuration),
            .rhythmicPattern
        )
        XCTAssertEqual(
            resolver.sound(for: .restStarted, configuration: configuration),
            .singleGong
        )
        XCTAssertEqual(
            resolver.sound(for: .workoutCompleted, configuration: configuration),
            .singleGong
        )
    }

    func testResolverExposesExpectedBundledFileNames() {
        let configuration = TimerConfiguration(
            roundCount: 3,
            roundDuration: 180,
            restDuration: 60,
            soundConfiguration: TimerSoundConfiguration(
                roundStartSound: .singleGong,
                roundTransitionSound: .brightBell,
                warningSound: .clickQuartetRhythm
            )
        )

        XCTAssertEqual(
            resolver.notificationSoundName(for: .roundStarted, configuration: configuration),
            "placeholder_round.wav"
        )
        XCTAssertEqual(
            resolver.notificationSoundName(for: .roundEnding(seconds: 30), configuration: configuration),
            "placeholder_bright.wav"
        )
        XCTAssertEqual(
            resolver.notificationSoundName(for: .workoutCompleted, configuration: configuration),
            "placeholder_bright.wav"
        )
    }

    func testResolverFallsBackToSupportedNotificationSoundsForMP3BackedSelections() {
        let configuration = TimerConfiguration(
            roundCount: 3,
            roundDuration: 180,
            restDuration: 60,
            soundConfiguration: TimerSoundConfiguration(
                roundStartSound: .bongoDrumTrill,
                roundTransitionSound: .rhythmicPattern,
                warningSound: .clickQuartetRhythm
            )
        )

        XCTAssertEqual(
            resolver.notificationSoundName(for: .roundStarted, configuration: configuration),
            "placeholder_round.wav"
        )
        XCTAssertEqual(
            resolver.notificationSoundName(for: .roundEnding(seconds: 10), configuration: configuration),
            "placeholder_bright.wav"
        )
        XCTAssertEqual(
            resolver.notificationSoundName(for: .workoutCompleted, configuration: configuration),
            "placeholder_complete.wav"
        )
    }
}
