import SpriteKit

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
    case dialogue(dialogueID: String, returnScene: SceneType)
    case platform(levelID: String)
    case chapterComplete(chapterID: String, nextScene: SceneType)
    case chapterSelect
    case ending(endingType: EndingType)
}

final class SceneManager {
    static let shared = SceneManager()
    private init() {}

    weak var view: SKView?

    func transition(to destination: SceneType, from source: SKScene) {
        guard let view = view else { return }
        let size = view.bounds.size
        let scene = makeScene(for: destination, size: size)
        let fade = SKTransition.fade(withDuration: 0.35)
        view.presentScene(scene, transition: fade)
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
        case .dialogue(let dialogueID, let returnScene):
            let s = DialogueScene(size: size)
            s.dialogueID = dialogueID
            s.returnSceneType = returnScene
            s.scaleMode = .resizeFill
            return s
        case .platform(let levelID):
            let s = PlatformScene(size: size); s.levelID = levelID; s.scaleMode = .resizeFill; return s
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
        }
    }
}
