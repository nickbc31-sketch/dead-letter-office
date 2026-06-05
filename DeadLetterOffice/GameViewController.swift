import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var didPresent = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presentBootSceneIfNeeded()
    }

    private func presentBootSceneIfNeeded() {
        guard !didPresent,
              let sv = view as? SKView,
              sv.bounds.width > 100,
              sv.bounds.height > 50 else { return }
        didPresent = true

        let sz = sv.bounds.size
        NSLog("[DLO] GameVC: presenting at %.0f×%.0f", sz.width, sz.height)
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
        if args.contains("--start-at-platform") {
            let s = PlatformScene(size: sz); s.levelID = "level_ch1"; s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }
        if args.contains("--start-at-chapter-select") {
            let s = ChapterSelectScene(size: sz); s.scaleMode = .resizeFill
            sv.presentScene(s); return
        }

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
        sv.showsFPS = false
        sv.showsNodeCount = false
        view = sv
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}
