import XCTest
@testable import Main

@MainActor
final class SoundSettingsViewModelTests: XCTestCase {
    // MARK: - Sound configuration

    func testPartialUpdatePreservesUnchangedSounds() {
        let fixture = Fixture()
        let initial = fixture.soundSettingsViewModel.soundConfiguration

        fixture.soundSettingsViewModel.update(roundStartSound: .brightBell)

        XCTAssertEqual(fixture.soundSettingsViewModel.soundConfiguration.roundStartSound, .brightBell)
        XCTAssertEqual(
            fixture.soundSettingsViewModel.soundConfiguration.roundTransitionSound,
            initial.roundTransitionSound
        )
        XCTAssertEqual(fixture.soundSettingsViewModel.soundConfiguration.warningSound, initial.warningSound)
        XCTAssertEqual(fixture.configurationRepository.value.soundConfiguration, fixture.soundSettingsViewModel.soundConfiguration)
    }

    func testPreviewDelegatesToSignalPlayer() {
        let fixture = Fixture()

        fixture.soundSettingsViewModel.preview(.tripleGong)

        XCTAssertEqual(fixture.signalPlayer.previewedSounds, [.tripleGong])
    }
}
