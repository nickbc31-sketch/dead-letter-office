import SpriteKit

final class DeskScene: SKScene {

    var chapterID: String = "ch1"

    // Game data
    private var cases: [CaseFile] = []
    private var currentCaseIndex: Int = 0
    private var currentCase: CaseFile? { cases.indices.contains(currentCaseIndex) ? cases[currentCaseIndex] : nil }

    // Visual nodes
    private var documentNodes: [DocumentNode] = []
    private var activeDocumentIndex: Int = 0
    private var stampButtons: [StampButtonNode] = []

    private var trayArea: SKNode!
    private var docTabs: SKNode!
    private var stampArea: SKNode!
    private var messageArea: SKNode!
    private var hudNode: SKNode!

    private var complianceBar: SKSpriteNode!
    private var suspicionBar: SKSpriteNode!
    private var hasStamped = false
    private var caseHeaderNode: SKLabelNode?
    private var actionRequiredNode: SKLabelNode?
    private var continueButtonNode: SKNode?

    // ── Scene-level touch hit targets (all in scene coordinates) ──────────────
    // Pattern: same as MainMenuScene — no isUserInteractionEnabled on any child node,
    // no coordinate-space ambiguity.

    private struct TabTarget   { let rect: CGRect; let index: Int }
    private struct StampTarget { let rect: CGRect; let action: CaseAction }

    private var tabTargets:    [TabTarget]   = []
    private var stampTargets:  [StampTarget] = []
    private var continueRect:  CGRect?
    private var continueAction: (() -> Void)?
    private var pauseButtonRect = CGRect.zero
    private var notebookButtonRect = CGRect.zero

    // Pause overlay rects (populated when overlay is shown, cleared when hidden)
    private var pauseOverlay:     SKNode?
    private var pauseResumeRect = CGRect.zero
    private var pauseExitRect   = CGRect.zero
    private var notebookOverlay:  SKNode?
    private var notebookScrollState: ScrollableReadablePanel.ScrollState?
    private var notebookScrollTouch: UITouch?

    // Action result overlay (shown after stamp, over doc area)
    private var resultPanel:        SKNode?
    private var resultContinueRect: CGRect = .zero
    private var resultContinueAction: (() -> Void)?

    // Audit analysis overlay
    private var auditOverlay:      SKNode?
    private var auditContentNode:  SKNode?
    private var auditContentH:     CGFloat = 0
    private var auditViewH:        CGFloat = 0
    private var auditButtonRect    = CGRect.zero
    private var auditCloseRect     = CGRect.zero
    private var isScrollingAudit   = false
    private var auditLastScrollY:  CGFloat = 0
    private var auditScrollOffset: CGFloat = 0

    // Document scrolling (touch-and-drag in the tray area)
    private var isScrollingDocument = false
    private var lastScrollY: CGFloat = 0

