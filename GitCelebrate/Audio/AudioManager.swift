import AppKit
import Observation

@MainActor
@Observable
final class AudioManager {
    func playTestSound(volume: Double) {
        let sound = NSSound(named: "Glass") ?? NSSound(named: "Ping")
        sound?.volume = Float(volume)
        sound?.play()
    }

    func playRewardSound(for reward: RewardEvent, volume: Double) {
        guard reward.intensity > 1 else {
            return
        }

        playTestSound(volume: volume)
    }
}
