import SpriteKit

enum DLOFont {
    static func terminalLabel(text: String, size: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Menlo"
        label.fontSize = size
        label.fontColor = DLOColor.terminalAmber
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        return label
    }

    static func titleLabel(text: String, size: CGFloat) -> SKLabelNode {
        return titleLabel(text: text, size: size, color: DLOColor.terminalAmber)
    }

    static func titleLabel(text: String, size: CGFloat, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Menlo-Bold"
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
}
