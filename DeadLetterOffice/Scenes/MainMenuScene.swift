import SpriteKit

final class MainMenuScene: SKScene {

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))

    private struct ButtonTarget { let rect: CGRect; let labelNode: SKLabelNode; let action: () -> Void }
    private var buttonTargets: [ButtonTarget] = []

    private var confirmPanel: SKNode?
    private var confirmRect  = CGRect.zero
    private var cancelRect   = CGRect.zero
    private var awaitingNewShiftConfirm = false

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        layout = SceneLayout.make(scene: self)
        backgroundColor = DLOColor.background
        buildScene()
        AudioManager.shared.playMainMenuMusic()
        NSLog("[DLO Startup] MainMenuScene ready — %d buttons", buttonTargets.count)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        buildScene()
    }

    private func buildScene() {
        removeAllChildren()
        buttonTargets.removeAll()
        confirmPanel = nil
        awaitingNewShiftConfirm = false

        buildBackground()
        buildTitle()
        buildMenuButtons()
        addChild(CRTEffectNode(size: size))
    }

    private func buildBackground() {
        if UIImage(named: "bg_main_menu") != nil {
            let bg = SKSpriteNode(imageNamed: "bg_main_menu")
            bg.size = size
            bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
            bg.zPosition = -10
            addChild(bg)
        } else {
            let base = SKSpriteNode(color: DLOColor.terminalBG, size: size)
            base.position = CGPoint(x: size.width / 2, y: size.height / 2)
            base.zPosition = -10
            addChild(base)

            let period: CGFloat = 4
            let lineColor = SKColor(white: 1.0, alpha: 0.04)
            var lineY: CGFloat = 0
            while lineY < size.height {
                let line = SKSpriteNode(color: lineColor, size: CGSize(width: size.width, height: 1))
                line.position = CGPoint(x: size.width / 2, y: lineY)
                line.zPosition = -9
                addChild(line)
                lineY += period
            }
        }
    }

    private func buildTitle() {
        let pmca = DLOFont.terminalLabel(text: "POST-MORTEM COMMUNICATIONS AUTHORITY", size: 8)
        pmca.horizontalAlignmentMode = .center
        pmca.position = CGPoint(x: layout.midX, y: layout.y(0.82))
        pmca.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.55)
        addChild(pmca)

        let titleLines = ["DEAD", "LETTER", "OFFICE"]
        var ty = layout.y(0.80)
        for line in titleLines {
            let lbl = DLOFont.titleLabel(text: line, size: min(layout.h * 0.17, 52))
            lbl.position = CGPoint(x: layout.midX, y: ty)
            lbl.verticalAlignmentMode = .top
            addChild(lbl)
            ty -= layout.h * 0.17
        }

        let divider = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                                   size: CGSize(width: layout.w * 0.6, height: 1))
        divider.position = CGPoint(x: layout.midX, y: layout.y(0.32))
        addChild(divider)
    }

    private func buildMenuButtons() {
        let state   = GameState.shared
        let hasSave = SaveManager.shared.hasSave
        let chapterSelectLocked = state.completedCaseIDs.isEmpty
        let mult    = state.textSizeMultiplier

        var items: [(label: String, subtitle: String?, enabled: Bool, action: () -> Void)] = []

        if hasSave {
            items.append(("> CONTINUE SHIFT", nil, true, { [weak self] in
                self?.handleContinueShift()
            }))
        }

        items.append(("> BEGIN NEW SHIFT", nil, true, { [weak self] in
            self?.handleBeginNewShift()
        }))

        items.append(("> CHAPTER SELECT",
                       chapterSelectLocked ? "(LOCKED)" : nil,
                       !chapterSelectLocked,
                       { [weak self] in
                           guard let self else { return }
                           SceneManager.shared.transition(to: .chapterSelect, from: self)
                       }))

        items.append(("> SETTINGS", nil, true, { [weak self] in
            guard let self else { return }
            SceneManager.shared.transition(to: .settings, from: self)
        }))

        items.append(("> CREDITS", nil, true, { [weak self] in
            guard let self else { return }
            SceneManager.shared.transition(to: .credits, from: self)
        }))

        let colW       = layout.w / CGFloat(items.count)
        let btnFontSz: CGFloat = (items.count > 4 ? 11 : 13) * mult

        for (i, item) in items.enumerated() {
            let colX = layout.left + colW * CGFloat(i) + colW / 2

            if i > 0 {
                let div = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.25),
                                       size: CGSize(width: 1, height: layout.h * 0.3))
                div.position = CGPoint(x: layout.left + colW * CGFloat(i), y: layout.y(0.2))
                addChild(div)
            }

            let alpha: CGFloat = item.enabled ? 1.0 : 0.4

            let arrow = DLOFont.terminalLabel(text: "v", size: 10 * mult)
            arrow.horizontalAlignmentMode = .center
            arrow.verticalAlignmentMode   = .top
            arrow.position   = CGPoint(x: colX, y: layout.y(0.24))
            arrow.fontColor  = DLOColor.terminalAmber.withAlphaComponent(alpha * 0.7)
            addChild(arrow)

            let btnLbl = DLOFont.terminalLabel(text: item.label, size: btnFontSz)
            btnLbl.horizontalAlignmentMode = .center
            btnLbl.verticalAlignmentMode   = .top
            btnLbl.position  = CGPoint(x: colX, y: layout.y(0.20))
            btnLbl.fontColor = item.enabled ? DLOColor.terminalAmber : DLOColor.uiBorder
            addChild(btnLbl)

            if let sub = item.subtitle {
                let subLbl = DLOFont.terminalLabel(text: sub, size: 8 * mult)
                subLbl.horizontalAlignmentMode = .center
                subLbl.verticalAlignmentMode   = .top
                subLbl.position  = CGPoint(x: colX, y: layout.y(0.13))
                subLbl.fontColor = DLOColor.uiBorder.withAlphaComponent(0.7)
                addChild(subLbl)
            }

            if item.enabled {
                let hitH    = max(layout.h * 0.3, 44)
                let hitRect = CGRect(x: layout.left + colW * CGFloat(i),
                                     y: layout.y(0.05),
                                     width: colW, height: hitH)
                buttonTargets.append(ButtonTarget(rect: hitRect, labelNode: btnLbl, action: item.action))
            }
        }
    }

    // MARK: - Continue Shift

    private func handleContinueShift() {
        AudioManager.shared.stopMainMenuMusic()
        let state = GameState.shared
        if state.hasFlag("game_complete") {
            SceneManager.shared.transition(to: .credits, from: self)
            return
        }
        let introFlag = "ch1_intro_complete"
        if !state.hasFlag(introFlag), DialogueFile.load(id: "intro_ch1") != nil {
            SceneManager.shared.transition(
                to: .dialogue(dialogueID: "intro_ch1",
                              returnScene: .desk(chapterID: "ch1"),
                              startNodeID: nil),
                from: self)
        } else {
            let ch = state.currentChapterID.isEmpty ? "ch1" : state.currentChapterID
            SceneManager.shared.transition(to: .desk(chapterID: ch), from: self)
        }
    }

    // MARK: - Begin New Shift

    private func handleBeginNewShift() {
        guard confirmPanel == nil else { return }
        if !SaveManager.shared.hasSave {
            confirmNewShift()
            return
        }

        let panelW = min(layout.w * 0.65, 520)
        let panelH = layout.h * 0.40

        let panel = SKNode()
        panel.zPosition = 1000
        panel.position  = layout.center

        let bg = SKSpriteNode(color: DLOColor.terminalBG,
                              size: CGSize(width: panelW, height: panelH))
        let border = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 4)
        border.strokeColor = DLOColor.terminalAmber
        border.lineWidth   = 1.5
        border.fillColor   = .clear
        border.zPosition   = 1
        bg.addChild(border)
        panel.addChild(bg)

        let titleLbl = DLOFont.titleLabel(text: "BEGIN A NEW SHIFT?", size: 14)
        titleLbl.horizontalAlignmentMode = .center
        titleLbl.position = CGPoint(x: 0, y: panelH * 0.22)
        panel.addChild(titleLbl)

        let msgLbl = SKLabelNode(text: "Your current save will be replaced.\nThis cannot be undone.")
        msgLbl.fontName                = "Menlo"
        msgLbl.fontSize                = 9
        msgLbl.fontColor               = DLOColor.uiBorder
        msgLbl.horizontalAlignmentMode = .center
        msgLbl.verticalAlignmentMode   = .center
        msgLbl.numberOfLines           = 2
        msgLbl.preferredMaxLayoutWidth = panelW * 0.80
        msgLbl.position = CGPoint(x: 0, y: -panelH * 0.02)
        panel.addChild(msgLbl)

        let btnY: CGFloat = -panelH * 0.30

        let confirmLbl = DLOFont.terminalLabel(text: "CONFIRM", size: 11)
        confirmLbl.fontColor               = DLOColor.terminalAmber
        confirmLbl.horizontalAlignmentMode = .center
        confirmLbl.position = CGPoint(x: -panelW * 0.22, y: btnY)
        panel.addChild(confirmLbl)

        let cancelLbl = DLOFont.terminalLabel(text: "CANCEL", size: 11)
        cancelLbl.fontColor               = DLOColor.uiBorder
        cancelLbl.horizontalAlignmentMode = .center
        cancelLbl.position = CGPoint(x: panelW * 0.22, y: btnY)
        panel.addChild(cancelLbl)

        addChild(panel)
        confirmPanel = panel

        let bY = layout.center.y + btnY
        let bH: CGFloat = 44
        confirmRect = CGRect(x: layout.center.x - panelW * 0.22 - 55, y: bY - bH / 2,
                             width: 110, height: bH)
        cancelRect  = CGRect(x: layout.center.x + panelW * 0.22 - 50, y: bY - bH / 2,
                             width: 100, height: bH)
        awaitingNewShiftConfirm = true
    }

    private func confirmNewShift() {
        AudioManager.shared.stopMainMenuMusic()
        awaitingNewShiftConfirm = false
        confirmPanel?.removeFromParent()
        confirmPanel = nil

        SaveManager.shared.deleteSave()
        GameState.shared.resetForNewGame()

        if DialogueFile.load(id: "intro_ch1") != nil {
            SceneManager.shared.transition(
                to: .dialogue(dialogueID: "intro_ch1",
                              returnScene: .desk(chapterID: "ch1"),
                              startNodeID: nil),
                from: self)
        } else {
            SceneManager.shared.transition(to: .desk(chapterID: "ch1"), from: self)
        }
    }

    // MARK: - Touch

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        NSLog("[DLO Startup] MainMenu tap (%.0f,%.0f) confirm=%d", pos.x, pos.y, awaitingNewShiftConfirm)

        if awaitingNewShiftConfirm {
            if confirmRect.contains(pos) {
                AudioManager.shared.playUIClick()
                confirmNewShift()
            } else if cancelRect.contains(pos) {
                AudioManager.shared.playUIClick()
                awaitingNewShiftConfirm = false
                confirmPanel?.removeFromParent()
                confirmPanel = nil
            }
            return
        }

        for target in buttonTargets where target.rect.contains(pos) {
            AudioManager.shared.playUIClick()
            target.labelNode.run(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.06),
                SKAction.fadeAlpha(to: 1.0, duration: 0.12)
            ]))
            run(SKAction.sequence([
                SKAction.wait(forDuration: 0.08),
                SKAction.run { target.action() }
            ]))
            return
        }
    }
}
