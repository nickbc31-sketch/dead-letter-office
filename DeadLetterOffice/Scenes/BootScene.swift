import SpriteKit

final class BootScene: SKScene {

    /// Prevents didChangeSize from cancelling the one-shot menu transition.
    private var bootSequenceStarted = false
    private var menuTransitionFired = false
    private weak var skView: SKView?

    override func didMove(to view: SKView) {
        backgroundColor = DLOColor.background
        alpha = 1
        isPaused = false
        skView = view
        SceneManager.shared.view = view
        NSLog("[DLO Startup] BootScene didMove size=%.0f×%.0f", size.width, size.height)
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
        guard !bootSequenceStarted else {
            NSLog("[DLO Startup] BootScene didChangeSize ignored — transition already scheduled")
            return
        }
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        NSLog("[DLO Startup] BootScene didChangeSize rebuilding splash %.0f×%.0f", size.width, size.height)
        childNode(withName: "bootContent")?.removeFromParent()
        removeAction(forKey: "bootSequence")
        buildScene()
    }

    private func buildScene() {
        guard !bootSequenceStarted else { return }
        bootSequenceStarted = true
        alpha = 1
        NSLog("[DLO Startup] BootScene scheduling main-menu transition")

        let layout = SceneLayout.make(scene: self)
        let cx = layout.midX
        let cy = layout.midY

        let content = SKNode()
        content.name = "bootContent"
        addChild(content)

        let titleLabel = DLOFont.titleLabel(text: "DEAD LETTER OFFICE", size: 28)
        titleLabel.position = CGPoint(x: cx, y: cy + layout.h * 0.04)
        titleLabel.alpha = 0
        content.addChild(titleLabel)

        let subtitleLabel = DLOFont.terminalLabel(text: "POST-MORTEM COMMUNICATIONS AUTHORITY", size: 11)
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: cx, y: cy - layout.h * 0.025)
        subtitleLabel.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
        subtitleLabel.alpha = 0
        content.addChild(subtitleLabel)

        let statusText = "SYSTEM ONLINE — CLERK TERMINAL v4.1.7"
        let statusLabel = DLOFont.terminalLabel(text: "", size: 9)
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.position = CGPoint(x: cx, y: cy - layout.h * 0.10)
        statusLabel.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.4)
        statusLabel.alpha = 1
        content.addChild(statusLabel)

        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let hold = SKAction.wait(forDuration: 3.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)

        var typeActions: [SKAction] = [SKAction.wait(forDuration: 0.5)]
        for char in statusText {
            let c = String(char)
            typeActions.append(SKAction.run { [weak statusLabel] in
                statusLabel?.text = (statusLabel?.text ?? "") + c
            })
            typeActions.append(SKAction.wait(forDuration: 0.045))
        }
        let typingDuration = 0.5 + Double(statusText.count) * 0.045

        content.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.group([
                SKAction.run { titleLabel.run(fadeIn) },
                SKAction.run { subtitleLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.4), fadeIn])) },
                SKAction.sequence(typeActions)
            ]),
            hold,
            fadeOut
        ]), withKey: "bootSequence")

        // Wall-clock transition — SKScene-level fadeOut previously left alpha at 0 and
        // could prevent the chained SKAction from presenting MainMenu on device.
        let menuDelay = 0.3 + max(typingDuration, 1.2) + 3.0 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + menuDelay) { [weak self] in
            self?.transitionToMainMenu()
        }

        AudioManager.shared.playMusic(named: "ambient_boot")
    }

    private func transitionToMainMenu() {
        guard !menuTransitionFired else { return }
        menuTransitionFired = true
        alpha = 1
        isPaused = false
        removeAction(forKey: "bootSequence")
        NSLog("[DLO Startup] BootScene→MainMenu transition firing")
        SceneManager.shared.transition(to: .mainMenu, from: self)
    }
}
