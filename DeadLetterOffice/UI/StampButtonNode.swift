import SpriteKit

// Visual-only stamp button — DeskScene owns all touch routing.
final class StampButtonNode: SKNode {

    let action: CaseAction
    private let buttonSize: CGSize

    init(action: CaseAction, size: CGSize = CGSize(width: 120, height: 44)) {
        self.action = action
        self.buttonSize = size
        super.init()
        // isUserInteractionEnabled is intentionally false — DeskScene handles all touch routing
        build()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func build() {
        // action.color is tuned for stamp-on-paper (aged cream background).
        // Boost dark colours for legibility on the dark DLOColor.terminalBG button panel.
        let ink = StampButtonNode.buttonColor(for: action.color)

        let body = SKShapeNode(rectOf: buttonSize, cornerRadius: 4)
        body.fillColor = ink.withAlphaComponent(0.15)
        body.strokeColor = ink
        body.lineWidth = 2
        addChild(body)

        let lbl = SKLabelNode(text: action.shortLabel)
        lbl.fontName = "Menlo-Bold"
        lbl.fontSize = 14
        lbl.fontColor = ink
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode = .center
        addChild(lbl)

        if action.isIllegal {
            let illegalDot = SKShapeNode(circleOfRadius: 5)
            illegalDot.fillColor = DLOColor.danger
            illegalDot.strokeColor = .clear
            illegalDot.position = CGPoint(x: buttonSize.width/2 - 10, y: buttonSize.height/2 - 10)
            addChild(illegalDot)
        }
    }

    // Ensures the button colour is legible against DLOColor.terminalBG.
    // action.color values are designed for stamp-on-paper (light background); many are
    // too dark to read on the terminal UI. Scale all channels up proportionally so
    // perceived brightness reaches at least 0.45 (gives ≥3:1 WCAG contrast).
    private static func buttonColor(for hex: String) -> SKColor {
        let raw = SKColor.fromHex(hex)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        raw.getRed(&r, green: &g, blue: &b, alpha: &a)
        let brightness = 0.299 * r + 0.587 * g + 0.114 * b
        let minBrightness: CGFloat = 0.45
        guard brightness < minBrightness else { return raw }
        let scale = minBrightness / max(brightness, 0.001)
        return SKColor(red: min(r * scale, 1), green: min(g * scale, 1),
                       blue: min(b * scale, 1), alpha: a)
    }

    // Called by DeskScene on touchesBegan to give immediate visual press feedback
    func animatePress() {
        removeAllActions()
        let ink = SKColor.fromHex(action.color)
        run(SKAction.sequence([
            SKAction.scale(to: 0.92, duration: 0.05),
            SKAction.scale(to: 1.0,  duration: 0.08),
            SKAction.colorize(with: ink, colorBlendFactor: 0.5, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.15)
        ]))
    }
}
