#if DEBUG
import SpriteKit

/// Debug harness for all PDA hack puzzle types. Launch with `-DLOTestHackPuzzles`.
final class HackPuzzleTestScene: SKScene {

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))
    private var buttonTargets: [(CGRect, () -> Void)] = []
    private var activePanel: SKNode?

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = DLOColor.background
        buildMenu()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        if activePanel == nil { buildMenu() }
    }

    private func buildMenu() {
        removeAllChildren()
        buttonTargets.removeAll()
        activePanel = nil
        layout = SceneLayout.make(scene: self)

        let hdr = DLOFont.titleLabel(text: "PDA HACK PUZZLE TEST", size: 18)
        hdr.position = CGPoint(x: layout.midX, y: layout.y(0.92))
        addChild(hdr)

        let sub = DLOFont.terminalLabel(text: "Tap a puzzle type + difficulty", size: 9)
        sub.fontColor = DLOColor.dimText
        sub.position = CGPoint(x: layout.midX, y: layout.y(0.86))
        addChild(sub)

        var y = layout.y(0.72)
        for type in HackPuzzleType.allCases {
            let row = DLOFont.terminalLabel(text: type.rawValue.uppercased(), size: 9)
            row.fontColor = DLOColor.terminalAmber
            row.horizontalAlignmentMode = .left
            row.position = CGPoint(x: layout.x(0.06), y: y)
            addChild(row)
            y -= 22

            var x = layout.x(0.08)
            for diff in HackDifficulty.allCases {
                addButton(label: diff.rawValue.uppercased(), x: x + 50, y: y, width: 96) { [weak self] in
                    self?.launchPuzzle(type: type, difficulty: diff)
                }
                x += 110
            }
            y -= 34
        }

        addButton(label: "BACK TO DEBUG", x: layout.x(0.5), y: layout.y(0.08), width: 160) { [weak self] in
            guard let self else { return }
            SceneManager.shared.transition(to: .debug, from: self)
        }
    }

    private func launchPuzzle(type: HackPuzzleType, difficulty: HackDifficulty) {
        activePanel?.removeFromParent()
        let config = HackingSystem.sampleConfig(type: type, difficulty: difficulty)
        let cam = SceneLayout.makeCamera(scene: self)
        let panelSize = CGSize(width: cam.w * 0.82, height: cam.h * 0.68)
        let panel = PDAHackPanel.present(
            config: config,
            panelSize: panelSize,
            textMultiplier: GameState.shared.textSizeMultiplier,
            unlockedPDATags: PDAJournalManager.unlockedPDATags(),
            onResult: { [weak self] result in
                self?.handleResult(result)
            })
        panel.position = CGPoint(x: cam.midX, y: cam.midY)
        panel.zPosition = 2000
        addChild(panel)
        activePanel = panel
    }

    private func handleResult(_ result: HackPuzzleResult) {
        activePanel?.removeFromParent()
        activePanel = nil
        let msg: String
        switch result {
        case .success: msg = "RESULT: SUCCESS"
        case .cancelled: msg = "RESULT: CANCELLED"
        case .failed(let reason): msg = "RESULT: FAILED — \(reason)"
        }
        let banner = DLOFont.terminalLabel(text: msg, size: 10)
        banner.fontColor = DLOColor.terminalAmber
        banner.position = CGPoint(x: layout.midX, y: layout.y(0.04))
        banner.name = "result_banner"
        childNode(withName: "result_banner")?.removeFromParent()
        addChild(banner)
        banner.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func addButton(label: String, x: CGFloat, y: CGFloat, width: CGFloat, action: @escaping () -> Void) {
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: 26), cornerRadius: 4)
        bg.fillColor = DLOColor.uiBorder.withAlphaComponent(0.2)
        bg.strokeColor = DLOColor.uiBorder
        bg.position = CGPoint(x: x, y: y)
        addChild(bg)
        let lbl = DLOFont.terminalLabel(text: label, size: 8)
        lbl.fontColor = DLOColor.terminalAmber
        lbl.position = CGPoint(x: x, y: y - 3)
        addChild(lbl)
        let rect = CGRect(x: x - width / 2, y: y - 13, width: width, height: 26)
        buttonTargets.append((rect, action))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        for (rect, action) in buttonTargets where rect.contains(loc) {
            action()
            return
        }
    }
}
#endif
