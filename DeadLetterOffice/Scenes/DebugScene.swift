import SpriteKit

/// QA debug menu — launch with `--start-at-debug`.
/// Reset save, inspect flags/scores, jump to scenes, toggle common test flags.
final class DebugScene: SKScene {

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))

    private struct ButtonTarget {
        let rect: CGRect
        let action: () -> Void
    }
    private var buttonTargets: [ButtonTarget] = []
    private var statusNode: SKNode?

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = DLOColor.background
        buildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        buildScene()
    }

    private func buildScene() {
        removeAllChildren()
        buttonTargets.removeAll()
        layout = SceneLayout.make(scene: self)

        let hdr = DLOFont.titleLabel(text: "DEBUG / QA", size: 20)
        hdr.position = CGPoint(x: layout.midX, y: layout.y(0.92))
        addChild(hdr)

        buildStatusPanel()
        buildSceneJumps()
        buildFlagTools()
        buildUtilityButtons()
        addChild(CRTEffectNode(size: size))
    }

    private func buildStatusPanel() {
        statusNode?.removeFromParent()
        let panel = SKNode()
        panel.position = CGPoint(x: layout.x(0.04), y: layout.y(0.78))
        addChild(panel)
        statusNode = panel

        let state = GameState.shared
        let flags = state.activeFlags.sorted().joined(separator: ", ")
        let flagText = flags.isEmpty ? "(none)" : flags
        let lines = [
            "Chapter: \(state.currentChapterID)",
            "Scores — C:\(state.complianceScore) E:\(state.empathyScore) S:\(state.suspicionScore)",
            "Trust — R:\(state.resistanceTrust) Corp:\(state.corporateTrust) Harm:\(state.citizenHarmCount)",
            "Cases done: \(state.completedCaseIDs.count)  Levels: \(state.completedLevelIDs.count)",
            "Flags (\(state.activeFlags.count)): \(flagText)"
        ]
        var y: CGFloat = 0
        for line in lines {
            let lbl = DLOFont.terminalLabel(text: line, size: 8)
            lbl.horizontalAlignmentMode = .left
            lbl.fontColor = DLOColor.uiBorder
            lbl.position = CGPoint(x: 0, y: y)
            panel.addChild(lbl)
            y -= 14
        }
    }

    private func buildSceneJumps() {
        let title = DLOFont.terminalLabel(text: "JUMP TO SCENE", size: 9)
        title.fontColor = DLOColor.terminalAmber
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: layout.x(0.04), y: layout.y(0.52))
        addChild(title)

        let jumps: [(String, () -> Void)] = [
            ("MAIN MENU", { SceneManager.shared.transition(to: .mainMenu, from: self) }),
            ("CHAPTER SELECT", { SceneManager.shared.transition(to: .chapterSelect, from: self) }),
            ("DESK CH1", { SceneManager.shared.transition(to: .desk(chapterID: "ch1"), from: self) }),
            ("DESK CH2", { SceneManager.shared.transition(to: .desk(chapterID: "ch2"), from: self) }),
            ("DESK CH3", { SceneManager.shared.transition(to: .desk(chapterID: "ch3"), from: self) }),
            ("PLATFORM CH1", { SceneManager.shared.transition(to: .platform(levelID: "level_ch1"), from: self) }),
            ("PLATFORM CH2", { SceneManager.shared.transition(to: .platform(levelID: "level_ch2"), from: self) }),
            ("PLATFORM CH3", { SceneManager.shared.transition(to: .platform(levelID: "level_ch3"), from: self) }),
            ("DIALOGUE INTRO CH1", {
                SceneManager.shared.transition(
                    to: .dialogue(dialogueID: "intro_ch1", returnScene: .debug, startNodeID: nil),
                    from: self)
            }),
            ("ENDING BROADCAST", { SceneManager.shared.transition(to: .ending(endingType: .broadcast), from: self) }),
        ]

        let colW = layout.w * 0.22
        let rowH: CGFloat = 28
        var x = layout.x(0.04)
        var y = layout.y(0.46)
        for (i, jump) in jumps.enumerated() {
            addButton(label: jump.0, x: x + colW / 2, y: y, width: colW - 8, action: jump.1)
            x += colW
            if (i + 1) % 4 == 0 {
                x = layout.x(0.04)
                y -= rowH
            }
        }
    }

    private func buildFlagTools() {
        let title = DLOFont.terminalLabel(text: "FLAGS & PROGRESS", size: 9)
        title.fontColor = DLOColor.terminalAmber
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: layout.x(0.52), y: layout.y(0.52))
        addChild(title)

        let toggles: [(String, String)] = [
            ("ch1_desk_complete", "CH1 DESK DONE"),
            ("ch1_platform_complete", "CH1 PLATFORM DONE"),
            ("ch2_unlocked", "UNLOCK CH2"),
            ("ch3_unlocked", "UNLOCK CH3"),
            ("ch4_unlocked", "UNLOCK CH4"),
            ("mara_death_scheduled", "MARA SCHEDULED"),
            ("ch1_tutorial_shown", "TUTORIAL SHOWN"),
            ("c09_processed", "C09 PROCESSED"),
            ("ch2_desk_complete", "CH2 DESK DONE"),
            ("ch2_elias_flag_reminder", "CH2 ELIAS REMINDER"),
            ("jun_vale_hint", "JUN HINT"),
            ("ch3_desk_complete", "CH3 DESK DONE"),
            ("marr_apt_accessed", "MARR APT ACCESS"),
            ("orrra_mural_ch3", "ORRA MURAL"),
        ]

        let colW = layout.w * 0.22
        let rowH: CGFloat = 28
        var x = layout.x(0.52)
        var y = layout.y(0.46)
        for (i, pair) in toggles.enumerated() {
            let flag = pair.0
            let label = pair.1
            addButton(label: label, x: x + colW / 2, y: y, width: colW - 8) { [weak self] in
                if GameState.shared.hasFlag(flag) {
                    GameState.shared.clearFlag(flag)
                } else {
                    GameState.shared.setFlag(flag)
                }
                GameState.shared.save()
                self?.buildScene()
            }
            x += colW
            if (i + 1) % 2 == 0 {
                x = layout.x(0.52)
                y -= rowH
            }
        }

        addButton(label: "UNLOCK ALL CHAPTERS", x: layout.x(0.74), y: layout.y(0.20),
                  width: layout.w * 0.22) { [weak self] in
            for n in 2...8 { GameState.shared.setFlag("ch\(n)_unlocked") }
            GameState.shared.save()
            self?.buildScene()
        }
    }

    private func buildUtilityButtons() {
        addButton(label: "RESET SAVE", x: layout.x(0.18), y: layout.y(0.08),
                  width: layout.w * 0.22, color: DLOColor.danger) { [weak self] in
            SaveManager.shared.deleteSave()
            GameState.shared.resetForNewGame()
            GameState.shared.save()
            self?.buildScene()
        }

        addButton(label: "REFRESH STATUS", x: layout.x(0.42), y: layout.y(0.08),
                  width: layout.w * 0.22) { [weak self] in
            self?.buildScene()
        }

        addButton(label: "< BACK TO MENU", x: layout.x(0.82), y: layout.y(0.08),
                  width: layout.w * 0.22) { [weak self] in
            guard let self else { return }
            SceneManager.shared.transition(to: .mainMenu, from: self)
        }
    }

    private func addButton(label: String, x: CGFloat, y: CGFloat, width: CGFloat,
                           color: SKColor = DLOColor.uiBorder,
                           action: @escaping () -> Void) {
        let h: CGFloat = 24
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: h), cornerRadius: 3)
        bg.fillColor = color.withAlphaComponent(0.15)
        bg.strokeColor = color.withAlphaComponent(0.55)
        bg.lineWidth = 1
        bg.position = CGPoint(x: x, y: y)
        addChild(bg)

        let lbl = DLOFont.terminalLabel(text: label, size: 7)
        lbl.fontColor = DLOColor.terminalAmber
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: x, y: y - 3)
        addChild(lbl)

        buttonTargets.append(ButtonTarget(
            rect: CGRect(x: x - width / 2, y: y - h / 2, width: width, height: h),
            action: action))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)
        for target in buttonTargets where target.rect.contains(pos) {
            target.action()
            return
        }
    }
}
