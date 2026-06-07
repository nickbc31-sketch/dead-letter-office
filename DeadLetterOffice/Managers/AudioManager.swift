import AVFoundation
import SpriteKit

final class AudioManager: NSObject, AVAudioPlayerDelegate {

    static let shared = AudioManager()
    private override init() {
        super.init()
        configureSession()
    }

    static let mainMenuTrackName = "main_menu"

    private var musicPlayer: AVAudioPlayer?
    private var currentTrackName: String?
    /// Retain one-shot players until playback finishes — otherwise SFX are cut off immediately.
    private var activeOneShots: [AVAudioPlayer] = []
    private var lastUIClickTime: TimeInterval = 0
    private var lastDialogueTime: TimeInterval = 0
    private let uiClickMinInterval: TimeInterval = 0.06
    private let dialogueMinInterval: TimeInterval = 0.10

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            NSLog("[AudioManager] WARNING — audio session setup failed: %@", error.localizedDescription)
        }
    }

    // MARK: - Music

    func playMusic(named name: String, fileExtension: String = "mp3") {
        guard name != currentTrackName else { return }
        stopMusic()
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            NSLog("[AudioManager] WARNING — missing music '%@.%@'", name, fileExtension)
            return
        }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = GameState.shared.musicVolume
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
            currentTrackName = name
        } catch {
            NSLog("[AudioManager] WARNING — failed to load music '%@': %@", name, error.localizedDescription)
        }
    }

    func playMainMenuMusic() {
        playMusic(named: Self.mainMenuTrackName, fileExtension: "wav")
    }

    func stopMainMenuMusic(fadeOut: TimeInterval = 0.8) {
        guard currentTrackName == Self.mainMenuTrackName else { return }
        stopMusic(fadeOut: fadeOut)
    }

    func stopMusic(fadeOut: TimeInterval = 0) {
        if fadeOut > 0 {
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

    // MARK: - UI / dialogue one-shots

    func playUIClick() {
        playOneShot(named: "Click", minInterval: uiClickMinInterval, lastPlayed: &lastUIClickTime)
    }

    func playDialogueContinue() {
        playOneShot(named: "dialogue", minInterval: dialogueMinInterval, lastPlayed: &lastDialogueTime)
    }

    private func playOneShot(named name: String, fileExtension: String = "wav",
                             minInterval: TimeInterval, lastPlayed: inout TimeInterval) {
        let volume = GameState.shared.sfxVolume
        guard volume > 0.01 else { return }
        let now = CACurrentMediaTime()
        if now - lastPlayed < minInterval { return }
        lastPlayed = now

        guard let url = bundleURL(forResource: name, extension: fileExtension) else {
            NSLog("[AudioManager] WARNING — missing SFX '%@.%@'", name, fileExtension)
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.volume = volume
            player.prepareToPlay()
            activeOneShots.append(player)
            if !player.play() {
                activeOneShots.removeAll { $0 === player }
                NSLog("[AudioManager] WARNING — SFX '%@' play() returned false", name)
            }
        } catch {
            NSLog("[AudioManager] WARNING — failed to play SFX '%@': %@", name, error.localizedDescription)
        }
    }

    private func bundleURL(forResource name: String, extension ext: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) { return url }
        // Case-insensitive fallback for bundle resources copied from UI_Sounds.
        let candidates = [name, name.lowercased(), name.uppercased(),
                          name.prefix(1).uppercased() + name.dropFirst().lowercased()]
        for candidate in Set(candidates) {
            if let url = Bundle.main.url(forResource: String(candidate), withExtension: ext) {
                return url
            }
        }
        return nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        activeOneShots.removeAll { $0 === player }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        activeOneShots.removeAll { $0 === player }
        if let error {
            NSLog("[AudioManager] WARNING — SFX decode error: %@", error.localizedDescription)
        }
    }

    // MARK: - Legacy SpriteKit SFX helpers (desk/platform — unchanged)

    func sfxAction(named name: String, fileExtension: String = "wav") -> SKAction {
        let volume = GameState.shared.sfxVolume
        let action = SKAction.playSoundFileNamed("\(name).\(fileExtension)", waitForCompletion: false)
        return SKAction.sequence([
            SKAction.changeVolume(to: volume, duration: 0),
            action
        ])
    }

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
