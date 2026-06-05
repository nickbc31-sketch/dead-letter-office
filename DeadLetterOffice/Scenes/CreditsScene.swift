import SpriteKit

final class CreditsScene: SKScene {

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))
    private var backRect = CGRect.zero

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        layout = SceneLayout.make(scene: self)
        backgroundColor = DLOColor.background
        buildScene()
    }

    private func buildScene() {
        removeAllChildren()

        let title = DLOFont.titleLabel(text: "CREDITS", size: 20)
        title.position = CGPoint(x: layout.midX, y: layout.y(0.85))
        addChild(title)

        let lines: [String] = [
            "DEAD LETTER OFFICE",
            "",
            "Design, Writing, Code",
            "Nicholas Byrne-Chinn",
            "",
            "Built with SpriteKit",
            "",
            "POST-MORTEM COMMUNICATIONS AUTHORITY",
            "All letters are property of the State.",
        ]

        var y = layout.y(0.72)
        for line in lines {
            let lbl = DLOFont.terminalLabel(text: line, size: line.isEmpty ? 6 : 11)
            lbl.horizontalAlignmentMode = .center
            lbl.position = CGPoint(x: layout.midX, y: y)
            lbl.fontColor = line.isEmpty ? DLOColor.uiBorder : DLOColor.terminalAmber.withAlphaComponent(0.8)
            addChild(lbl)
            y -= line.isEmpty ? 8 : 14
        }

        let backLbl = DLOFont.terminalLabel(text: "> BACK", size: 12)
        backLbl.horizontalAlignmentMode = .center
        backLbl.position = CGPoint(x: layout.midX, y: layout.y(0.10))
        addChild(backLbl)
        backRect = CGRect(x: layout.midX - 80, y: layout.y(0.10) - 22,
                          width: 160, height: 44)

        addChild(CRTEffectNode(size: size))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        if backRect.contains(pos) {
            SceneManager.shared.transition(to: .mainMenu, from: self)
        }
    }
}
