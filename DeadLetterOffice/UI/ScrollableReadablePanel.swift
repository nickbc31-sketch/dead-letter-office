import SpriteKit
import UIKit

/// Scrollable readable modal for terminals, Mara PDA notes, and field confirmations.
enum ScrollableReadablePanel {

    enum Style {
        case terminal
        case pda

        var background: SKColor {
            switch self {
            case .terminal: return DLOColor.terminalBG
            case .pda:      return SKColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 1)
            }
        }

        var border: SKColor {
            switch self {
            case .terminal: return DLOColor.teal
            case .pda:      return SKColor(red: 0.38, green: 0.48, blue: 0.42, alpha: 1)
            }
        }

        var textColor: SKColor {
            switch self {
            case .terminal: return DLOColor.terminalAmber.withAlphaComponent(0.92)
            case .pda:      return SKColor(red: 0.78, green: 0.84, blue: 0.74, alpha: 1)
            }
        }

        var headerColor: SKColor {
            switch self {
            case .terminal: return DLOColor.terminalAmber
            case .pda:      return SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 1)
            }
        }

        var headerBarColor: SKColor {
            switch self {
            case .terminal: return DLOColor.terminalBG
            case .pda:      return SKColor(red: 0.13, green: 0.15, blue: 0.17, alpha: 1)
            }
        }
    }

    struct PDAMetadata {
        var deviceID: String
        var caseRef: String
        var noteCount: Int
        var syncStatus: String
        var timestamp: String
    }

    final class ScrollState {
        weak var content: SKNode?
        weak var bodyLabel: SKLabelNode?
        var viewportHeight: CGFloat = 0
        var maxScroll: CGFloat = 0
        var offset: CGFloat = 0

        /// Finger drag in scene coords: swipe up (positive deltaY) reveals lower content.
        func applyDrag(deltaY: CGFloat) {
            guard maxScroll > 0, let content else { return }
            offset = max(0, min(maxScroll, offset + deltaY))
            content.position.y = offset
        }

        func recalculateBounds() {
            guard let bodyLabel, viewportHeight > 0 else { return }
            let contentHeight = ScrollableReadablePanel.measuredTextHeight(bodyLabel)
            maxScroll = max(0, contentHeight - viewportHeight)
            offset = min(max(offset, 0), maxScroll)
            content?.position.y = offset
        }
    }

    /// Wrapped text height from font size, width, and line breaks (scene-independent).
    private static func measuredTextHeight(_ label: SKLabelNode) -> CGFloat {
        let text = label.text ?? ""
        let width = max(1, label.preferredMaxLayoutWidth)
        let fontName = label.fontName ?? "Menlo"
        let font = UIFont(name: fontName, size: label.fontSize)
            ?? UIFont.monospacedSystemFont(ofSize: label.fontSize, weight: .regular)
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil)
        return max(ceil(rect.height), ceil(abs(label.frame.height)))
    }

    struct ButtonSpec {
        let label: String
        let action: () -> Void
    }

    private enum Z {
        static let background: CGFloat = 0
        static let bodyCrop: CGFloat = 1
        static let chrome: CGFloat = 10
        static let buttons: CGFloat = 11
    }

    static func build(
        style: Style,
        header: String,
        body: String,
        panelSize: CGSize,
        textMultiplier: CGFloat,
        primaryButton: ButtonSpec,
        secondaryButton: ButtonSpec? = nil,
        pdaMetadata: PDAMetadata? = nil
    ) -> (panel: SKNode, scrollState: ScrollState) {
        let panelW = panelSize.width
        let panelH = panelSize.height
        let mult = max(0.85, min(1.35, textMultiplier))

        let panel = SKNode()
        let scrollState = ScrollState()

        // ── Background ──────────────────────────────────────────────
        let bg = SKSpriteNode(color: style.background, size: panelSize)
        bg.alpha = 0.97
        bg.zPosition = Z.background
        panel.addChild(bg)

        let cornerRadius: CGFloat = style == .pda ? 10 : 4
        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: panelH - 2),
                                 cornerRadius: cornerRadius)
        border.strokeColor = style.border
        border.lineWidth = 1.5
        border.fillColor = .clear
        border.zPosition = Z.background
        panel.addChild(border)

        // ── Layout: header | body viewport | footer ───────────────────
        let titleBarH: CGFloat = style == .pda ? 72 : 52
        let footerH: CGFloat = secondaryButton == nil ? 52 : 80
        let marginX: CGFloat = 20
        let contentW = panelW - marginX * 2

        let headerDividerY = panelH / 2 - titleBarH + 4
        let footerDividerY = -panelH / 2 + footerH

        let viewportTopY = headerDividerY - 6
        let viewportBottomY = footerDividerY + 6
        let viewportH = viewportTopY - viewportBottomY
        let viewportMidY = (viewportTopY + viewportBottomY) / 2

        // ── Clipped body viewport (renders below chrome) ──────────────
        let bodyLbl = SKLabelNode(text: body)
        bodyLbl.fontName = "Menlo"
        bodyLbl.fontSize = (style == .pda ? 10 : 11) * mult
        bodyLbl.fontColor = style.textColor
        bodyLbl.horizontalAlignmentMode = .left
        bodyLbl.verticalAlignmentMode = .top
        bodyLbl.numberOfLines = 0
        bodyLbl.preferredMaxLayoutWidth = contentW
        bodyLbl.lineBreakMode = .byWordWrapping

        let content = SKNode()
        bodyLbl.position = CGPoint(x: -contentW / 2, y: viewportH / 2)
        content.addChild(bodyLbl)

        let crop = SKCropNode()
        crop.position = CGPoint(x: 0, y: viewportMidY)
        crop.zPosition = Z.bodyCrop

        let mask = SKSpriteNode(color: .white, size: CGSize(width: contentW, height: viewportH))
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = .zero
        crop.maskNode = mask
        crop.addChild(content)
        panel.addChild(crop)

        let contentHeight = measuredTextHeight(bodyLbl)
        scrollState.content = content
        scrollState.bodyLabel = bodyLbl
        scrollState.viewportHeight = viewportH
        scrollState.maxScroll = max(0, contentHeight - viewportH)
        scrollState.offset = 0
        content.position.y = 0

        // ── Opaque header chrome (covers any crop bleed) ──────────────
        let headerCapH = panelH / 2 - viewportTopY
        let headerCap = SKSpriteNode(color: style.background,
                                     size: CGSize(width: panelW - 2, height: headerCapH))
        headerCap.position = CGPoint(x: 0, y: panelH / 2 - headerCapH / 2)
        headerCap.zPosition = Z.chrome
        panel.addChild(headerCap)

        let titleBar = SKSpriteNode(color: style.headerBarColor,
                                    size: CGSize(width: panelW - 4, height: titleBarH))
        titleBar.position = CGPoint(x: 0, y: panelH / 2 - titleBarH / 2)
        titleBar.zPosition = Z.chrome
        panel.addChild(titleBar)

        if style == .pda {
            let bezel = SKSpriteNode(
                color: SKColor(red: 0.18, green: 0.20, blue: 0.22, alpha: 1),
                size: CGSize(width: panelW - 8, height: 6))
            bezel.position = CGPoint(x: 0, y: panelH / 2 - 4)
            bezel.zPosition = Z.chrome
            panel.addChild(bezel)

            let led = SKShapeNode(circleOfRadius: 2.5)
            led.fillColor = style.headerColor.withAlphaComponent(0.85)
            led.strokeColor = .clear
            led.position = CGPoint(x: -panelW / 2 + 18, y: panelH / 2 - 18)
            led.zPosition = Z.chrome
            panel.addChild(led)

            if let meta = pdaMetadata {
                let statusLine = DLOFont.terminalLabel(
                    text: "SYNC: \(meta.syncStatus)  ·  \(meta.timestamp)",
                    size: 7 * mult)
                statusLine.fontColor = style.textColor.withAlphaComponent(0.55)
                statusLine.horizontalAlignmentMode = .left
                statusLine.position = CGPoint(x: -panelW / 2 + 16, y: panelH / 2 - 30)
                statusLine.zPosition = Z.chrome
                panel.addChild(statusLine)

                let idLine = DLOFont.terminalLabel(
                    text: "\(meta.deviceID)  ·  \(meta.caseRef)  ·  NOTES: \(meta.noteCount)",
                    size: 7 * mult)
                idLine.fontColor = style.textColor.withAlphaComponent(0.45)
                idLine.horizontalAlignmentMode = .left
                idLine.position = CGPoint(x: -panelW / 2 + 16, y: panelH / 2 - 42)
                idLine.zPosition = Z.chrome
                panel.addChild(idLine)
            }
        }

        let headerLbl = DLOFont.terminalLabel(text: header, size: 11 * mult)
        headerLbl.fontColor = style.headerColor
        headerLbl.horizontalAlignmentMode = .center
        headerLbl.position = CGPoint(x: 0, y: panelH / 2 - (style == .pda ? 58 : 28))
        headerLbl.zPosition = Z.chrome
        panel.addChild(headerLbl)

        let headerDivider = SKSpriteNode(color: style.border.withAlphaComponent(0.45),
                                         size: CGSize(width: panelW - 24, height: 1))
        headerDivider.position = CGPoint(x: 0, y: headerDividerY)
        headerDivider.zPosition = Z.chrome
        panel.addChild(headerDivider)

        // ── Opaque footer chrome ──────────────────────────────────────
        let footerCapH = viewportBottomY - (-panelH / 2)
        let footerCap = SKSpriteNode(color: style.background,
                                     size: CGSize(width: panelW - 2, height: footerCapH))
        footerCap.position = CGPoint(x: 0, y: -panelH / 2 + footerCapH / 2)
        footerCap.zPosition = Z.chrome
        panel.addChild(footerCap)

        let footerTop = SKSpriteNode(color: style.border.withAlphaComponent(0.35),
                                     size: CGSize(width: panelW - 24, height: 1))
        footerTop.position = CGPoint(x: 0, y: footerDividerY)
        footerTop.zPosition = Z.chrome
        panel.addChild(footerTop)

        if scrollState.maxScroll > 0 {
            let hint = DLOFont.terminalLabel(text: "▲ SCROLL ▼", size: 7 * mult)
            hint.fontColor = style.textColor.withAlphaComponent(0.4)
            hint.horizontalAlignmentMode = .right
            hint.position = CGPoint(x: panelW / 2 - 16, y: viewportBottomY + 8)
            hint.zPosition = Z.chrome
            panel.addChild(hint)
        }

        let primary = PanelButtonNode(label: primaryButton.label, action: primaryButton.action)
        primary.position = CGPoint(x: 0, y: -panelH / 2 + (secondaryButton == nil ? 26 : 50))
        primary.zPosition = Z.buttons
        panel.addChild(primary)

        if let secondary = secondaryButton {
            let sec = PanelButtonNode(label: secondary.label, action: secondary.action)
            sec.position = CGPoint(x: 0, y: -panelH / 2 + 18)
            sec.zPosition = Z.buttons
            panel.addChild(sec)
        }

        panel.userData = NSMutableDictionary()
        panel.userData?["scrollState"] = scrollState
        return (panel, scrollState)
    }
}
