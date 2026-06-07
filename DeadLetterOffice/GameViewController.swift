import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var didPresent = false

    /// Landscape logical size for this landscape-only app.
    /// `UIScreen.main.bounds` often reports portrait dimensions on a physical device.
    private static func landscapeSceneSize(from bounds: CGSize) -> CGSize {
        CGSize(width: max(bounds.width, bounds.height),
               height: min(bounds.width, bounds.height))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentBootSceneIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presentBootSceneIfNeeded()
    }

    private func presentBootSceneIfNeeded() {
        guard !didPresent,
              let sv = view as? SKView else { return }

        let viewBounds = sv.bounds
        guard viewBounds.width > 1, viewBounds.height > 1 else { return }

        let sz = Self.landscapeSceneSize(from: UIScreen.main.bounds.size)
        guard sz.width > 200, sz.height > 150 else { return }

        didPresent = true
        NSLog("[DLO Startup] GameVC presenting BootScene view=%.0f×%.0f scene=%.0f×%.0f",
              viewBounds.width, viewBounds.height, sz.width, sz.height)
        SceneManager.shared.view = sv

        // Debug: --start-at-desk / --start-at-dialogue launch arguments for UI testing
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--reset-save") { SaveManager.shared.deleteSave() }
        if args.contains("--reset-ch1") { resetCh1Progress() }
        if args.contains("--start-at-desk") {
            let s = DeskScene(size: sz); s.chapterID = "ch1"; s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }
        if args.contains("--start-at-dialogue") {
            let s = DialogueScene(size: sz)
            s.dialogueID = "intro_ch1"
            s.returnSceneType = .desk(chapterID: "ch1")
            s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }
        if args.contains("--start-at-platform")
            || args.contains("--dlo-validate-platform")
            || args.contains("-DLOTestPlatformScene") {
            let s = PlatformScene(size: sz)
            s.levelID = "level_ch1"
            s.scaleMode = .resizeFill
            #if DEBUG
            if args.contains("--dlo-validate-platform") || args.contains("-DLOTestPlatformScene") {
                s.debugValidationMode = true
                NSLog("[DLO Validate] debug platform regression mode — level_ch1")
            }
            #endif
            sv.presentScene(s)
            return
        }
        if args.contains("--start-at-chapter-select") {
            let s = ChapterSelectScene(size: sz); s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }
        if args.contains("--start-at-debug") {
            let s = DebugScene(size: sz); s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }
        #if DEBUG
        if args.contains("--start-at-debug-field") {
            let s = DebugFieldTestScene(size: sz); s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }
        if let shiftArg = args.first(where: { $0.hasPrefix("--debug-field-shift=") }),
           let shift = Int(shiftArg.split(separator: "=").last ?? ""),
           (1...8).contains(shift) {
            DebugFieldTestSession.prepareShift(shift)
            let s = PlatformScene(size: sz)
            s.levelID = "level_ch\(shift)"
            s.debugFieldTestMode = true
            s.scaleMode = .resizeFill
            NSLog("[DLO DebugField] launch arg — level_ch%d", shift)
            sv.presentScene(s); return
        }
        if args.contains("-DLOTestHackPuzzles") {
            let s = HackPuzzleTestScene(size: sz); s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }
        #endif

        let scene = BootScene(size: sz)
        scene.scaleMode = .resizeFill
        sv.presentScene(scene)
    }

    // Clears only Ch1 progress from the save. Preserves all Ch2+ data.
    // Activated by --reset-ch1 launch argument (Xcode scheme > Arguments Passed On Launch).
    private func resetCh1Progress() {
        let state = GameState.shared
        state.completedCaseIDs = state.completedCaseIDs.filter { !$0.hasPrefix("case_ch1_") }
        state.completedLevelIDs = state.completedLevelIDs.filter { $0 != "level_ch1" }
        let ch1Prefixes = ["ch1_", "c01_", "c02_", "c03_", "c04_", "c05_"]
        state.activeFlags = state.activeFlags.filter { flag in
            !ch1Prefixes.contains(where: { flag.hasPrefix($0) })
        }
        state.complianceScore = 0
        state.empathyScore = 0
        state.suspicionScore = 0
        state.resistanceTrust = 0
        state.corporateTrust = 0
        state.citizenHarmCount = 0
        state.currentChapterID = "ch1"
        state.caseDecisions = state.caseDecisions.filter { !$0.key.hasPrefix("case_ch1_") }
        state.save()
        NSLog("[DLO] --reset-ch1: Ch1 progress cleared")
    }

    override func loadView() {
        let sv = SKView()
        sv.backgroundColor = .black
        sv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sv.ignoresSiblingOrder = true
        sv.isMultipleTouchEnabled = true
        sv.showsFPS = false
        sv.showsNodeCount = false
        view = sv
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}
