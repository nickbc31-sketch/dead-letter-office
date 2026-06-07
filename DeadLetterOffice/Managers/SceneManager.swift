import SpriteKit
import UIKit

enum EndingType {
    case broadcast
    case control
    case erasure
}

indirect enum SceneType {
    case mainMenu
    case credits
    case settings
    case desk(chapterID: String)
    case dialogue(dialogueID: String, returnScene: SceneType, startNodeID: String?)
    case platform(levelID: String)
    case chapterComplete(chapterID: String, nextScene: SceneType)
    case chapterSelect
    case ending(endingType: EndingType)
    case debug
    case debugFieldTest
}

final class SceneManager {
    static let shared = SceneManager()
    private init() {}

    weak var view: SKView?

    func transition(to destination: SceneType, from source: SKScene) {
        guard let view = view else {
            NSLog("[DLO Startup] BLOCKED transition to %@ — SceneManager.view is nil", "\(destination)")
            return
        }
        NSLog("[DLO Startup] transition %@ → %@", String(describing: type(of: source)), "\(destination)")
        let screen = UIScreen.main.bounds.size
        let viewBounds = view.bounds.size
        let size = CGSize(
            width: max(screen.width, screen.height, viewBounds.width, viewBounds.height),
            height: min(screen.width, screen.height, viewBounds.width, viewBounds.height)
        )
        let scene = makeScene(for: destination, size: size)
        scene.alpha = 1
        source.alpha = 1
        let fade = SKTransition.fade(withDuration: 0.35)
        view.presentScene(scene, transition: fade)
    }

    /// Resume gameplay after Settings when opened from an active scene.
    func returnFromSettings(from source: SKScene) {
        guard let dest = GameState.shared.consumeSettingsReturn() else {
            transition(to: .mainMenu, from: source)
            return
        }
        switch dest {
        case .platform(let levelID, let spawn):
            GameState.shared.setPlatformSpawnOverride(levelID: levelID, point: spawn)
            transition(to: .platform(levelID: levelID), from: source)
        case .desk(let chapterID):
            transition(to: .desk(chapterID: chapterID), from: source)
        }
    }

    private func makeScene(for type: SceneType, size: CGSize) -> SKScene {
        switch type {
        case .mainMenu:
            let s = MainMenuScene(size: size); s.scaleMode = .resizeFill; return s
        case .credits:
            let s = CreditsScene(size: size); s.scaleMode = .resizeFill; return s
        case .settings:
            let s = SettingsScene(size: size); s.scaleMode = .resizeFill; return s
        case .desk(let chapterID):
            let s = DeskScene(size: size); s.chapterID = chapterID; s.scaleMode = .resizeFill; return s
        case .dialogue(let dialogueID, let returnScene, let startNodeID):
            let s = DialogueScene(size: size)
            s.dialogueID = dialogueID
            s.returnSceneType = returnScene
            s.startNodeID = startNodeID
            s.scaleMode = .resizeFill
            return s
        case .platform(let levelID):
            let s = PlatformScene(size: size); s.levelID = levelID; s.scaleMode = .resizeFill
            #if DEBUG
            s.debugFieldTestMode = GameState.shared.isDebugFieldTestSession
            #endif
            return s
        case .chapterComplete(let chapterID, let nextScene):
            let s = ChapterCompleteScene(size: size)
            s.chapterID = chapterID
            s.nextSceneType = nextScene
            s.scaleMode = .resizeFill
            return s
        case .chapterSelect:
            let s = ChapterSelectScene(size: size); s.scaleMode = .resizeFill; return s
        case .ending(let endingType):
            let s = EndingScene(size: size); s.endingType = endingType; s.scaleMode = .resizeFill; return s
        case .debug:
            let s = DebugScene(size: size); s.scaleMode = .resizeFill; return s
        case .debugFieldTest:
            #if DEBUG
            let s = DebugFieldTestScene(size: size); s.scaleMode = .resizeFill; return s
            #else
            let s = MainMenuScene(size: size); s.scaleMode = .resizeFill; return s
            #endif
        }
    }
}
