import SpriteKit

/// Touch-friendly PDA hack presenter — signal routing and future puzzle types.
enum PDAHackPanel {

    static func presentSignalRoute(
        title: String,
        nodeLabels: [String],
        correctSequence: [Int],
        panelSize: CGSize,
        textMultiplier: CGFloat,
        onSuccess: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> (panel: SKNode, scrollState: ScrollableReadablePanel.ScrollState?) {
        var tapped: [Int] = []
        let mult = textMultiplier

        let body = """
\(title)

Tap nodes in the displayed route order.

ROUTE:
\(correctSequence.map { nodeLabels[$0] }.joined(separator: " → "))

Status: AWAITING INPUT
"""
        var statusNode: SKLabelNode?

        let panel = SKNode()
        let panelW = panelSize.width
        let panelH = panelSize.height

        let bg = SKSpriteNode(color: SKColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 1),
                              size: panelSize)
        bg.alpha = 0.97
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: panelH - 2), cornerRadius: 10)
        border.strokeColor = SKColor(red: 0.38, green: 0.48, blue: 0.42, alpha: 1)
        border.lineWidth = 1.5
        border.fillColor = .clear
        panel.addChild(border)

        let header = DLOFont.terminalLabel(text: "MARA PDA — SYSTEM INTRUSION", size: 11 * mult)
        header.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 1)
        header.horizontalAlignmentMode = .center
        header.position = CGPoint(x: 0, y: panelH / 2 - 28)
        panel.addChild(header)

        let instr = DLOFont.terminalLabel(text: title, size: 9 * mult)
        instr.fontColor = SKColor(red: 0.78, green: 0.84, blue: 0.74, alpha: 0.9)
        instr.horizontalAlignmentMode = .center
        instr.position = CGPoint(x: 0, y: panelH / 2 - 52)
        panel.addChild(instr)

        let routeLbl = DLOFont.terminalLabel(
            text: "ROUTE: " + correctSequence.map { nodeLabels[$0] }.joined(separator: " → "),
            size: 8 * mult)
        routeLbl.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 0.85)
        routeLbl.horizontalAlignmentMode = .center
        routeLbl.position = CGPoint(x: 0, y: panelH / 2 - 72)
        panel.addChild(routeLbl)

        statusNode = DLOFont.terminalLabel(text: "STATUS: AWAITING INPUT", size: 8 * mult)
        statusNode?.fontColor = SKColor(red: 0.78, green: 0.84, blue: 0.74, alpha: 0.7)
        statusNode?.horizontalAlignmentMode = .center
        statusNode?.position = CGPoint(x: 0, y: -panelH / 2 + 88)
        if let statusNode { panel.addChild(statusNode) }

        let nodeY: CGFloat = 0
        let spacing: CGFloat = min(72, (panelW - 80) / CGFloat(max(1, nodeLabels.count)))
        let startX = -spacing * CGFloat(nodeLabels.count - 1) / 2

        for (i, label) in nodeLabels.enumerated() {
            let x = startX + CGFloat(i) * spacing
            let btn = HackNodeButton(label: label) {
                tapped.append(i)
                let progress = tapped.enumerated().map { nodeLabels[$0.element] }.joined(separator: " → ")
                statusNode?.text = "STATUS: \(progress.isEmpty ? "AWAITING INPUT" : progress)"

                let expected = Array(correctSequence.prefix(tapped.count))
                if tapped != expected {
                    statusNode?.fontColor = DLOColor.danger
                    statusNode?.text = "STATUS: SIGNAL MISMATCH — RESET"
                    tapped.removeAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        statusNode?.fontColor = SKColor(red: 0.78, green: 0.84, blue: 0.74, alpha: 0.7)
                        statusNode?.text = "STATUS: AWAITING INPUT"
                    }
                    return
                }

                if tapped.count == correctSequence.count {
                    statusNode?.text = "STATUS: ACCESS GRANTED"
                    statusNode?.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onSuccess() }
                }
            }
            btn.position = CGPoint(x: x, y: nodeY)
            panel.addChild(btn)
        }

        let cancel = PanelButtonNode(label: "[ CANCEL ]", action: onCancel)
        cancel.position = CGPoint(x: 0, y: -panelH / 2 + 24)
        panel.addChild(cancel)

        return (panel, nil)
    }
}

private final class HackNodeButton: SKNode {
    init(label: String, action: @escaping () -> Void) {
        super.init()
        isUserInteractionEnabled = true
        let size = CGSize(width: 58, height: 58)
        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.14, green: 0.18, blue: 0.20, alpha: 1)
        bg.strokeColor = SKColor(red: 0.38, green: 0.48, blue: 0.42, alpha: 0.8)
        bg.lineWidth = 1.5
        addChild(bg)

        let lbl = DLOFont.terminalLabel(text: label, size: 7)
        lbl.fontColor = SKColor(red: 0.62, green: 0.82, blue: 0.68, alpha: 1)
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode = .center
        addChild(lbl)

        self.userData = NSMutableDictionary()
        self.userData?["action"] = action
    }
    required init?(coder: NSCoder) { fatalError() }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        (userData?["action"] as? () -> Void)?()
        run(SKAction.sequence([
            SKAction.scale(to: 0.92, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ]))
    }
}