    // ── Layout ────────────────────────────────────────────────────────────────

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))

    private let kStatusH: CGFloat = 28
    private let kTabH:    CGFloat = 26
    private let kTabGap:  CGFloat = 4
    private var kHudY:    CGFloat { layout.top - kStatusH / 2 }
    private var kTabsY:   CGFloat { layout.top - kStatusH - kTabGap - kTabH }
    private var kDocH:    CGFloat { kTabsY - layout.bottom }
    private var kDocW:    CGFloat { layout.w * 0.59 }
    // Divider sits 6pt right of the document panel edge (was layout.x(0.65), which left
    // a 6% dead zone between the document and divider that was not usable space).
    private var kSplitX:  CGFloat { layout.left + kDocW + 6 }
    // Stamp buttons centred in the full right panel (divider to screen right).
    // Because kSplitX now aligns with the document edge, this is also centred between
    // the document right edge and the screen right edge — equal breathing room on both sides.
    private var kStampX:  CGFloat { (kSplitX + layout.right) / 2 }
    // Full available width for the message / contradiction panel in the right column.
    private var kMsgW:    CGFloat { layout.right - kSplitX - 16 }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = DLOColor.background

        // Fire chapter intro dialogue the first time a chapter is entered (Ch1 is handled by
        // MainMenuScene; all other chapters trigger here so each intro plays exactly once).
        if chapterID != "ch1" {
            let introFlag = "\(chapterID)_intro_complete"
            if !GameState.shared.hasFlag(introFlag),
               DialogueFile.load(id: "intro_\(chapterID)") != nil {
                SceneManager.shared.transition(
                    to: .dialogue(dialogueID: "intro_\(chapterID)",
                                  returnScene: .desk(chapterID: chapterID),
                                  startNodeID: nil),
                    from: self)
                return
            }
        }

        loadCases()
        buildScene()
        AudioManager.shared.playMusic(named: "ambient_desk")
        if ProcessInfo.processInfo.arguments.contains("--run-touch-test") {
            run(SKAction.wait(forDuration: 0.5)) { [weak self] in self?.runTouchTests() }
        }
        if ProcessInfo.processInfo.arguments.contains("--run-full-ch1-test") {
            run(SKAction.wait(forDuration: 0.5)) { [weak self] in self?.runFullCh1Test() }
        }
        if ProcessInfo.processInfo.arguments.contains("--run-required-flags-test") {
            DeskScene.runRequiredFlagsTest()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        documentNodes.removeAll()
        stampButtons.removeAll()
        pauseOverlay = nil
        pauseResumeRect = .zero
        pauseExitRect = .zero
        buildScene()
    }

    private func buildScene() {
        layout = SceneLayout.make(scene: self)
        removeAllChildren()
        tabTargets.removeAll()
        stampTargets.removeAll()
        continueRect = nil
        continueAction = nil
        pauseResumeRect = .zero
        pauseExitRect = .zero
        buildLayout()
        presentCurrentCase()
    }

    // MARK: - Touch (scene-level — no isUserInteractionEnabled on any child node)
    //
    // All interactive elements are hit-tested here against stored CGRect arrays
    // in scene coordinates. This matches the proven MainMenuScene pattern and
    // avoids SpriteKit custom-node hit-test ambiguity on iOS.

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)

        if notebookOverlay != nil, notebookScrollState?.maxScroll ?? 0 > 0 {
            notebookScrollTouch = touch
            return
        }

        if auditOverlay != nil {
            // Audit overlay: enable vertical scroll anywhere in the overlay
            isScrollingAudit = true
            auditLastScrollY = pos.y
            return
        }

        // Start document scroll when finger lands in the document tray
        if pauseOverlay == nil {
            let docArea = CGRect(x: layout.left, y: layout.bottom, width: kDocW, height: kDocH)
            if docArea.contains(pos) {
                isScrollingDocument = true
                lastScrollY = pos.y
            }

            // Visual press feedback on stamp buttons
            if !hasStamped {
                for (i, target) in stampTargets.enumerated() where target.rect.contains(pos) {
                    NSLog("[DLO Touch] touchesBegan on stamp[\(i)] action=\(target.action.id)")
                    if i < stampButtons.count { stampButtons[i].animatePress() }
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)
        if let scrollTouch = notebookScrollTouch, touch === scrollTouch,
           let state = notebookScrollState {
            state.applyDrag(deltaY: pos.y - touch.previousLocation(in: self).y)
            return
        }
        if isScrollingAudit {
            let delta = pos.y - auditLastScrollY
            auditLastScrollY = pos.y
            scrollAuditContent(delta: delta)
        } else if isScrollingDocument {
            let delta = pos.y - lastScrollY
            lastScrollY = pos.y
            if documentNodes.indices.contains(activeDocumentIndex) {
                documentNodes[activeDocumentIndex].scroll(delta: delta)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isScrollingDocument = false
        isScrollingAudit = false
        for touch in touches where touch === notebookScrollTouch {
            notebookScrollTouch = nil
        }
        guard let touch = touches.first else { return }
        handleTap(at: touch.location(in: self))
    }

    // Central tap dispatcher — called by touchesEnded AND the programmatic test runner.
    @discardableResult
    private func handleTap(at pos: CGPoint) -> String {
        NSLog("[DLO Touch] tap pos=(\(Int(pos.x)),\(Int(pos.y)))")

        // ── Action result panel is open ───────────────────────────────────────
        if resultPanel != nil {
            if resultContinueRect.contains(pos) {
                NSLog("[DLO Touch] → RESULT PANEL CONTINUE")
                let action = resultContinueAction
                hideResultPanel()
                action?()
                return "result-continue"
            }
            return "result-panel"
        }

        // ── Audit analysis overlay is open ────────────────────────────────────
        if auditOverlay != nil {
            if auditCloseRect.contains(pos) {
                NSLog("[DLO Touch] → CLOSE AUDIT LOG")
                hideAuditOverlay()
                return "audit-close"
            }
            // Tapping outside the panel also closes
            let panelW = layout.w * 0.90
            let panelH = layout.h * 0.86
            let panelRect = CGRect(x: layout.midX - panelW / 2, y: layout.midY - panelH / 2,
                                   width: panelW, height: panelH)
            if !panelRect.contains(pos) {
                hideAuditOverlay()
                return "audit-dim-close"
            }
            return "audit-panel"
        }

        // ── Pause overlay is open ─────────────────────────────────────────────
        if pauseOverlay != nil {
            if pauseResumeRect.contains(pos) {
                NSLog("[DLO Touch] → RESUME SHIFT")
                hidePauseOverlay()
                return "resume"
            } else if pauseExitRect.contains(pos) {
                NSLog("[DLO Touch] → EXIT TO MAIN MENU")
                hidePauseOverlay()
                GameState.shared.save()
                SceneManager.shared.transition(to: .mainMenu, from: self)
                return "exit"
            }
            NSLog("[DLO Touch] → overlay background (consumed)")
            return "overlay-bg"
        }

        if notebookOverlay != nil {
            return "notebook-open"
        }

        if notebookButtonRect.contains(pos) {
            showNotebookOverlay()
            return "notebook-open"
        }

        // ── Pause button ──────────────────────────────────────────────────────
        if pauseButtonRect.contains(pos) {
            NSLog("[DLO Touch] → OPEN PAUSE MENU")
            showPauseOverlay()
            return "pause-open"
        }

        // ── Audit log button ──────────────────────────────────────────────────
        if !hasStamped, auditButtonRect.contains(pos), let c = currentCase, !c.contradictions.isEmpty {
            NSLog("[DLO Touch] → OPEN AUDIT LOG")
            showAuditOverlay(for: c)
            return "audit-open"
        }

        // ── Continue / Next Case ──────────────────────────────────────────────
        if let cr = continueRect, cr.contains(pos) {
            NSLog("[DLO Touch] → CONTINUE / NEXT CASE")
            let action = continueAction
            clearContinueButton()
            action?()
            return "continue"
        }

        // ── Stamp / decision buttons ──────────────────────────────────────────
        if !hasStamped {
            for target in stampTargets where target.rect.contains(pos) {
                NSLog("[DLO Touch] → STAMP action=\(target.action.id)")
                if let c = currentCase { performAction(target.action, for: c) }
                return "stamp-\(target.action.id)"
            }
        }

        // ── Document tabs ─────────────────────────────────────────────────────
        for target in tabTargets where target.rect.contains(pos) {
            NSLog("[DLO Touch] → TAB index=\(target.index)")
            switchToDocument(at: target.index)
            return "tab-\(target.index)"
        }

        NSLog("[DLO Touch] → no hit")
        return "miss"
    }

    // MARK: - Programmatic Touch Tests (debug only)
    // Called when launched with --run-touch-test argument.
    // Exercises every interactive element using the tap handler directly,
    // logging PASS/FAIL for each target.
    private func runTouchTests() {
        var seq: [(delay: Double, label: String, pos: CGPoint)] = []

        // Tab targets — center of each hit rect
        for t in tabTargets {
            let cx = t.rect.midX
            let cy = t.rect.midY
            seq.append((delay: 0.3, label: "TAB-\(t.index)-center", pos: CGPoint(x: cx, y: cy)))
        }

        // Stamp targets — center of each
        for t in stampTargets {
            let cx = t.rect.midX
            let cy = t.rect.midY
            seq.append((delay: 0.3, label: "STAMP-\(t.action.id)-center", pos: CGPoint(x: cx, y: cy)))
            // Only tap one stamp (the first) to avoid firing duplicates
            break
        }

        // Pause button
        seq.append((delay: 0.3, label: "PAUSE-BTN",
                    pos: CGPoint(x: pauseButtonRect.midX, y: pauseButtonRect.midY)))
        // Resume (inside overlay, requires overlay to be open)
        // Simulate open then close
        seq.append((delay: 0.5, label: "PAUSE-RESUME",
                    pos: CGPoint(x: pauseResumeRect.midX > 0 ? pauseResumeRect.midX : layout.midX,
                                 y: pauseResumeRect.midY > 0 ? pauseResumeRect.midY : layout.midY - 18)))

        var t = 1.0
        NSLog("[DLO Test] === TOUCH TARGET TEST SEQUENCE STARTING ===")
        NSLog("[DLO Test] tabTargets=\(tabTargets.count) stampTargets=\(stampTargets.count)")
        for step in seq {
            t += step.delay
            run(SKAction.sequence([
                SKAction.wait(forDuration: t),
                SKAction.run { [weak self, step] in
                    guard let self else { return }
                    let result = self.handleTap(at: step.pos)
                    let pass = result != "miss" && result != "overlay-bg"
                    NSLog("[DLO Test] %@ '%@' pos=(%d,%d) → %@ %@",
                          pass ? "PASS" : "FAIL",
                          step.label,
                          Int(step.pos.x), Int(step.pos.y),
                          result,
                          pass ? "✓" : "✗")
                }
            ]))
        }
        run(SKAction.sequence([
            SKAction.wait(forDuration: t + 0.5),
            SKAction.run { NSLog("[DLO Test] === TOUCH TARGET TEST SEQUENCE COMPLETE ===") }
        ]))
    }

    // Full Chapter 1 flow test: stamps every case with its first available action,
    // taps NEXT CASE each time, then waits for ChapterCompleteScene transition.
    private func runFullCh1Test() {
        NSLog("[DLO FlowTest] === CHAPTER 1 FULL FLOW TEST STARTING ===")
        NSLog("[DLO FlowTest] cases loaded: \(cases.count)")

        var t = 0.5  // start offset

        for caseIndex in 0..<5 {
            let stampDelay = t
            let continueDelay = t + 0.6  // wait for stamp animation

            run(SKAction.sequence([
                SKAction.wait(forDuration: stampDelay),
                SKAction.run { [weak self] in
                    guard let self else { return }
                    guard let c = self.currentCase else {
                        NSLog("[DLO FlowTest] FAIL: no current case at expected index \(caseIndex)")
                        return
                    }
                    NSLog("[DLO FlowTest] [Case \(caseIndex+1)/5] \(c.id) — stamping '\(c.availableActions[0].id)'")

                    // Switch to first tab to confirm it works
                    self.handleTap(at: CGPoint(x: self.tabTargets.first?.rect.midX ?? 86,
                                               y: self.tabTargets.first?.rect.midY ?? 258))

                    // Stamp with first available action
                    if let stampRect = self.stampTargets.first?.rect {
                        let result = self.handleTap(at: CGPoint(x: stampRect.midX, y: stampRect.midY))
                        NSLog("[DLO FlowTest] [Case \(caseIndex+1)/5] stamp → \(result)")
                    }
                }
            ]))

            run(SKAction.sequence([
                SKAction.wait(forDuration: continueDelay),
                SKAction.run { [weak self] in
                    guard let self else { return }
                    if let cr = self.continueRect {
                        let result = self.handleTap(at: CGPoint(x: cr.midX, y: cr.midY))
                        NSLog("[DLO FlowTest] [Case \(caseIndex+1)/5] continue → \(result)")
                    } else {
                        NSLog("[DLO FlowTest] FAIL: continueRect nil at case index \(caseIndex)")
                    }
                }
            ]))

            t += 1.5  // 1.5s per case
        }

        // After all cases, expect ChapterCompleteScene
        run(SKAction.sequence([
            SKAction.wait(forDuration: t + 6.0),  // extra time for glitch animation (case 5)
            SKAction.run { NSLog("[DLO FlowTest] === CHAPTER 1 FULL FLOW TEST COMPLETE — check scene transition ===") }
        ]))
    }

    // Tests that loadCases() correctly filters cases by requiredFlags.
    // Static so it can be called from any launch-arg check point (e.g. BootScene).
    static func runRequiredFlagsTest() {
        NSLog("[DLO FlagsTest] === REQUIRED FLAGS FILTER TEST STARTING ===")
        let state = GameState.shared

        // Build synthetic cases using real CaseFile structure via JSON decoding.
        // We test the filter logic directly without touching the live cases array.
        let alwaysVisible  = makeSyntheticCase(id: "test_always",  requiredFlags: nil)
        let needsFlag      = makeSyntheticCase(id: "test_flagged", requiredFlags: ["test_flag_alpha"])
        let needsMultiple  = makeSyntheticCase(id: "test_multi",   requiredFlags: ["test_flag_alpha", "test_flag_beta"])
        let needsOther     = makeSyntheticCase(id: "test_other",   requiredFlags: ["test_flag_gamma"])
        let all: [CaseFile] = [alwaysVisible, needsFlag, needsMultiple, needsOther].compactMap { $0 }

        func filtered(flags: [String]) -> [String] {
            flags.forEach { state.setFlag($0) }
            let result = all
                .filter { c in c.requiredFlags == nil || c.requiredFlags!.allSatisfy { state.hasFlag($0) } }
                .map { $0.id }
            // clean up test flags so they don't pollute real game state
            flags.forEach { state.clearFlag($0) }
            return result
        }

        // Test 1: no flags set — only always-visible case
        let t1 = filtered(flags: [])
        let pass1 = t1 == ["test_always"]
        NSLog("[DLO FlagsTest] Test 1 (no flags): %@ expected=[test_always] got=%@", pass1 ? "PASS ✓" : "FAIL ✗", t1.joined(separator: ","))

        // Test 2: one flag set — always-visible + single-flag case
        let t2 = filtered(flags: ["test_flag_alpha"])
        let pass2 = t2 == ["test_always", "test_flagged"]
        NSLog("[DLO FlagsTest] Test 2 (alpha): %@ expected=[test_always,test_flagged] got=%@", pass2 ? "PASS ✓" : "FAIL ✗", t2.joined(separator: ","))

        // Test 3: both flags — always-visible + single-flag + multi-flag cases
        let t3 = filtered(flags: ["test_flag_alpha", "test_flag_beta"])
        let pass3 = t3 == ["test_always", "test_flagged", "test_multi"]
        NSLog("[DLO FlagsTest] Test 3 (alpha+beta): %@ expected=[test_always,test_flagged,test_multi] got=%@", pass3 ? "PASS ✓" : "FAIL ✗", t3.joined(separator: ","))

        // Test 4: only gamma — only always-visible + gamma case
        let t4 = filtered(flags: ["test_flag_gamma"])
        let pass4 = t4 == ["test_always", "test_other"]
        NSLog("[DLO FlagsTest] Test 4 (gamma): %@ expected=[test_always,test_other] got=%@", pass4 ? "PASS ✓" : "FAIL ✗", t4.joined(separator: ","))

        // Test 5: verify Ch1 cases unaffected (all requiredFlags=nil → always pass)
        let ch1 = CaseFile.loadCases(forChapter: "ch1")
        let ch1Filtered = ch1.filter { c in c.requiredFlags == nil || c.requiredFlags!.allSatisfy { state.hasFlag($0) } }
        let pass5 = ch1.count == ch1Filtered.count && ch1.count == 5
        NSLog("[DLO FlagsTest] Test 5 (Ch1 unaffected): %@ expected=5 original=%d filtered=%d", pass5 ? "PASS ✓" : "FAIL ✗", ch1.count, ch1Filtered.count)

        // Test 6: Ch2 cases unaffected (all requiredFlags=nil → always pass)
        let ch2 = CaseFile.loadCases(forChapter: "ch2")
        let ch2Filtered = ch2.filter { c in c.requiredFlags == nil || c.requiredFlags!.allSatisfy { state.hasFlag($0) } }
        let pass6 = ch2.count == ch2Filtered.count && ch2.count == 3
        NSLog("[DLO FlagsTest] Test 6 (Ch2 unaffected): %@ expected=3 original=%d filtered=%d", pass6 ? "PASS ✓" : "FAIL ✗", ch2.count, ch2Filtered.count)

        let allPassed = pass1 && pass2 && pass3 && pass4 && pass5 && pass6
        NSLog("[DLO FlagsTest] === RESULT: %@ ===", allPassed ? "ALL PASS" : "FAILURES DETECTED")
    }

    static func runFollowUpFlagsTest() {
        NSLog("[DLO FollowUpTest] === FOLLOWUP FLAGS TEST STARTING ===")
        let state = GameState.shared

        // Test 1: followUpFlags on a synthetic case are applied correctly
        let json1 = """
        {"id":"t_followup","chapter":"test","senderName":"T","senderStatus":"LIVING",
         "senderCitizenID":"00-T","recipientName":"R","recipientCitizenID":"00-R",
         "messageText":"m","followUpFlags":["test_followup_alpha","test_followup_beta"],
         "documents":[],"availableActions":[],"contradictions":[],"correctLegalActionID":""}
        """
        guard let data1 = json1.data(using: .utf8),
              let testCase = try? JSONDecoder().decode(CaseFile.self, from: data1) else {
            NSLog("[DLO FollowUpTest] FAIL ✗ — could not decode synthetic case"); return
        }
        testCase.followUpFlags?.forEach { state.setFlag($0) }
        let pass1 = state.hasFlag("test_followup_alpha") && state.hasFlag("test_followup_beta")
        NSLog("[DLO FollowUpTest] Test 1 (synthetic followUpFlags applied): %@", pass1 ? "PASS ✓" : "FAIL ✗")
        state.clearFlag("test_followup_alpha")
        state.clearFlag("test_followup_beta")

        // Test 2: real Ch3 C09 cases all declare c09_processed as their followUpFlag
        let ch3 = CaseFile.loadCases(forChapter: "ch3")
        let c09cases = ch3.filter { $0.id.hasPrefix("case_ch3_001") }
        let pass2 = c09cases.count == 4 && c09cases.allSatisfy { $0.followUpFlags == ["c09_processed"] }
        NSLog("[DLO FollowUpTest] Test 2 (all 4 C09 variants have c09_processed): %@ count=%d", pass2 ? "PASS ✓" : "FAIL ✗", c09cases.count)

        // Test 3: applying any C09 case's followUpFlags sets c09_processed
        if let c09a = ch3.first(where: { $0.id == "case_ch3_001a" }) {
            c09a.followUpFlags?.forEach { state.setFlag($0) }
            let pass3 = state.hasFlag("c09_processed")
            NSLog("[DLO FollowUpTest] Test 3 (c09_processed set after C09-a): %@", pass3 ? "PASS ✓" : "FAIL ✗")
            state.clearFlag("c09_processed")
        } else {
            NSLog("[DLO FollowUpTest] Test 3 SKIP — case_ch3_001a not found")
        }

        // Test 4: level_ch3 interactables door_marr_apt and terminal_apt_main require c09_processed
        if let level = LevelData.load(id: "level_ch3") {
            let gated = level.interactables.filter { $0.requiredFlag == "c09_processed" }
            let pass4 = gated.map { $0.id }.sorted() == ["door_marr_apt", "terminal_apt_main"]
            NSLog("[DLO FollowUpTest] Test 4 (level_ch3 c09_processed interactables): %@ found=%@",
                  pass4 ? "PASS ✓" : "FAIL ✗", gated.map { $0.id }.joined(separator: ","))
        } else {
            NSLog("[DLO FollowUpTest] Test 4 SKIP — level_ch3 not found")
        }

        // Test 5: nil followUpFlags on a case does not crash (safe optional chaining)
        let json5 = """
        {"id":"t_nofollowup","chapter":"test","senderName":"T","senderStatus":"LIVING",
         "senderCitizenID":"00-T","recipientName":"R","recipientCitizenID":"00-R",
         "messageText":"m","documents":[],"availableActions":[],"contradictions":[],"correctLegalActionID":""}
        """
        if let data5 = json5.data(using: .utf8),
           let noFollowCase = try? JSONDecoder().decode(CaseFile.self, from: data5) {
            noFollowCase.followUpFlags?.forEach { state.setFlag($0) }
            NSLog("[DLO FollowUpTest] Test 5 (nil followUpFlags no crash): PASS ✓")
        }

        NSLog("[DLO FollowUpTest] === COMPLETE ===")
    }

    // Creates a minimal CaseFile for testing using JSON round-trip via Codable.
    private static func makeSyntheticCase(id: String, requiredFlags: [String]?) -> CaseFile? {
        let flagsJSON: String
        if let flags = requiredFlags {
            flagsJSON = "[" + flags.map { "\"\($0)\"" }.joined(separator: ",") + "]"
        } else {
            flagsJSON = "null"
        }
        let json = """
        {"id":"\(id)","chapter":"test","senderName":"Test","senderStatus":"LIVING",
         "senderCitizenID":"00-TEST","recipientName":"Recipient","recipientCitizenID":"00-RCPT",
         "messageText":"Test message","requiredFlags":\(flagsJSON),
         "documents":[],"availableActions":[],"contradictions":[],"correctLegalActionID":""}
        """
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CaseFile.self, from: data)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isScrollingDocument = false
        isScrollingAudit = false
    }

    // MARK: - Data Loading

    private func loadCases() {
        let state = GameState.shared
        cases = CaseFile.loadCases(forChapter: chapterID)
            .filter { !state.completedCaseIDs.contains($0.id) }
            .filter { c in c.requiredFlags == nil || c.requiredFlags!.allSatisfy { state.hasFlag($0) } }
        currentCaseIndex = 0
    }

    // MARK: - Layout

    private func buildLayout() {
        buildDesktopBackground()
        buildDocumentTray()
        buildStampArea()
        buildMessageArea()
        buildHUD()
        addChild(CRTEffectNode(size: size))
    }

    private func buildDesktopBackground() {
        let bgName = UIImage(named: "bg_terminal_wallpaper") != nil ? "bg_terminal_wallpaper"
                   : UIImage(named: "bg_desk_office") != nil        ? "bg_desk_office"
                   : nil
        if let bgName {
            let bg = SKSpriteNode(imageNamed: bgName)
            bg.size = size
            bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
            bg.zPosition = -10
            bg.alpha = 0.82
            addChild(bg)
        } else {
            buildProceduralTerminalBackground()
        }

        let statusBar = SKSpriteNode(color: .black, size: CGSize(width: size.width, height: kStatusH))
        statusBar.position = CGPoint(x: size.width / 2, y: kHudY)
        statusBar.zPosition = 5
        addChild(statusBar)

        let hudReservedW: CGFloat = 237
        let statusAvailW = layout.w - hudReservedW
        let shiftNum = chapterID.replacingOccurrences(of: "ch", with: "")
        let statusText: String
        if statusAvailW >= 220 {
            statusText = "PMCA CLERK TERMINAL  |  MARA VENN  |  SHIFT \(shiftNum)"
        } else if statusAvailW >= 100 {
            statusText = "MARA VENN  |  SHIFT \(shiftNum)"
        } else {
            statusText = "SHIFT \(shiftNum)"
        }
        let statusLabel = DLOFont.terminalLabel(text: statusText, size: 9)
        statusLabel.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
        statusLabel.position = CGPoint(x: layout.left + 12, y: kHudY)
        statusLabel.verticalAlignmentMode = .center
        statusLabel.zPosition = 6
        addChild(statusLabel)

        // Case notes button
        let notesLbl = DLOFont.terminalLabel(text: "NOTES", size: 9)
        notesLbl.fontColor = DLOColor.teal.withAlphaComponent(0.75)
        notesLbl.horizontalAlignmentMode = .right
        notesLbl.verticalAlignmentMode   = .center
        notesLbl.position   = CGPoint(x: layout.right - 72, y: kHudY)
        notesLbl.zPosition  = 6
        addChild(notesLbl)

        let btnH: CGFloat = max(kStatusH, 44)
        notebookButtonRect = CGRect(x: layout.right - 110,
                                      y: kHudY - btnH / 2,
                                      width: 52, height: btnH)

        // Pause / menu button — tap target stored in pauseButtonRect
        let menuLbl = DLOFont.terminalLabel(text: "≡ MENU", size: 9)
        menuLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.6)
        menuLbl.horizontalAlignmentMode = .right
        menuLbl.verticalAlignmentMode   = .center
        menuLbl.position   = CGPoint(x: layout.right - 4, y: kHudY)
        menuLbl.zPosition  = 6
        addChild(menuLbl)

        pauseButtonRect = CGRect(x: layout.right - 60,
                                 y: kHudY - btnH / 2,
                                 width: 60, height: btnH)
    }

    // Procedural terminal wallpaper: dark navy base + very faint horizontal scanlines.
    // The scanlines are white at 4% opacity — barely perceptible but give the screen
    // a subtle CRT texture behind all UI panels. Easy to remove if undesirable.
    private func buildProceduralTerminalBackground() {
        let base = SKSpriteNode(color: DLOColor.terminalBG, size: size)
        base.position = CGPoint(x: size.width / 2, y: size.height / 2)
        base.zPosition = -10
        addChild(base)

        // One thin line every 4pt, from bottom to top.
        // Alpha 0.04 keeps them invisible behind solid UI panels and just visible in open areas.
        let period: CGFloat = 4
        let lineColor = SKColor(white: 1.0, alpha: 0.04)
        var lineY = layout.bottom + 1
        while lineY < layout.top {
            let line = SKSpriteNode(color: lineColor, size: CGSize(width: size.width, height: 1))
            line.position = CGPoint(x: size.width / 2, y: lineY)
            line.zPosition = -9
            addChild(line)
            lineY += period
        }
    }

    private func buildDocumentTray() {
        trayArea = SKNode()
        trayArea.position = CGPoint(x: layout.left, y: layout.bottom)
        addChild(trayArea)

        docTabs = SKNode()
        docTabs.position = CGPoint(x: layout.left, y: kTabsY)
        addChild(docTabs)
    }

    private func buildStampArea() {
        stampArea = SKNode()
        stampArea.position = CGPoint(x: kStampX, y: layout.y(0.52))  // updated in buildStampButtons
        stampArea.zPosition = 10
        addChild(stampArea)

        let divider = SKSpriteNode(color: DLOColor.uiBorder,
                                   size: CGSize(width: 1, height: layout.h * 0.88))
        divider.position = CGPoint(x: kSplitX, y: layout.midY)
        addChild(divider)
        // Note: "ACTION REQUIRED" header is added in buildStampButtons so it can be positioned
        // relative to the dynamically-computed stamp area Y.
    }

    private func buildMessageArea() {
        messageArea = SKNode()
        // Anchored at the panel's left edge so the message / contradiction box spans
        // the full right-panel width, independent of where the stamp buttons sit.
        messageArea.position = CGPoint(x: kSplitX + 8, y: layout.y(0.06))
        addChild(messageArea)
    }

    private func buildHUD() {
        hudNode = SKNode()
        hudNode.zPosition = 20
        addChild(hudNode)

        let compLabel = DLOFont.terminalLabel(text: "COMP", size: 8)
        compLabel.position = CGPoint(x: layout.right - 217, y: kHudY)
        compLabel.fontColor = DLOColor.uiBorder
        compLabel.verticalAlignmentMode = .center
        hudNode.addChild(compLabel)

        complianceBar = SKSpriteNode(color: DLOColor.approveRed, size: CGSize(width: 60, height: 6))
        complianceBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        complianceBar.position = CGPoint(x: layout.right - 193, y: kHudY)
        hudNode.addChild(complianceBar)

        let suspLabel = DLOFont.terminalLabel(text: "SUSP", size: 8)
        suspLabel.position = CGPoint(x: layout.right - 129, y: kHudY)
        suspLabel.fontColor = DLOColor.uiBorder
        suspLabel.verticalAlignmentMode = .center
        hudNode.addChild(suspLabel)

        suspicionBar = SKSpriteNode(color: DLOColor.danger, size: CGSize(width: 60, height: 6))
        suspicionBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        suspicionBar.position = CGPoint(x: layout.right - 105, y: kHudY)
        hudNode.addChild(suspicionBar)
    }

    // MARK: - Case Presentation

    private func presentCurrentCase(animated: Bool = false) {
        guard let currentCase = currentCase else { allCasesDone(); return }

        clearDeskContent()
        hasStamped = false

        let docSize = CGSize(width: kDocW, height: kDocH)
        for (i, doc) in currentCase.documents.enumerated() {
            let node = DocumentNode(document: doc, size: docSize)
            node.position = CGPoint(x: 0, y: 0)
            node.alpha = i == 0 ? (animated ? 0.0 : 1.0) : 0
            node.zPosition = CGFloat(100 - i)
            trayArea.addChild(node)
            documentNodes.append(node)
        }

        buildDocumentTabs(currentCase)
        buildStampButtons(currentCase)
        buildCaseHeader(currentCase)

        showContradictionSummary(currentCase)
        updateHUD()

        if animated, let first = documentNodes.first {
            first.run(SKAction.fadeIn(withDuration: 0.25))
        }

        if chapterID == "ch1" && currentCaseIndex == 0 && !GameState.shared.hasFlag("ch1_tutorial_shown") {
            GameState.shared.setFlag("ch1_tutorial_shown")
            GameState.shared.save()
            showTutorialHint()
        }
    }

    private func buildDocumentTabs(_ caseFile: CaseFile) {
        docTabs.removeAllChildren()
        tabTargets.removeAll()

        let count  = max(caseFile.documents.count, 1)
        let tabW   = min(120, kDocW / CGFloat(count) - 4)
        // Minimum 44pt touch target height; expand upward from visual so document area isn't blocked
        let hitH   = max(kTabH, 44)
        let hitY   = kTabsY - (hitH - kTabH)   // extend hit area above the visual strip

        for (i, doc) in caseFile.documents.enumerated() {
            let isActive = i == activeDocumentIndex
            let hasSuspicious = doc.fields.contains(where: { $0.isSuspicious })
            let tab = DocumentTabNode(title: doc.title,
                                      isActive: isActive,
                                      hasSuspiciousFields: hasSuspicious,
                                      size: CGSize(width: tabW, height: kTabH))
            tab.position = CGPoint(x: CGFloat(i) * (tabW + 4), y: 0)
            docTabs.addChild(tab)

            // Hit rect in scene coordinates
            let hitX = layout.left + CGFloat(i) * (tabW + 4)
            tabTargets.append(TabTarget(
                rect: CGRect(x: hitX, y: hitY, width: tabW, height: hitH),
                index: i))
            NSLog("[DLO Layout] tab[\(i)] '\(doc.title)' rect=(\(Int(hitX)),\(Int(hitY)),\(Int(tabW)),\(Int(hitH)))")
        }
    }

    private func switchToDocument(at index: Int) {
        guard documentNodes.indices.contains(index) else { return }
        documentNodes.forEach { $0.alpha = 0 }
        documentNodes[index].alpha = 0
        documentNodes[index].run(SKAction.fadeIn(withDuration: 0.07))
        activeDocumentIndex = index
        if let caseFile = currentCase, caseFile.documents.indices.contains(index) {
            NotebookManager.onDeskDocumentOpened(
                documentID: caseFile.documents[index].id, caseID: caseFile.id)
            buildDocumentTabs(caseFile)
        }
        AudioManager.shared.playPageTurn(on: self)
    }

    private func buildStampButtons(_ caseFile: CaseFile) {
        stampArea.removeAllChildren()
        stampButtons.removeAll()
        stampTargets.removeAll()

        let count = CGFloat(caseFile.availableActions.count)
        let headerY = layout.y(0.80)
        let topPad: CGFloat = 14              // gap between header and first button top
        let maxTopCenter = headerY - topPad - 23  // center of first button must be below header
        let bottomMargin: CGFloat = layout.bottom + 8

        // Compute spacing: reduce step if needed to keep all buttons within bounds
        let maxStep: CGFloat = 56
        let minStep: CGFloat = 46             // minimum gap (touching buttons)
        let step: CGFloat
        if count <= 1 {
            step = maxStep
        } else {
            let available = maxTopCenter - (bottomMargin + 23)   // space between centers
            let naturalStep = available / (count - 1)
            step = max(minStep, min(maxStep, naturalStep))
        }

        // Place first button at the highest allowed position
        let stampAreaY = maxTopCenter
        stampArea.position.y = stampAreaY

        // "ACTION REQUIRED" header — centred over the stamp button column.
        let hdr = DLOFont.terminalLabel(text: "ACTION REQUIRED", size: 9)
        hdr.horizontalAlignmentMode = .center
        hdr.position = CGPoint(x: kStampX, y: headerY)
        hdr.fontColor = DLOColor.uiBorder
        addChild(hdr)
        actionRequiredNode = hdr

        var yOffset: CGFloat = 0
        for action in caseFile.availableActions {
            let btn = StampButtonNode(action: action, size: CGSize(width: 180, height: 46))
            btn.position = CGPoint(x: 0, y: yOffset)
            stampArea.addChild(btn)
            stampButtons.append(btn)

            // Hit rect in scene coordinates
            let centerY = stampAreaY + yOffset
            let hitH: CGFloat = max(46, 44)
            let rect = CGRect(x: kStampX - 90, y: centerY - hitH / 2, width: 180, height: hitH)
            stampTargets.append(StampTarget(rect: rect, action: action))
            NSLog("[DLO Layout] stamp '\(action.id)' rect=(\(Int(rect.minX)),\(Int(rect.minY)),\(Int(rect.width)),\(Int(rect.height)))")

            yOffset -= step
        }
    }

    private func buildCaseHeader(_ caseFile: CaseFile) {
        caseHeaderNode?.removeFromParent()
        let hdr = DLOFont.terminalLabel(
            text: "CASE \(caseFile.id.uppercased())  |  SENDER: \(caseFile.senderName)  |  STATUS: \(caseFile.senderStatus)",
            size: 9)
        hdr.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.8)
        hdr.position = CGPoint(x: layout.left + 12, y: layout.bottom + layout.h * 0.02)
        hdr.zPosition = 8
        addChild(hdr)
        caseHeaderNode = hdr
    }

    private func clearDeskContent() {
        documentNodes.forEach { $0.removeFromParent() }
        documentNodes.removeAll()
        activeDocumentIndex = 0
        stampButtons.removeAll()
        stampTargets.removeAll()
        stampArea.removeAllChildren()
        docTabs.removeAllChildren()
        tabTargets.removeAll()
        messageArea.removeAllChildren()
        caseHeaderNode?.removeFromParent()
        caseHeaderNode = nil
        actionRequiredNode?.removeFromParent()
        actionRequiredNode = nil
        clearContinueButton()
        hideAuditOverlay()
        hideResultPanel()
        auditButtonRect = .zero
    }

    // MARK: - Tutorial

    private func showTutorialHint() {
        let hints = [
            "READ EACH DOCUMENT TAB",
            "◆ DOTS MARK SUSPICIOUS FIELDS",
            "TAP AUDIT LOG TO REVIEW ANOMALIES",
            "THEN CHOOSE AN ACTION"
        ]
        var delay: TimeInterval = 1.2
        for hint in hints {
            let lbl = DLOFont.terminalLabel(text: hint, size: 9)
            lbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.0)
            lbl.horizontalAlignmentMode = .center
            lbl.position = CGPoint(x: layout.left + kDocW / 2, y: layout.y(0.50))
            lbl.zPosition = 50
            addChild(lbl)
            lbl.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.fadeAlpha(to: 0.55, duration: 0.4),
                SKAction.wait(forDuration: 2.5),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
            delay += 3.6
        }
    }

    // MARK: - Action Handling

    private func performAction(_ action: CaseAction, for caseFile: CaseFile) {
        guard !hasStamped else { return }
        hasStamped = true

        GameState.shared.applyConsequences(action.consequences)
        caseFile.followUpFlags?.forEach { GameState.shared.setFlag($0) }
        GameState.shared.recordDecision(caseID: caseFile.id, actionID: action.id)
        GameState.shared.save()
        NSLog("[DLO State] case=\(caseFile.id) action=\(action.id) compliance=\(GameState.shared.complianceScore) suspicion=\(GameState.shared.suspicionScore)")

        playStampAnimation(label: action.shortLabel, color: .fromHex(action.color))
        AudioManager.shared.playStamp(on: self)
        updateHUD()

        let isChapterCulmination = action.consequences.flagsSet?.contains("ch1_chapter_complete") == true
        let nextAction: () -> Void = isChapterCulmination
            ? { [weak self] in self?.playChapterCulminationGlitch() }
            : { [weak self] in self?.continueAfterCaseAction(caseFile: caseFile, action: action) }

        // Show result as a readable overlay over the document area instead of the
        // right panel — cleaner, not obscured by stamp buttons or Next Case.
        showActionResultPanel(text: action.resultText,
                              color: .fromHex(action.color),
                              auditResponse: action.auditResponse,
                              onContinue: nextAction)
    }

    private struct PendingDeskDialogue {
        let dialogueID: String
        let startNodeID: String
        let returnScene: SceneType
    }

    private func pendingDialogueAfterStamp(caseFile: CaseFile, action: CaseAction) -> PendingDeskDialogue? {
        if chapterID == "ch3",
           caseFile.id.hasPrefix("case_ch3_001"),
           GameState.shared.hasFlag("c09_processed"),
           !GameState.shared.hasFlag("ch3_c09_note_shown") {
            return PendingDeskDialogue(
                dialogueID: "intro_ch3",
                startNodeID: "n1",
                returnScene: .desk(chapterID: "ch3"))
        }

        if chapterID == "ch3",
           caseFile.id == "case_ch3_003",
           action.consequences.flagsSet?.contains("ch3_desk_complete") == true,
           !GameState.shared.hasFlag("ch3_outro_complete") {
            let platformLevelID = "level_ch3"
            let nextScene: SceneType
            if LevelData.load(id: platformLevelID) != nil,
               !GameState.shared.completedLevelIDs.contains(platformLevelID) {
                nextScene = .chapterComplete(chapterID: "ch3",
                                             nextScene: .platform(levelID: platformLevelID))
            } else {
                nextScene = resolveNextScene(afterDeskFor: "ch3")
            }
            return PendingDeskDialogue(
                dialogueID: "intro_ch3",
                startNodeID: "n2",
                returnScene: nextScene)
        }

        return nil
    }

    private func continueAfterCaseAction(caseFile: CaseFile, action: CaseAction) {
        if let pending = pendingDialogueAfterStamp(caseFile: caseFile, action: action) {
            SceneManager.shared.transition(
                to: .dialogue(dialogueID: pending.dialogueID,
                              returnScene: pending.returnScene,
                              startNodeID: pending.startNodeID),
                from: self)
            return
        }
        advanceCase()
    }

    private func playChapterCulminationGlitch() {
        let glitchNode = SKNode()
        glitchNode.zPosition = 600
        addChild(glitchNode)

        let flash = SKSpriteNode(color: .white, size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.alpha = 0
        glitchNode.addChild(flash)

        let glitchLabel = SKLabelNode(text: "I AM NOT DEAD")
        glitchLabel.fontName = "Menlo-Bold"
        glitchLabel.fontSize = 36
        glitchLabel.fontColor = DLOColor.danger
        glitchLabel.horizontalAlignmentMode = .center
        glitchLabel.verticalAlignmentMode = .center
        glitchLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        glitchLabel.alpha = 0
        glitchNode.addChild(glitchLabel)

        let auditLabel = DLOFont.terminalLabel(
            text: "SYSTEM: ANOMALOUS MESSAGE DETECTED. ORIGIN UNVERIFIABLE. SESSION FLAGGED.", size: 9)
        auditLabel.horizontalAlignmentMode = .center
        auditLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        auditLabel.fontColor = DLOColor.terminalAmber
        auditLabel.alpha = 0
        glitchNode.addChild(auditLabel)

        let seq = SKAction.sequence([
            SKAction.run { flash.run(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.6, duration: 0.05),
                SKAction.fadeAlpha(to: 0.0, duration: 0.1)
            ])) },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { glitchLabel.alpha = 1 },
            SKAction.wait(forDuration: 0.05),
            SKAction.run { glitchLabel.alpha = 0 },
            SKAction.wait(forDuration: 0.05),
            SKAction.run { glitchLabel.alpha = 1 },
            SKAction.wait(forDuration: 0.08),
            SKAction.run { glitchLabel.alpha = 0 },
            SKAction.wait(forDuration: 0.12),
            SKAction.run { glitchLabel.alpha = 1 },
            SKAction.wait(forDuration: 1.2),
            SKAction.run { auditLabel.run(SKAction.fadeIn(withDuration: 0.4)) },
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                glitchNode.removeFromParent()
                self?.allCasesDone()
            }
        ])
        run(seq)
    }

    private func playStampAnimation(label: String, color: SKColor) {
        // Add stamp to scene (not trayArea) so it cannot be clipped by trayArea edges.
        // Centre on the visible document area in scene coordinates.
        let stampLbl = SKLabelNode(text: label)
        stampLbl.fontName = "Menlo-Bold"
        stampLbl.fontSize = 42
        stampLbl.fontColor = color.withAlphaComponent(0.85)
        stampLbl.zRotation = CGFloat.random(in: -0.22...0.22)
        let centerX = layout.left + kDocW * 0.5
        let centerY = layout.bottom + kDocH * 0.46
        stampLbl.position   = CGPoint(x: centerX, y: centerY)
        stampLbl.zPosition  = 200
        stampLbl.setScale(2.5)
        addChild(stampLbl)   // scene level — no left-edge clip

        stampLbl.run(SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.12),
            SKAction.wait(forDuration: 1.4),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))

        if !GameState.shared.reducedFlashingEnabled {
            let flash = SKSpriteNode(color: color.withAlphaComponent(0.15), size: size)
            flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
            flash.zPosition = 500
            addChild(flash)
            flash.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.08),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Action Result Overlay (over left doc area, replaces right-panel showMessage after stamp)

    private func showActionResultPanel(text: String, color: SKColor,
                                       auditResponse: String?,
                                       onContinue: @escaping () -> Void) {
        resultPanel?.removeFromParent()

        let panelW = kDocW - 20
        let panelH = min(layout.h * 0.58, 240)
        let panelX = layout.left + kDocW / 2
        let panelY = layout.midY

        let panel = SKNode()
        panel.zPosition = 250
        panel.alpha = 0

        let bg = SKSpriteNode(color: DLOColor.terminalBG.withAlphaComponent(0.97),
                              size: CGSize(width: panelW, height: panelH))
        bg.position = CGPoint(x: panelX, y: panelY)
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: panelH - 2),
                                 cornerRadius: 4)
        border.strokeColor = color.withAlphaComponent(0.80)
        border.lineWidth   = 1.8
        border.fillColor   = .clear
        border.position    = CGPoint(x: panelX, y: panelY)
        panel.addChild(border)

        // Header strip
        let headerH: CGFloat = 24
        let headerBG = SKSpriteNode(color: color.withAlphaComponent(0.18),
                                    size: CGSize(width: panelW, height: headerH))
        headerBG.position = CGPoint(x: panelX, y: panelY + panelH / 2 - headerH / 2)
        panel.addChild(headerBG)

        let headerLbl = DLOFont.terminalLabel(text: "PMCA — ACTION RECORDED", size: 9)
        headerLbl.horizontalAlignmentMode = .center
        headerLbl.fontColor = color
        headerLbl.position  = headerBG.position
        panel.addChild(headerLbl)

        // Result text
        let mult = GameState.shared.textSizeMultiplier
        let resultLbl = SKLabelNode(text: text)
        resultLbl.fontName = "Menlo"
        resultLbl.fontSize = 11 * mult
        resultLbl.fontColor = color
        resultLbl.horizontalAlignmentMode = .center
        resultLbl.verticalAlignmentMode   = .top
        resultLbl.numberOfLines = 0
        resultLbl.preferredMaxLayoutWidth = panelW - 24
        resultLbl.position = CGPoint(x: panelX, y: panelY + panelH / 2 - headerH - 14)
        panel.addChild(resultLbl)

        // Audit response (if any)
        if let audit = auditResponse {
            let divY = panelY + panelH / 2 - headerH - 54
            let divider = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.3),
                                       size: CGSize(width: panelW - 24, height: 1))
            divider.position = CGPoint(x: panelX, y: divY)
            panel.addChild(divider)

            let tagLbl = DLOFont.terminalLabel(text: "AUDIT LOG:", size: 8.5)
            tagLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.55)
            tagLbl.horizontalAlignmentMode = .left
            tagLbl.position = CGPoint(x: panelX - panelW / 2 + 12, y: divY - 14)
            panel.addChild(tagLbl)

            let auditLbl = SKLabelNode(text: audit)
            auditLbl.fontName = "Menlo"
            auditLbl.fontSize = 9.5 * mult
            auditLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.80)
            auditLbl.horizontalAlignmentMode = .left
            auditLbl.verticalAlignmentMode   = .top
            auditLbl.numberOfLines = 0
            auditLbl.preferredMaxLayoutWidth = panelW - 24
            auditLbl.position = CGPoint(x: panelX - panelW / 2 + 12, y: divY - 30)
            panel.addChild(auditLbl)
        }

        // NEXT CASE button anchored at panel bottom
        let btnH: CGFloat = 38
        let btnW: CGFloat = panelW - 24
        let btnX = panelX
        let btnY = panelY - panelH / 2 + btnH / 2 + 10

        let btnBG = SKShapeNode(rectOf: CGSize(width: btnW, height: btnH), cornerRadius: 4)
        btnBG.fillColor   = DLOColor.terminalAmber.withAlphaComponent(0.12)
        btnBG.strokeColor = DLOColor.terminalAmber.withAlphaComponent(0.70)
        btnBG.lineWidth   = 1.2
        btnBG.position    = CGPoint(x: btnX, y: btnY)
        panel.addChild(btnBG)

        let btnLbl = DLOFont.terminalLabel(text: "▶  NEXT CASE", size: 11)
        btnLbl.horizontalAlignmentMode = .center
        btnLbl.fontColor = DLOColor.terminalAmber
        btnLbl.position  = CGPoint(x: btnX, y: btnY - 3)
        panel.addChild(btnLbl)

        let hitH: CGFloat = max(btnH, 44)
        resultContinueRect   = CGRect(x: btnX - btnW / 2, y: btnY - hitH / 2,
                                      width: btnW, height: hitH)
        resultContinueAction = onContinue

        addChild(panel)
        resultPanel = panel
        // Delay so stamp animation is visible first
        panel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.45),
            SKAction.fadeIn(withDuration: 0.2)
        ]))
    }

    private func hideResultPanel() {
        resultPanel?.removeFromParent()
        resultPanel = nil
        resultContinueRect   = .zero
        resultContinueAction = nil
    }

    // Shows a compact anomaly indicator + AUDIT LOG button in the right panel.
    // Full details are in the dedicated audit overlay (showAuditOverlay).
    private func showContradictionSummary(_ caseFile: CaseFile) {
        messageArea.removeAllChildren()
        auditButtonRect = .zero

        guard !caseFile.contradictions.isEmpty else {
            showMessage(
                currentCaseIndex == 0
                    ? "TAP A DOCUMENT TAB TO READ  |  THEN CHOOSE AN ACTION"
                    : "REVIEW DOCUMENTS. COMPARE FOR DISCREPANCIES. SELECT AN ACTION.",
                color: DLOColor.uiBorder)
            return
        }

        let msgW   = kMsgW
        let panelH: CGFloat = 56

        let bg = SKSpriteNode(color: .black, size: CGSize(width: msgW, height: panelH))
        bg.position = CGPoint(x: msgW / 2, y: panelH / 2)
        messageArea.addChild(bg)

        let count = caseFile.contradictions.count
        let critCount = caseFile.contradictions.filter { $0.isCritical }.count
        let headerText = critCount > 0
            ? "◆ \(count) ANOMAL\(count == 1 ? "Y" : "IES")  [\(critCount) CRITICAL]"
            : "◇ \(count) ANOMAL\(count == 1 ? "Y" : "IES") DETECTED"

        let hdr = DLOFont.terminalLabel(text: headerText, size: 9)
        hdr.fontColor = critCount > 0
            ? DLOColor.terminalAmber.withAlphaComponent(0.9)
            : DLOColor.uiBorder.withAlphaComponent(0.8)
        hdr.horizontalAlignmentMode = .center
        hdr.position = CGPoint(x: msgW / 2, y: panelH - 14)
        messageArea.addChild(hdr)

        let sep = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.2),
                               size: CGSize(width: msgW - 8, height: 1))
        sep.anchorPoint = CGPoint(x: 0, y: 0.5)
        sep.position = CGPoint(x: 4, y: panelH - 24)
        messageArea.addChild(sep)

        // AUDIT LOG button
        let btnBG = SKShapeNode(rectOf: CGSize(width: msgW - 14, height: 22), cornerRadius: 3)
        btnBG.fillColor = DLOColor.terminalAmber.withAlphaComponent(0.08)
        btnBG.strokeColor = DLOColor.terminalAmber.withAlphaComponent(0.45)
        btnBG.lineWidth = 1
        btnBG.position = CGPoint(x: msgW / 2, y: 13)
        messageArea.addChild(btnBG)

        let btnLbl = DLOFont.terminalLabel(text: "▶  AUDIT LOG", size: 10)
        btnLbl.fontColor = DLOColor.terminalAmber
        btnLbl.horizontalAlignmentMode = .center
        btnLbl.position = CGPoint(x: msgW / 2, y: 13)
        messageArea.addChild(btnLbl)

        // Hit rect in scene coordinates (messageArea anchored at kSplitX+8, layout.y(0.06))
        let baseX = kSplitX + 8
        let baseY = layout.y(0.06)
        let hitH: CGFloat = max(30, 44)
        auditButtonRect = CGRect(x: baseX + 4, y: baseY + 13 - hitH / 2,
                                 width: msgW - 8, height: hitH)
        NSLog("[DLO Layout] auditButtonRect=\(auditButtonRect)")
    }

    // MARK: - Audit Analysis Overlay

    private func showAuditOverlay(for caseFile: CaseFile) {
        guard auditOverlay == nil else { return }

        let overlay = SKNode()
        overlay.zPosition = 700
        overlay.alpha = 0

        // Dim background
        let dim = SKSpriteNode(color: .black.withAlphaComponent(0.78),
                               size: CGSize(width: size.width, height: size.height))
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.addChild(dim)

        let panelW = layout.w * 0.90
        let panelH = layout.h * 0.86
        let panelX = layout.midX
        let panelY = layout.midY

        let panelBG = SKSpriteNode(color: DLOColor.terminalBG,
                                   size: CGSize(width: panelW, height: panelH))
        panelBG.position = CGPoint(x: panelX, y: panelY)
        overlay.addChild(panelBG)

        let panelBorder = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 4)
        panelBorder.strokeColor = DLOColor.uiBorder
        panelBorder.lineWidth = 1.5
        panelBorder.fillColor = .clear
        panelBorder.position = CGPoint(x: panelX, y: panelY)
        overlay.addChild(panelBorder)

        // Header strip
        let headerH: CGFloat = 28
        let headerBG = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.12),
                                    size: CGSize(width: panelW, height: headerH))
        headerBG.position = CGPoint(x: panelX, y: panelY + panelH / 2 - headerH / 2)
        overlay.addChild(headerBG)

        let hdrLbl = DLOFont.titleLabel(text: "AUDIT ANALYSIS", size: 14)
        hdrLbl.position = CGPoint(x: panelX, y: panelY + panelH / 2 - headerH / 2)
        overlay.addChild(hdrLbl)

        // Case ref
        let count = caseFile.contradictions.count
        let refLbl = DLOFont.terminalLabel(
            text: "CASE: \(caseFile.id.uppercased())  |  \(count) ANOMAL\(count == 1 ? "Y" : "IES") DETECTED",
            size: 10)
        refLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
        refLbl.horizontalAlignmentMode = .center
        refLbl.position = CGPoint(x: panelX, y: panelY + panelH / 2 - headerH - 16)
        overlay.addChild(refLbl)

        let refDiv = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.3),
                                  size: CGSize(width: panelW - 24, height: 1))
        refDiv.position = CGPoint(x: panelX, y: panelY + panelH / 2 - headerH - 30)
        overlay.addChild(refDiv)

        // CLOSE button strip at bottom
        let closeStripH: CGFloat = 36
        let closeStripY = panelY - panelH / 2 + closeStripH / 2

        let closeBG = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.08),
                                   size: CGSize(width: panelW, height: closeStripH))
        closeBG.position = CGPoint(x: panelX, y: closeStripY)
        overlay.addChild(closeBG)

        let closeLbl = DLOFont.terminalLabel(text: "[ CLOSE AUDIT LOG ]", size: 11)
        closeLbl.fontColor = DLOColor.terminalAmber
        closeLbl.horizontalAlignmentMode = .center
        closeLbl.position = CGPoint(x: panelX, y: closeStripY)
        overlay.addChild(closeLbl)

        let closeHitH: CGFloat = max(closeStripH, 44)
        auditCloseRect = CGRect(x: panelX - panelW / 2,
                                y: closeStripY - closeHitH / 2,
                                width: panelW, height: closeHitH)

        // Scrollable content area
        let contentTopY    = panelY + panelH / 2 - headerH - 34   // below refDiv
        let contentBotY    = panelY - panelH / 2 + closeStripH + 4
        let scrollH        = contentTopY - contentBotY
        let scrollCenterY  = (contentTopY + contentBotY) / 2
        let contentPad:    CGFloat = 10
        let contentViewW   = panelW - 28
        auditViewH = scrollH

        let cropMask = SKSpriteNode(color: .white,
                                    size: CGSize(width: contentViewW, height: scrollH))
        let crop = SKCropNode()
        crop.maskNode = cropMask
        crop.position = CGPoint(x: panelX, y: scrollCenterY)
        overlay.addChild(crop)

        let contentHolder = SKNode()
        crop.addChild(contentHolder)
        auditContentNode = contentHolder
        auditScrollOffset = 0
        contentHolder.position.y = 0

        // Build anomaly entries top-to-bottom in contentHolder's local coords
        // Origin of contentHolder is at crop.position (scrollCenterY); y=scrollH/2 is the top.
        let mult = GameState.shared.textSizeMultiplier
        let anomalyFS:   CGFloat = 11 * mult
        let lineStep:    CGFloat = anomalyFS * 1.55
        let charW:       CGFloat = anomalyFS * 0.62
        let textAreaW    = contentViewW - contentPad * 2
        let charsPerLine = max(1, Int(textAreaW / charW))
        let leftX        = -contentViewW / 2 + contentPad
        var cy: CGFloat  = scrollH / 2 - contentPad

        for (i, c) in caseFile.contradictions.enumerated() {
            let isCrit  = c.isCritical
            let dotChar = isCrit ? "◆" : "◇"
            let dotCol: SKColor = isCrit ? DLOColor.terminalAmber : DLOColor.uiBorder

            // Anomaly label
            let anomLbl = DLOFont.terminalLabel(
                text: "\(dotChar) ANOMALY \(i + 1)\(isCrit ? "  [CRITICAL]" : "")", size: 9.5)
            anomLbl.fontColor = dotCol
            anomLbl.horizontalAlignmentMode = .left
            anomLbl.position = CGPoint(x: leftX, y: cy)
            contentHolder.addChild(anomLbl)
            cy -= lineStep

            // Field A
            let aLbl = SKLabelNode(text: "A: " + c.fieldA)
            aLbl.fontName = "Menlo"
            aLbl.fontSize = anomalyFS - 1
            aLbl.fontColor = DLOColor.bodyText.withAlphaComponent(0.65)
            aLbl.horizontalAlignmentMode = .left
            aLbl.verticalAlignmentMode = .top
            aLbl.numberOfLines = 0
            aLbl.preferredMaxLayoutWidth = textAreaW
            aLbl.position = CGPoint(x: leftX + 8, y: cy)
            contentHolder.addChild(aLbl)
            let aLines = max(1, (3 + c.fieldA.count + charsPerLine - 1) / charsPerLine)
            cy -= CGFloat(aLines) * (anomalyFS - 1) * 1.5

            // Field B
            let bLbl = SKLabelNode(text: "B: " + c.fieldB)
            bLbl.fontName = "Menlo"
            bLbl.fontSize = anomalyFS - 1
            bLbl.fontColor = DLOColor.bodyText.withAlphaComponent(0.65)
            bLbl.horizontalAlignmentMode = .left
            bLbl.verticalAlignmentMode = .top
            bLbl.numberOfLines = 0
            bLbl.preferredMaxLayoutWidth = textAreaW
            bLbl.position = CGPoint(x: leftX + 8, y: cy)
            contentHolder.addChild(bLbl)
            let bLines = max(1, (3 + c.fieldB.count + charsPerLine - 1) / charsPerLine)
            cy -= CGFloat(bLines) * (anomalyFS - 1) * 1.5

            // Description
            let descLbl = SKLabelNode(text: c.description)
            descLbl.fontName = "Menlo"
            descLbl.fontSize = anomalyFS
            descLbl.fontColor = dotCol.withAlphaComponent(0.9)
            descLbl.horizontalAlignmentMode = .left
            descLbl.verticalAlignmentMode = .top
            descLbl.numberOfLines = 0
            descLbl.preferredMaxLayoutWidth = textAreaW
            descLbl.position = CGPoint(x: leftX + 8, y: cy)
            contentHolder.addChild(descLbl)
            let dLines = max(1, (c.description.count + charsPerLine - 1) / charsPerLine)
            cy -= CGFloat(dLines) * lineStep

            if i < caseFile.contradictions.count - 1 {
                cy -= 4
                let sep = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.2),
                                       size: CGSize(width: contentViewW - 16, height: 1))
                sep.position = CGPoint(x: 0, y: cy)
                contentHolder.addChild(sep)
                cy -= 10
            }
        }

        auditContentH = (scrollH / 2 - contentPad) - cy

        // Scroll hint when content overflows
        if auditContentH > scrollH - 10 {
            let hint = DLOFont.terminalLabel(text: "▲ drag to scroll ▼", size: 8)
            hint.fontColor = DLOColor.uiBorder.withAlphaComponent(0.45)
            hint.horizontalAlignmentMode = .center
            hint.position = CGPoint(x: panelX, y: closeStripY + closeStripH / 2 + 8)
            overlay.addChild(hint)
        }

        addChild(overlay)
        auditOverlay = overlay
        overlay.run(SKAction.fadeIn(withDuration: 0.15))
    }

    private func hideAuditOverlay() {
        guard let overlay = auditOverlay else { return }
        auditOverlay = nil
        auditContentNode = nil
        auditCloseRect = .zero
        isScrollingAudit = false
        auditScrollOffset = 0
        overlay.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }

    private func scrollAuditContent(delta: CGFloat) {
        guard let content = auditContentNode else { return }
        let maxScroll = max(0, auditContentH - auditViewH)
        auditScrollOffset = (auditScrollOffset + delta).clamped(to: 0...maxScroll)
        content.position.y = auditScrollOffset
    }

    private func showMessage(_ text: String, color: SKColor = DLOColor.terminalAmber,
                             auditResponse: String? = nil) {
        messageArea.removeAllChildren()
        auditButtonRect = .zero

        let mult = GameState.shared.textSizeMultiplier
        let msgW = kMsgW  // full right-panel width, anchored from kSplitX
        let totalHeight: CGFloat = auditResponse != nil ? 90 : 66
        let bg = SKSpriteNode(color: .black, size: CGSize(width: msgW, height: totalHeight))
        bg.position = CGPoint(x: msgW / 2, y: totalHeight / 2)
        messageArea.addChild(bg)

        var yOffset: CGFloat = totalHeight - 10

        if let audit = auditResponse {
            let auditTag = SKLabelNode(text: "AUDIT LOG:")
            auditTag.fontName = "Menlo-Bold"
            auditTag.fontSize = 9 * mult
            auditTag.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.5)
            auditTag.horizontalAlignmentMode = .left
            auditTag.verticalAlignmentMode = .top
            auditTag.position = CGPoint(x: 4, y: yOffset)
            messageArea.addChild(auditTag)
            yOffset -= 16

            let auditLbl = SKLabelNode(text: audit)
            auditLbl.fontName = "Menlo"
            auditLbl.fontSize = 9 * mult
            auditLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
            auditLbl.horizontalAlignmentMode = .left
            auditLbl.verticalAlignmentMode = .top
            auditLbl.numberOfLines = 0
            auditLbl.preferredMaxLayoutWidth = msgW - 8
            auditLbl.position = CGPoint(x: 4, y: yOffset)
            messageArea.addChild(auditLbl)
            yOffset -= 24

            let divider = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                                       size: CGSize(width: msgW - 8, height: 1))
            divider.anchorPoint = CGPoint(x: 0, y: 0.5)
            divider.position = CGPoint(x: 4, y: yOffset)
            messageArea.addChild(divider)
            yOffset -= 8
        }

        let lbl = SKLabelNode(text: text)
        lbl.fontName = "Menlo"
        lbl.fontSize = 10 * mult
        lbl.fontColor = color
        lbl.horizontalAlignmentMode = .left
        lbl.verticalAlignmentMode = .top
        lbl.numberOfLines = 0
        lbl.preferredMaxLayoutWidth = msgW - 8
        lbl.position = CGPoint(x: 4, y: yOffset)
        messageArea.addChild(lbl)
    }

    private func updateHUD() {
        let state = GameState.shared
        let maxScore: CGFloat = 30
        complianceBar.size.width = max(2, min(CGFloat(state.complianceScore) / maxScore, 1.0) * 60)
        suspicionBar.size.width  = max(2, min(CGFloat(state.suspicionScore)  / maxScore, 1.0) * 60)
    }

    private func showContinueButton(action: @escaping () -> Void) {
        clearContinueButton()

        // Button spans the full right panel, aligned with the message/contradiction box.
        let msgW    = kMsgW
        let btnW    = msgW - 8
        let centerX = kSplitX + 8 + btnW / 2
        let centerY = layout.y(0.14)

        let btn = DeskContinueButtonNode(width: btnW)
        btn.position = CGPoint(x: centerX, y: centerY)
        btn.zPosition = 30
        btn.alpha = 0
        btn.run(SKAction.fadeIn(withDuration: 0.2))
        addChild(btn)
        continueButtonNode = btn

        let hitH: CGFloat = max(DeskContinueButtonNode.height, 44)
        continueRect   = CGRect(x: centerX - btnW / 2, y: centerY - hitH / 2,
                                width: btnW, height: hitH)
        continueAction = action
        NSLog("[DLO Layout] continueRect=\(continueRect!)")
    }

    private func clearContinueButton() {
        continueButtonNode?.removeFromParent()
        continueButtonNode = nil
        continueRect   = nil
        continueAction = nil
    }

    // MARK: - Case Flow

    private func advanceCase() {
        currentCaseIndex += 1
        if currentCase != nil {
            presentCurrentCase(animated: true)
        } else {
            allCasesDone()
        }
    }

    private func allCasesDone() {
        clearDeskContent()
        GameState.shared.save()

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let nextScene = self.resolveNextScene(afterDeskFor: self.chapterID)
                SceneManager.shared.transition(
                    to: .chapterComplete(chapterID: self.chapterID, nextScene: nextScene),
                    from: self)
            }
        ]))
    }

    // MARK: - Notebook Overlay

    private func showNotebookOverlay() {
        guard notebookOverlay == nil else { return }
        let built = NotebookManager.makeDeskPDAPanel(layout: layout, chapter: chapterID) { [weak self] in
            self?.hideNotebookOverlay()
        }
        built.panel.zPosition = 850
        built.panel.alpha = 0
        addChild(built.panel)
        notebookOverlay = built.panel
        notebookScrollState = built.scrollState
        built.panel.run(SKAction.fadeIn(withDuration: 0.12))
    }

    private func hideNotebookOverlay() {
        guard let overlay = notebookOverlay else { return }
        notebookOverlay = nil
        notebookScrollState = nil
        notebookScrollTouch = nil
        overlay.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Pause Overlay

    private func showPauseOverlay() {
        guard pauseOverlay == nil else { return }

        let overlay = SKNode()
        overlay.zPosition = 800

        let dim = SKSpriteNode(color: .black.withAlphaComponent(0.7),
                               size: CGSize(width: size.width, height: size.height))
        dim.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.zPosition = 0
        overlay.addChild(dim)

        let panelW = min(layout.w * 0.55, layout.w)
        let panelH = layout.h * 0.50
        let panelBG = SKSpriteNode(color: DLOColor.terminalBG,
                                   size: CGSize(width: panelW, height: panelH))
        panelBG.position  = layout.center
        panelBG.zPosition = 1
        overlay.addChild(panelBG)

        let border = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 4)
        border.strokeColor = DLOColor.uiBorder
        border.lineWidth   = 1.5
        border.fillColor   = .clear
        border.position    = layout.center
        border.zPosition   = 2
        overlay.addChild(border)

        let header = DLOFont.titleLabel(text: "— SHIFT PAUSED —", size: 18)
        header.position  = CGPoint(x: layout.midX, y: layout.midY + panelH * 0.24)
        header.zPosition = 3
        overlay.addChild(header)

        let divider = SKSpriteNode(color: DLOColor.uiBorder,
                                   size: CGSize(width: panelW * 0.7, height: 1))
        divider.position  = CGPoint(x: layout.midX, y: layout.midY + panelH * 0.06)
        divider.zPosition = 3
        overlay.addChild(divider)

        let resumeY = layout.midY - panelH * 0.12
        let exitY   = layout.midY - panelH * 0.30

        let resumeLbl = DLOFont.terminalLabel(text: "> RESUME SHIFT", size: 13)
        resumeLbl.fontColor = DLOColor.terminalAmber
        resumeLbl.horizontalAlignmentMode = .center
        resumeLbl.position  = CGPoint(x: layout.midX, y: resumeY)
        resumeLbl.zPosition = 3
        overlay.addChild(resumeLbl)

        let exitLbl = DLOFont.terminalLabel(text: "> EXIT TO MAIN MENU", size: 13)
        exitLbl.fontColor = DLOColor.danger
        exitLbl.horizontalAlignmentMode = .center
        exitLbl.position  = CGPoint(x: layout.midX, y: exitY)
        exitLbl.zPosition = 3
        overlay.addChild(exitLbl)

        // Store hit rects (scene coordinates) — no PauseBlocker needed
        let hitW = max(panelW * 0.7, 150)
        pauseResumeRect = CGRect(x: layout.midX - hitW / 2, y: resumeY - 22,
                                 width: hitW, height: 44)
        pauseExitRect   = CGRect(x: layout.midX - hitW / 2, y: exitY - 22,
                                 width: hitW, height: 44)
        NSLog("[DLO Layout] pauseResumeRect=\(pauseResumeRect) pauseExitRect=\(pauseExitRect)")

        overlay.alpha = 0
        addChild(overlay)
        pauseOverlay = overlay
        overlay.run(SKAction.fadeIn(withDuration: 0.15))
    }

    private func hidePauseOverlay() {
        guard let overlay = pauseOverlay else { return }
        pauseOverlay = nil
        pauseResumeRect = .zero
        pauseExitRect   = .zero
        overlay.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Chapter Resolution

    private func resolveNextScene(afterDeskFor chapterID: String) -> SceneType {
        let platformLevelID = "level_\(chapterID)"
        if LevelData.load(id: platformLevelID) != nil
            && !GameState.shared.completedLevelIDs.contains(platformLevelID) {
            return .platform(levelID: platformLevelID)
        }
        if let next = nextChapterID(from: chapterID) {
            let nextHasCases = !CaseFile.loadCases(forChapter: next).isEmpty
            let nextHasLevel = LevelData.load(id: "level_\(next)") != nil
            if nextHasCases || nextHasLevel {
                GameState.shared.currentChapterID = next
                GameState.shared.save()
                return .desk(chapterID: next)
            }
        }
        GameState.shared.setFlag("game_complete")
        GameState.shared.save()
        return .ending(endingType: determineEnding())
    }

    private func nextChapterID(from current: String) -> String? {
        let chapters = ["ch1","ch2","ch3","ch4","ch5","ch6","ch7","ch8"]
        guard let idx = chapters.firstIndex(of: current), idx + 1 < chapters.count else { return nil }
        return chapters[idx + 1]
    }

    private func determineEnding() -> EndingType {
        let state = GameState.shared
        if state.resistanceTrust > state.corporateTrust && state.empathyScore > state.complianceScore {
            return .broadcast
        } else if state.corporateTrust > state.resistanceTrust && state.complianceScore > state.empathyScore {
            return .control
        } else {
            return .erasure
        }
    }
}

