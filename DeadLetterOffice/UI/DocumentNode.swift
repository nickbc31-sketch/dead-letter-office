import SpriteKit
import UIKit

final class DocumentNode: SKNode {

    private let document: DocumentModel
    private let nodeSize: CGSize
    private var contentNode: SKNode!
    private var contentHeight: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private let padding: CGFloat = 12

    init(document: DocumentModel, size: CGSize) {
        self.document = document
        self.nodeSize = size
        super.init()
        buildContent()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildContent() {
        let mult     = GameState.shared.textSizeMultiplier
        let fieldFS  = 11.0 * mult         // field key + value font (was 9.5)
        let bodyFS   = 10.5 * mult         // body paragraph font (was 9.0)

        // Paper background
        let bg = SKSpriteNode(color: DLOColor.documentBG, size: nodeSize)
        bg.anchorPoint = CGPoint(x: 0, y: 1)
        bg.position = CGPoint(x: 0, y: nodeSize.height)
        addChild(bg)

        // Clip mask — constrains all content to the document rectangle
        let mask = SKSpriteNode(color: .white, size: nodeSize)
        mask.anchorPoint = CGPoint(x: 0, y: 1)
        mask.position = CGPoint(x: 0, y: nodeSize.height)
        let crop = SKCropNode()
        crop.maskNode = mask

        contentNode = SKNode()
        crop.addChild(contentNode)
        addChild(crop)

        var y: CGFloat = nodeSize.height - padding

        // ── Classification banner ─────────────────────────────────────────────
        let classColor: SKColor = document.classificationLevel == "STANDARD"
            ? DLOColor.uiBorder.withAlphaComponent(0.5)
            : (document.classificationLevel == "RESTRICTED"
               ? DLOColor.terminalAmber.withAlphaComponent(0.7)
               : DLOColor.danger.withAlphaComponent(0.8))

        let classBanner = SKSpriteNode(color: classColor,
                                       size: CGSize(width: nodeSize.width, height: 14))
        classBanner.anchorPoint = CGPoint(x: 0, y: 1)
        classBanner.position = CGPoint(x: 0, y: y)
        contentNode.addChild(classBanner)

        let classLbl = SKLabelNode(text: document.classificationLevel)
        classLbl.fontName = "Menlo-Bold"
        classLbl.fontSize = 8
        classLbl.fontColor = .white
        classLbl.horizontalAlignmentMode = .center
        classLbl.verticalAlignmentMode = .center
        classLbl.position = CGPoint(x: nodeSize.width / 2, y: y - 7)
        contentNode.addChild(classLbl)
        y -= 20

        // ── Issuer ────────────────────────────────────────────────────────────
        let issuerLbl = SKLabelNode(text: document.issuer.uppercased())
        issuerLbl.fontName = "Menlo"
        issuerLbl.fontSize = 8.5
        issuerLbl.fontColor = DLOColor.bodyText.withAlphaComponent(0.6)
        issuerLbl.horizontalAlignmentMode = .center
        issuerLbl.verticalAlignmentMode = .top
        issuerLbl.position = CGPoint(x: nodeSize.width / 2, y: y)
        contentNode.addChild(issuerLbl)
        y -= 12

        // ── Title ─────────────────────────────────────────────────────────────
        let titleFS: CGFloat = 11 * mult
        let titleLbl = SKLabelNode(text: document.title.uppercased())
        titleLbl.fontName = "Menlo-Bold"
        titleLbl.fontSize = titleFS
        titleLbl.fontColor = DLOColor.bodyText
        titleLbl.horizontalAlignmentMode = .center
        titleLbl.verticalAlignmentMode = .top
        titleLbl.numberOfLines = 2
        titleLbl.preferredMaxLayoutWidth = nodeSize.width - padding * 2
        titleLbl.position = CGPoint(x: nodeSize.width / 2, y: y)
        contentNode.addChild(titleLbl)
        let titleCharsPerLine = max(1, Int((nodeSize.width - padding * 2) / (titleFS * 0.62)))
        let titleLines = max(1, (document.title.count + titleCharsPerLine - 1) / titleCharsPerLine)
        y -= CGFloat(titleLines) * (titleFS * 1.35) + 2

        // ── Reference / date ─────────────────────────────────────────────────
        let refLbl = SKLabelNode(text: "REF: \(document.referenceNumber)  |  DATE: \(document.issueDate)")
        refLbl.fontName = "Menlo"
        refLbl.fontSize = 8.0
        refLbl.fontColor = DLOColor.bodyText.withAlphaComponent(0.5)
        refLbl.horizontalAlignmentMode = .center
        refLbl.verticalAlignmentMode = .top
        refLbl.position = CGPoint(x: nodeSize.width / 2, y: y)
        contentNode.addChild(refLbl)
        y -= 12

        // Divider
        let div = SKSpriteNode(color: DLOColor.bodyText.withAlphaComponent(0.3),
                               size: CGSize(width: nodeSize.width - padding * 2, height: 1))
        div.anchorPoint = CGPoint(x: 0, y: 0.5)
        div.position = CGPoint(x: padding, y: y - 3)
        contentNode.addChild(div)
        y -= 12

        // ── Fields ────────────────────────────────────────────────────────────
        let keyColW:    CGFloat = 130
        let valueW:     CGFloat = nodeSize.width - padding * 2 - keyColW - 4

        for field in document.fields {
            let keyColor = field.isSuspicious
                ? DLOColor.terminalAmber.withAlphaComponent(0.9)
                : DLOColor.bodyText.withAlphaComponent(0.7)
            let valColor = field.isSuspicious ? DLOColor.terminalAmber : DLOColor.bodyText

            let keyLbl = SKLabelNode(text: field.key.uppercased() + ":")
            keyLbl.fontName = "Menlo-Bold"
            keyLbl.fontSize = fieldFS
            keyLbl.fontColor = keyColor
            keyLbl.horizontalAlignmentMode = .left
            keyLbl.verticalAlignmentMode = .top
            keyLbl.numberOfLines = 2
            keyLbl.preferredMaxLayoutWidth = keyColW - 4
            keyLbl.position = CGPoint(x: padding, y: y)
            contentNode.addChild(keyLbl)

            let valLbl = SKLabelNode(text: field.value)
            valLbl.fontName = "Menlo"
            valLbl.fontSize = fieldFS
            valLbl.fontColor = valColor
            valLbl.horizontalAlignmentMode = .left
            valLbl.verticalAlignmentMode = .top
            valLbl.numberOfLines = 0
            valLbl.preferredMaxLayoutWidth = valueW
            valLbl.position = CGPoint(x: padding + keyColW, y: y)
            contentNode.addChild(valLbl)

            if field.isSuspicious {
                let flagDot = SKLabelNode(text: "◆")
                flagDot.fontName = "Menlo"
                flagDot.fontSize = 6
                flagDot.fontColor = DLOColor.terminalAmber
                flagDot.horizontalAlignmentMode = .right
                flagDot.verticalAlignmentMode = .top
                flagDot.position = CGPoint(x: nodeSize.width - padding + 2, y: y)
                contentNode.addChild(flagDot)
            }

            let keyHeight = Self.measuredTextHeight(
                field.key.uppercased() + ":", fontSize: fieldFS, width: keyColW - 4)
            let valHeight = Self.measuredTextHeight(field.value, fontSize: fieldFS, width: valueW)
            y -= max(keyHeight, valHeight) + 2
        }

        // ── Body text ─────────────────────────────────────────────────────────
        if !document.bodyText.isEmpty {
            y -= 6
            let bodyDiv = SKSpriteNode(color: DLOColor.bodyText.withAlphaComponent(0.2),
                                       size: CGSize(width: nodeSize.width - padding * 2, height: 1))
            bodyDiv.anchorPoint = CGPoint(x: 0, y: 0.5)
            bodyDiv.position = CGPoint(x: padding, y: y)
            contentNode.addChild(bodyDiv)
            y -= 8

            let bodyLbl = SKLabelNode(text: document.bodyText)
            bodyLbl.fontName = "Menlo"
            bodyLbl.fontSize = bodyFS
            bodyLbl.fontColor = DLOColor.bodyText.withAlphaComponent(0.85)
            bodyLbl.horizontalAlignmentMode = .left
            bodyLbl.verticalAlignmentMode = .top
            bodyLbl.numberOfLines = 0
            bodyLbl.preferredMaxLayoutWidth = nodeSize.width - padding * 2
            bodyLbl.position = CGPoint(x: padding, y: y)
            contentNode.addChild(bodyLbl)
            let bodyWidth = nodeSize.width - padding * 2
            y -= Self.measuredTextHeight(document.bodyText, fontSize: bodyFS, width: bodyWidth) + 6
        }

        // ── Stamps ────────────────────────────────────────────────────────────
        for stamp in document.stamps {
            let stampLbl = SKLabelNode(text: stamp.text)
            stampLbl.fontName = "Menlo-Bold"
            stampLbl.fontSize = 18
            stampLbl.fontColor = SKColor.fromHex(stamp.color).withAlphaComponent(0.7)
            stampLbl.zRotation = -0.2
            stampLbl.horizontalAlignmentMode = .center
            stampLbl.verticalAlignmentMode = .center
            stampLbl.position = CGPoint(x: nodeSize.width * 0.65, y: nodeSize.height * 0.45)
            stampLbl.zPosition = 10
            contentNode.addChild(stampLbl)
        }

        // ── Tampered indicator ────────────────────────────────────────────────
        if document.isTampered {
            let tamperedLbl = SKLabelNode(text: "[DOCUMENT INTEGRITY COMPROMISED]")
            tamperedLbl.fontName = "Menlo"
            tamperedLbl.fontSize = 6
            tamperedLbl.fontColor = DLOColor.danger.withAlphaComponent(0.6)
            tamperedLbl.horizontalAlignmentMode = .center
            tamperedLbl.verticalAlignmentMode = .top
            tamperedLbl.position = CGPoint(x: nodeSize.width / 2, y: padding)
            contentNode.addChild(tamperedLbl)
        }

        let topY = nodeSize.height - padding
        contentHeight = max(nodeSize.height, topY - y + padding)
        scrollOffset = 0
        contentNode.position.y = 0
    }

    /// Swipe up (positive delta) reveals lower document text.
    func scroll(delta: CGFloat) {
        let maxScroll = max(0, contentHeight - nodeSize.height)
        scrollOffset = (scrollOffset + delta).clamped(to: 0...maxScroll)
        contentNode.position.y = scrollOffset
    }

    private static func measuredTextHeight(_ text: String, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont(name: "Menlo", size: fontSize)
            ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: max(1, width), height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil)
        return ceil(rect.height)
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
