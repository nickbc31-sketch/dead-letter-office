import SpriteKit

final class PanelButtonNode: SKNode {
    private let action: () -> Void
    private static let btnSize = CGSize(width: 140, height: 32)

    init(label: String, action: @escaping () -> Void) {
        self.action = action
        super.init()
        isUserInteractionEnabled = true

        let bg = SKShapeNode(rectOf: PanelButtonNode.btnSize, cornerRadius: 4)
        bg.fillColor = DLOColor.uiBorder.withAlphaComponent(0.25)
        bg.strokeColor = DLOColor.uiBorder
        bg.lineWidth = 1.2
        addChild(bg)

        let lbl = DLOFont.terminalLabel(text: label, size: 11)
        lbl.horizontalAlignmentMode = .center
        lbl.fontColor = DLOColor.terminalAmber
        lbl.position = CGPoint(x: 0, y: -4)
        addChild(lbl)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func calculateAccumulatedFrame() -> CGRect {
        let s = PanelButtonNode.btnSize
        return CGRect(x: position.x - s.width / 2, y: position.y - s.height / 2,
                      width: s.width, height: s.height)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 0.7 }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1.0
        action()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 1.0 }
}
