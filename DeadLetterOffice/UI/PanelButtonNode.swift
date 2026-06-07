import SpriteKit
import UIKit

final class PanelButtonNode: SKNode {
    private let action: () -> Void
    private let buttonSize: CGSize

    private let playsUIClick: Bool

    /// - Parameters:
    ///   - width: Explicit button width. When nil, sizes to label text (minimum 140pt).
    ///   - fontSize: Base font size before `GameState.textSizeMultiplier` is applied.
    init(label: String,
         width: CGFloat? = nil,
         fontSize: CGFloat = 11,
         playsUIClick: Bool = false,
         action: @escaping () -> Void) {
        self.playsUIClick = playsUIClick
        self.action = action

        let mult = GameState.shared.textSizeMultiplier
        let effectiveFontSize = fontSize * mult
        let measuredW = Self.measuredWidth(for: label, fontSize: effectiveFontSize)
        let w = width ?? max(140, measuredW + 28)
        let h = max(32, effectiveFontSize * 2.6 + 14)
        self.buttonSize = CGSize(width: w, height: h)

        super.init()
        isUserInteractionEnabled = true

        let bg = SKShapeNode(rectOf: buttonSize, cornerRadius: 4)
        bg.fillColor = DLOColor.uiBorder.withAlphaComponent(0.25)
        bg.strokeColor = DLOColor.uiBorder
        bg.lineWidth = 1.2
        addChild(bg)

        let lbl = DLOFont.terminalLabel(text: label, size: effectiveFontSize)
        lbl.horizontalAlignmentMode = .center
        lbl.fontColor = DLOColor.terminalAmber
        lbl.position = CGPoint(x: 0, y: -effectiveFontSize * 0.12)
        addChild(lbl)
    }

    required init?(coder: NSCoder) { fatalError() }

    var height: CGFloat { buttonSize.height }

    private static func measuredWidth(for text: String, fontSize: CGFloat) -> CGFloat {
        let font = UIFont(name: "Menlo", size: fontSize)
            ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: fontSize * 2),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil)
        return ceil(rect.width)
    }

    override func calculateAccumulatedFrame() -> CGRect {
        CGRect(x: position.x - buttonSize.width / 2, y: position.y - buttonSize.height / 2,
               width: buttonSize.width, height: buttonSize.height)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 0.7 }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1.0
        if playsUIClick { AudioManager.shared.playUIClick() }
        action()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 1.0 }
}
