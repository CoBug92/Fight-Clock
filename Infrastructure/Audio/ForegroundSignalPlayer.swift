import AVFAudio
import Foundation

@MainActor
final class ForegroundSignalPlayer: NSObject, SignalPlaying {
    private var player: AVAudioPlayer?
    private let soundResolver: SessionSoundResolver

    init(soundResolver: SessionSoundResolver = SessionSoundResolver()) {
        self.soundResolver = soundResolver
    }

    func play(_ signal: SessionSignal, configuration: TimerConfiguration) {
        play(resourceName: soundResolver.resourceName(for: signal, configuration: configuration))
    }

    func preview(_ sound: BundledTimerSound) {
        play(sound: sound)
    }

    private func play(resourceName: String) {
        guard let sound = BundledTimerSound.allCases.first(where: { $0.resourceName == resourceName }) else { return }
        play(sound: sound)
    }

    private func play(sound: BundledTimerSound) {
        guard let url = Bundle.main.url(
            forResource: sound.resourceName,
            withExtension: sound.fileExtension
        ) else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
        } catch {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension ForegroundSignalPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }
}
