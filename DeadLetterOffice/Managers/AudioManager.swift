import AVFoundation
import SpriteKit

final class AudioManager {

    static let shared = AudioManager()
    private init() {}

    private var musicPlayer: AVAudioPlayer?
    private var currentTrackName: String?

    // Play a looping ambient music track
    func playMusic(named name: String, fileExtension: String = "mp3") {
        guard name != currentTrackName else { return }
        stopMusic()
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else { return }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = GameState.shared.musicVolume
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
            currentTrackName = name
        } catch {
            print("[AudioManager] Failed to load music: \(name) — \(error)")
        }
    }

    func stopMusic(fadeOut: TimeInterval = 0) {
        if fadeOut > 0 {
            // Simple fade: reduce volume, then stop
            musicPlayer?.setVolume(0, fadeDuration: fadeOut)
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut) { [weak self] in
                self?.musicPlayer?.stop()
                self?.musicPlayer = nil
                self?.currentTrackName = nil
            }
        } else {
            musicPlayer?.stop()
            musicPlayer = nil
            currentTrackName = nil
        }
    }

    func setMusicVolume(_ volume: Float) {
        musicPlayer?.volume = volume
    }

    // Play a one-shot sound effect via SKAction on the caller node
    func sfxAction(named name: String, fileExtension: String = "wav") -> SKAction {
        let volume = GameState.shared.sfxVolume
        let action = SKAction.playSoundFileNamed("\(name).\(fileExtension)", waitForCompletion: false)
        return SKAction.sequence([
            SKAction.changeVolume(to: volume, duration: 0),
            action
        ])
    }

    // Named convenience methods for common sounds
    func playStamp(on node: SKNode) {
        node.run(sfxAction(named: "stamp"))
    }

    func playPageTurn(on node: SKNode) {
        node.run(sfxAction(named: "page_turn"))
    }

    func playTerminalBeep(on node: SKNode) {
        node.run(sfxAction(named: "terminal_beep"))
    }

    func playDroneAlert(on node: SKNode) {
        node.run(sfxAction(named: "drone_alert"))
    }
}
