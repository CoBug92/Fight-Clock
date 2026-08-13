import AVFAudio
import Foundation

@MainActor
final class ForegroundSignalPlayer: NSObject, SignalPlaying {
    private var player: AVAudioPlayer?

    func play(_ signal: SessionSignal) {
        let name = switch signal {
        case .roundStarted: "placeholder_round"
        case .roundEnding: "placeholder_warning"
        case .restStarted: "placeholder_rest"
        case .workoutCompleted: "placeholder_complete"
        }

        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }

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