// MARK: - Document Tab (visual only — DeskScene owns all touch handling)

private final class DocumentTabNode: SKNode {
    init(title: String, isActive: Bool, hasSuspiciousFields: Bool, size: CGSize) {
        super.init()

        let bg = SKSpriteNode(color: isActive ? DLOColor.documentBG : DLOColor.terminalBG, size: size)
        bg.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(bg)

        // Active tab indicator strip
        if isActive {
            let strip = SKSpriteNode(color: DLOColor.terminalAmber,
                                     size: CGSize(width: size.width, height: 2))
            strip.anchorPoint = CGPoint(x: 0, y: 0)
            strip.position = CGPoint(x: 0, y: size.height - 2)
            addChild(strip)
        }

        // Subtle amber ◆ dot in top-right corner when document contains suspicious fields.
        // Tells the player something is worth examining without revealing what.
        if hasSuspiciousFields {
            let dot = SKLabelNode(text: "◆")
            dot.fontName = "Menlo"
            dot.fontSize = 6
            dot.fontColor = SKColor.fromHex("#CC6600").withAlphaComponent(isActive ? 1.0 : 0.65)
            dot.horizontalAlignmentMode = .right
            dot.verticalAlignmentMode = .top
            dot.position = CGPoint(x: size.width - 3, y: size.height - 3)
            addChild(dot)
        }

        // Title label — reserve right margin if dot is present so text doesn't overlap
        let titleMaxW = hasSuspiciousFields ? size.width - 14 : size.width - 8
        let lbl = SKLabelNode(text: title)
        lbl.fontName = "Menlo"
        lbl.fontSize = 8
        lbl.fontColor = isActive ? DLOColor.bodyText : DLOColor.uiBorder
        lbl.horizontalAlignmentMode = .left
        lbl.verticalAlignmentMode = .center
        lbl.position = CGPoint(x: 6, y: size.height / 2)
        lbl.preferredMaxLayoutWidth = titleMaxW
        lbl.numberOfLines = 2
        addChild(lbl)
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

// MARK: - Continue Button (visual only — DeskScene owns all touch handling)

private final class DeskContinueButtonNode: SKNode {
    private let nodeWidth: CGFloat
    static let height: CGFloat = 32

    init(width: CGFloat) {
        self.nodeWidth = width
        super.init()

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: DeskContinueButtonNode.height),
                             cornerRadius: 3)
        bg.fillColor = DLOColor.terminalAmber.withAlphaComponent(0.12)
        bg.strokeColor = DLOColor.terminalAmber.withAlphaComponent(0.6)
        bg.lineWidth = 1.2
        addChild(bg)

        let lbl = DLOFont.terminalLabel(text: "▶  NEXT CASE", size: 10)
        lbl.horizontalAlignmentMode = .center
        lbl.fontColor = DLOColor.terminalAmber
        lbl.position = CGPoint(x: 0, y: -3)
        addChild(lbl)
    }
    required init?(coder: NSCoder) { fatalError() }
}
