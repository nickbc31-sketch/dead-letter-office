import SpriteKit

final class BootScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = DLOColor.background
        SceneManager.shared.view = view
        if ProcessInfo.processInfo.arguments.contains("--run-required-flags-test") {
            DeskScene.runRequiredFlagsTest()
        }
        if ProcessInfo.processInfo.arguments.contains("--run-followup-flags-test") {
            DeskScene.runFollowUpFlagsTest()
        }
        if let idx = ProcessInfo.processInfo.arguments.firstIndex(of: "--skip-to-desk"),
           ProcessInfo.processInfo.arguments.indices.contains(idx + 1) {
            let chID = ProcessInfo.processInfo.arguments[idx + 1]
            GameState.shared.resetForNewGame()
            GameState.shared.currentChapterID = chID
            SceneManager.shared.transition(to: .desk(chapterID: chID), from: self)
            return
        }
        buildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        removeAllChildren()
        removeAllActions()
        buildScene()
    }

    private func buildScene() {
        let layout = SceneLayout.make(scene: self)
        let cx = layout.midX
        let cy = layout.midY

        let titleLabel = DLOFont.titleLabel(text: "DEAD LETTER OFFICE", size: 28)
        titleLabel.position = CGPoint(x: cx, y: cy + layout.h * 0.04)
        titleLabel.alpha = 0
        addChild(titleLabel)

        let subtitleLabel = DLOFont.terminalLabel(text: "POST-MORTEM COMMUNICATIONS AUTHORITY", size: 11)
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: cx, y: cy - layout.h * 0.025)
        subtitleLabel.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
        subtitleLabel.alpha = 0
        addChild(subtitleLabel)

        let statusText = "SYSTEM ONLINE — CLERK TERMINAL v4.1.7"
        let statusLabel = DLOFont.terminalLabel(text: "", size: 9)
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.position = CGPoint(x: cx, y: cy - layout.h * 0.10)
        statusLabel.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.4)
        statusLabel.alpha = 1
        addChild(statusLabel)

        let fadeIn  = SKAction.fadeIn(withDuration: 0.8)
        let wait    = SKAction.wait(forDuration: 3.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let go      = SKAction.run { [weak self] in
            guard let self else { return }
            SceneManager.shared.transition(to: .mainMenu, from: self)
        }

        var typeActions: [SKAction] = [SKAction.wait(forDuration: 0.5)]
        for char in statusText {
            let c = String(char)
            typeActions.append(SKAction.run { statusLabel.text = (statusLabel.text ?? "") + c })
            typeActions.append(SKAction.wait(forDuration: 0.045))
        }

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.group([
                SKAction.run { titleLabel.run(fadeIn) },
                SKAction.run { subtitleLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.4), fadeIn])) },
                SKAction.run { statusLabel.run(SKAction.sequence(typeActions)) }
            ]),
            wait,
            fadeOut,
            go
        ]))

        AudioManager.shared.playMusic(named: "ambient_boot")
    }
}
