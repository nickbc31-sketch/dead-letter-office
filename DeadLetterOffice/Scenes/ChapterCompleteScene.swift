import SpriteKit

final class ChapterCompleteScene: SKScene {

    var chapterID: String = "ch1"
    var nextSceneType: SceneType = .mainMenu

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))
    private var continueRect = CGRect.zero
    private var showingTutorial = false
    private var scrollState: ScrollableReadablePanel.ScrollState?
    private var scrollBodyRect = CGRect.zero
    private var scrollTouch: UITouch?

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = .black
        PDAJournalManager.onShiftComplete(chapterID: chapterID)
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
        scrollState = nil
        scrollTouch = nil
        buildScene()
    }

    private func buildScene() {
        layout = SceneLayout.make(scene: self)
        let chapter = ChapterData.load(id: chapterID)
        let needsTutorial = chapterID == "ch1"
            && !GameState.shared.hasFlag("performance_review_explained")
        if needsTutorial {
            buildPerformanceTutorial {
                GameState.shared.setFlag("performance_review_explained")
                GameState.shared.save()
                self.removeAllChildren()
                self.scrollState = nil
                self.scrollTouch = nil
                self.buildEvaluationScreen(
                    title: chapter?.title ?? "SHIFT COMPLETE",
                    summary: chapter?.summary ?? "")
            }
        } else {
            buildEvaluationScreen(
                title: chapter?.title ?? "SHIFT COMPLETE",
                summary: chapter?.summary ?? "")
        }
    }

    // MARK: - First-time orientation / performance review

    private func buildPerformanceTutorial(onContinue: @escaping () -> Void) {
        showingTutorial = true
        let mult = GameState.shared.textSizeMultiplier
        let state = GameState.shared

        let sections: [(String, String)] = [
            ("COMPLIANCE",
             "Following PMCA procedures increases Compliance.\nHigher Compliance reduces scrutiny."),
            ("SUSPICION",
             "Unusual actions increase Suspicion.\nHigh Suspicion may attract PMCA attention."),
            ("CITIZEN HARM",
             "Some decisions negatively affect citizens.\nCitizen Harm may influence future outcomes."),
        ]

        var bodyLines: [String] = []
        for (title, body) in sections {
            bodyLines.append(title)
            bodyLines.append(body)
            bodyLines.append("")
        }
        bodyLines.append("—")
        bodyLines.append("")
        bodyLines.append("CURRENT COMPLIANCE: \(state.complianceScore)")
        bodyLines.append("CURRENT SUSPICION: \(state.suspicionScore)")
        bodyLines.append("CURRENT CITIZEN HARM: \(state.citizenHarmCount)")

        let report = FixedHeaderScrollReport.build(
            layout: layout,
            header: "PMCA PERFORMANCE REVIEW",
            body: bodyLines.joined(separator: "\n"),
            continueText: "> CONTINUE",
            textMultiplier: mult)
        addChild(report.root)
        scrollState = report.scrollState
        scrollBodyRect = report.scrollBodyRect
        continueRect = report.continueRect
        addChild(CRTEffectNode(size: size))
        isUserInteractionEnabled = true
        userData = NSMutableDictionary()
        userData?["tutorialContinue"] = onContinue
    }

    // MARK: - Shift Evaluation

    private func buildShiftEvaluation(chapterID: String) -> [String] {
        let cases = CaseFile.loadCases(forChapter: chapterID)
        let state = GameState.shared
        var lines: [String] = []

        for c in cases {
            guard let actionID = state.caseDecisions[c.id] else { continue }
            guard let action = c.availableActions.first(where: { $0.id == actionID }) else { continue }
            let label = MaraConfidenceAssessor.shortCaseLabel(for: c)
            let confidence = state.caseConfidence[c.id]
                ?? MaraConfidenceAssessor.assess(
                    caseFile: c, actionID: actionID, flags: state.activeFlags)

            lines.append("CASE \(label)")
            lines.append("Decision: \(action.shortLabel.uppercased())")
            lines.append("PMCA Assessment: \(MaraConfidenceAssessor.pmcaAssessment(for: action))")
            lines.append("Mara Assessment: \(MaraConfidenceAssessor.maraShiftAssessment(for: confidence))")
            lines.append("Citizen Impact: \(MaraConfidenceAssessor.citizenImpact(for: action))")
            lines.append("")
        }

        if !lines.isEmpty { lines.append("—") }

        let summary = MaraConfidenceAssessor.confidenceSummary(from: state.caseConfidence)
        if summary.correct + summary.partial + summary.incorrect > 0 {
            lines.append("SHIFT RECORD")
            lines.append("Cases investigated: \(summary.correct + summary.partial + summary.incorrect)")
            if summary.partial > 0 {
                lines.append("Cases with unresolved questions: \(summary.partial)")
            }
            if summary.incorrect > 0 {
                lines.append("Cases overlooked: \(summary.incorrect)")
            }
            lines.append("")
        }

        if state.complianceScore != 0 || state.suspicionScore != 0 || state.citizenHarmCount != 0 {
            lines.append("—")
            lines.append("COMPLIANCE INDEX: \(state.complianceScore)")
            lines.append("SUSPICION FLAG LEVEL: \(state.suspicionScore)")
            if state.citizenHarmCount > 0 {
                lines.append("CITIZEN HARM EVENTS: \(state.citizenHarmCount)")
            }
        }

        return lines
    }

    private func buildEvaluationScreen(title: String, summary: String) {
        showingTutorial = false
        let mult = GameState.shared.textSizeMultiplier
        let evalLines = buildShiftEvaluation(chapterID: chapterID)

        var bodyLines = evalLines
        if !bodyLines.isEmpty { bodyLines.append("") }
        bodyLines.append("—")
        bodyLines.append("")
        bodyLines.append(title.uppercased())
        bodyLines.append("")
        bodyLines.append(summary)

        let report = FixedHeaderScrollReport.build(
            layout: layout,
            header: "PMCA — SHIFT EVALUATION",
            body: bodyLines.joined(separator: "\n"),
            continueText: "> CONTINUE TO NEXT ASSIGNMENT",
            textMultiplier: mult)
        report.root.alpha = 0
        addChild(report.root)
        scrollState = report.scrollState
        scrollBodyRect = report.scrollBodyRect
        continueRect = report.continueRect
        report.continueLabel.alpha = 0
        addChild(CRTEffectNode(size: size))

        report.root.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.45),
            SKAction.run { report.continueLabel.alpha = 1 },
            SKAction.run { [weak self] in self?.isUserInteractionEnabled = true }
        ]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)
        if scrollBodyRect.contains(pos), (scrollState?.maxScroll ?? 0) > 0 {
            scrollTouch = touch
            return
        }
        guard continueRect.contains(pos) else { return }
        AudioManager.shared.playUIClick()

        if showingTutorial, let action = userData?["tutorialContinue"] as? () -> Void {
            isUserInteractionEnabled = false
            action()
            return
        }
        SceneManager.shared.transition(to: nextSceneType, from: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = scrollTouch, touches.contains(touch), let scrollState else { return }
        let pos = touch.location(in: self)
        let prev = touch.previousLocation(in: self)
        if scrollBodyRect.contains(pos) || scrollBodyRect.contains(prev) {
            scrollState.applyDrag(deltaY: pos.y - prev.y)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = scrollTouch, touches.contains(touch) { scrollTouch = nil }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = scrollTouch, touches.contains(touch) { scrollTouch = nil }
    }
}
