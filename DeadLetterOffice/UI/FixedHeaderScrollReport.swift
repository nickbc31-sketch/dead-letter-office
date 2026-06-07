import SpriteKit

/// Fixed header + scrollable body + fixed footer button layout for chapter reports.
enum FixedHeaderScrollReport {

    struct BuildResult {
        let root: SKNode
        let scrollState: ScrollableReadablePanel.ScrollState
        let scrollBodyRect: CGRect
        let continueRect: CGRect
        let continueLabel: SKLabelNode
    }

    static func build(
        layout: SceneLayout,
        header: String,
        body: String,
        continueText: String,
        textMultiplier: CGFloat,
        footerHeight: CGFloat = 56
    ) -> BuildResult {
        let mult = max(0.85, min(1.35, textMultiplier))
        let root = SKNode()

        let headerH: CGFloat = 52
        let footerH = footerHeight
        let bodyTop = layout.top - headerH - 8
        let bodyBottom = layout.bottom + footerH + 8
        let bodyH = bodyTop - bodyBottom
        let bodyW = layout.w * 0.84
        let bodyLeft = layout.x(0.08)

        let hdr = DLOFont.titleLabel(text: header, size: 15 * mult)
        hdr.horizontalAlignmentMode = .center
        hdr.position = CGPoint(x: layout.midX, y: layout.top - 28)
        root.addChild(hdr)

        let div = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.45),
                               size: CGSize(width: layout.w * 0.70, height: 1))
        div.position = CGPoint(x: layout.midX, y: layout.top - headerH)
        root.addChild(div)

        let bodyLbl = SKLabelNode(text: body)
        bodyLbl.fontName = "Menlo"
        bodyLbl.fontSize = 12 * mult
        bodyLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.88)
        bodyLbl.horizontalAlignmentMode = .left
        bodyLbl.verticalAlignmentMode = .top
        bodyLbl.numberOfLines = 0
        bodyLbl.preferredMaxLayoutWidth = bodyW

        let clip = SKCropNode()
        let mask = SKSpriteNode(color: .white, size: CGSize(width: bodyW, height: bodyH))
        mask.position = CGPoint(x: bodyLeft + bodyW / 2, y: bodyBottom + bodyH / 2)
        clip.maskNode = mask

        let content = SKNode()
        bodyLbl.position = CGPoint(x: bodyLeft, y: bodyTop)
        content.addChild(bodyLbl)
        clip.addChild(content)
        clip.position = .zero
        root.addChild(clip)

        let scrollState = ScrollableReadablePanel.ScrollState()
        scrollState.content = content
        scrollState.bodyLabel = bodyLbl
        scrollState.viewportHeight = bodyH
        scrollState.recalculateBounds()

        let scrollBodyRect = CGRect(x: bodyLeft, y: bodyBottom, width: bodyW, height: bodyH)

        let continueLbl = DLOFont.terminalLabel(text: continueText, size: 14 * mult)
        continueLbl.horizontalAlignmentMode = .center
        continueLbl.position = CGPoint(x: layout.midX, y: layout.bottom + footerH * 0.42)
        continueLbl.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.35, duration: 0.7),
            SKAction.fadeAlpha(to: 1.0, duration: 0.7),
        ])))
        root.addChild(continueLbl)

        let continueRect = CGRect(
            x: layout.midX - layout.w * 0.35,
            y: layout.bottom + 6,
            width: layout.w * 0.70,
            height: footerH)

        return BuildResult(
            root: root,
            scrollState: scrollState,
            scrollBodyRect: scrollBodyRect,
            continueRect: continueRect,
            continueLabel: continueLbl)
    }
}
