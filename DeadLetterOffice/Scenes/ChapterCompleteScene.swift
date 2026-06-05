import SpriteKit

final class ChapterCompleteScene: SKScene {

    var chapterID: String = "ch1"
    var nextSceneType: SceneType = .mainMenu

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = .black
        buildScene()
        AudioManager.shared.playMusic(named: "chapter_complete")
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        removeAllChildren()
        removeAllActions()
        isUserInteractionEnabled = false
        buildScene()
    }

    private func buildScene() {
        layout = SceneLayout.make(scene: self)
        let chapter = ChapterData.load(id: chapterID)
        buildScreen(title: chapter?.title ?? "SHIFT COMPLETE",
                    summary: chapter?.summary ?? "")
    }

    // MARK: - Shift Evaluation

    private func buildShiftEvaluation(chapterID: String) -> [String] {
        let cases = CaseFile.loadCases(forChapter: chapterID)
        let decisions = GameState.shared.caseDecisions
        var lines: [String] = []

        for c in cases {
            guard let actionID = decisions[c.id] else { continue }
            guard let action = c.availableActions.first(where: { $0.id == actionID }) else { continue }
            let audit = action.auditResponse.map { " \($0)" } ?? ""
            lines.append("CASE \(c.id.uppercased()) — \(action.shortLabel.uppercased()).\(audit)")
        }

        // Append score summary
        let state = GameState.shared
        if state.complianceScore != 0 || state.suspicionScore != 0 {
            lines.append("—")
            if state.complianceScore > 0 { lines.append("COMPLIANCE INDEX: +\(state.complianceScore)") }
            if state.suspicionScore > 0  { lines.append("SUSPICION FLAG LEVEL: \(state.suspicionScore)") }
        }
        if state.citizenHarmCount > 0 {
            lines.append("CITIZEN HARM EVENTS LOGGED: \(state.citizenHarmCount)")
        }

        return lines
    }

    // MARK: - Layout

    private func buildScreen(title: String, summary: String) {
        let evalLines = buildShiftEvaluation(chapterID: chapterID)

        // ── Shift Evaluation header ───────────────────────────────────────────
        let evalHdr = DLOFont.titleLabel(text: "PMCA — SHIFT EVALUATION", size: 13)
        evalHdr.horizontalAlignmentMode = .center
        evalHdr.position = CGPoint(x: layout.midX, y: layout.y(0.90))
        evalHdr.alpha = 0
        addChild(evalHdr)

        let evalDiv = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.5),
                                   size: CGSize(width: layout.w * 0.70, height: 1))
        evalDiv.position = CGPoint(x: layout.midX, y: layout.y(0.85))
        evalDiv.alpha = 0
        addChild(evalDiv)

        // Evaluation entries — stacked top-down with small step
        let lineStep: CGFloat = layout.h * 0.075
        let maxLines = min(evalLines.count, 6)
        var evalNodes: [SKNode] = [evalHdr, evalDiv]
        var lineY = layout.y(0.80)

        for i in 0..<maxLines {
            let text = evalLines[i]
            let isRule = text == "—"
            let lbl: SKNode
            if isRule {
                let rule = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.3),
                                        size: CGSize(width: layout.w * 0.60, height: 1))
                rule.position = CGPoint(x: layout.midX, y: lineY)
                rule.alpha = 0
                addChild(rule)
                lbl = rule
            } else {
                let entryLbl = DLOFont.terminalLabel(text: text, size: 9)
                entryLbl.fontColor = i == 0 ? DLOColor.terminalAmber.withAlphaComponent(0.9)
                                             : DLOColor.terminalAmber.withAlphaComponent(0.65)
                entryLbl.horizontalAlignmentMode = .left
                entryLbl.position = CGPoint(x: layout.x(0.08), y: lineY)
                entryLbl.alpha = 0
                entryLbl.preferredMaxLayoutWidth = layout.w * 0.84
                entryLbl.numberOfLines = 2
                addChild(entryLbl)
                lbl = entryLbl
            }
            evalNodes.append(lbl)
            lineY -= lineStep * (isRule ? 0.5 : 1.0)
        }

        // ── Chapter complete header ───────────────────────────────────────────
        let chapterDivY = lineY - lineStep * 0.6
        let chapterDiv = SKSpriteNode(color: DLOColor.uiBorder,
                                      size: CGSize(width: layout.w * 0.35, height: 1))
        chapterDiv.position = CGPoint(x: layout.midX, y: chapterDivY)
        chapterDiv.alpha = 0
        addChild(chapterDiv)

        let titleLabel = DLOFont.titleLabel(text: title, size: 18)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: layout.midX, y: chapterDivY - 22)
        titleLabel.alpha = 0
        addChild(titleLabel)

        let summaryLabel = SKLabelNode(text: summary)
        summaryLabel.fontName = "Menlo"
        summaryLabel.fontSize = 11
        summaryLabel.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.8)
        summaryLabel.horizontalAlignmentMode = .center
        summaryLabel.verticalAlignmentMode   = .top
        summaryLabel.numberOfLines = 0
        summaryLabel.preferredMaxLayoutWidth = layout.w * 0.55
        summaryLabel.position = CGPoint(x: layout.midX, y: chapterDivY - 42)
        summaryLabel.alpha = 0
        addChild(summaryLabel)

        let continueLbl = DLOFont.terminalLabel(text: "> CONTINUE TO NEXT ASSIGNMENT", size: 12)
        continueLbl.horizontalAlignmentMode = .center
        continueLbl.position = CGPoint(x: layout.midX, y: layout.y(0.08))
        continueLbl.alpha = 0
        addChild(continueLbl)

        continueLbl.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.7),
            SKAction.fadeAlpha(to: 1.0, duration: 0.7)
        ])))

        addChild(CRTEffectNode(size: size))

        // Staggered fade-in sequence
        var seq: [SKAction] = [SKAction.wait(forDuration: 0.6)]
        for node in evalNodes {
            seq.append(SKAction.run { node.run(SKAction.fadeIn(withDuration: 0.4)) })
            seq.append(SKAction.wait(forDuration: 0.18))
        }
        seq.append(SKAction.wait(forDuration: 0.3))
        seq.append(SKAction.run { chapterDiv.run(SKAction.fadeIn(withDuration: 0.4)) })
        seq.append(SKAction.wait(forDuration: 0.3))
        seq.append(SKAction.run { titleLabel.run(SKAction.fadeIn(withDuration: 0.7)) })
        seq.append(SKAction.wait(forDuration: 0.4))
        seq.append(SKAction.run { summaryLabel.run(SKAction.fadeIn(withDuration: 0.6)) })
        seq.append(SKAction.wait(forDuration: 0.7))
        seq.append(SKAction.run { continueLbl.alpha = 1 })
        seq.append(SKAction.run { [weak self] in self?.isUserInteractionEnabled = true })
        run(SKAction.sequence(seq))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SceneManager.shared.transition(to: nextSceneType, from: self)
    }
}
