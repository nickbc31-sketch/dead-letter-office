import SpriteKit

/// Copy and modal UI for optional iOS enhanced-voice guidance.
enum FieldNotesVoiceHelp {

    static let guidedModeSummary = """
Field Notes can read aloud automatically.
Useful for shorter sessions and accessibility.
"""

    static let guidedModeVoiceHint = """
Optional: For better spoken notes, download an enhanced iOS voice:
Settings → Accessibility → Spoken Content → Voices → English

This is optional. The game works without it.
"""

    static let settingsHint = """
Dead Letter Office uses your iPhone's built-in speech voices.
For better spoken Field Notes, install an enhanced iOS voice.
This is optional.
"""

    static let linkLabel = "VOICE QUALITY HELP"

    static let modalTitle = "BETTER FIELD NOTES VOICE"

    static let modalBody = """
Dead Letter Office uses your iPhone's built-in speech voices.

For better spoken Field Notes, install an enhanced iOS voice:
Settings → Accessibility → Spoken Content → Voices → English.

This is optional.
"""

    static func showModal(
        in scene: SKScene,
        layout: SceneLayout,
        panelNode: inout SKNode?,
        okRect: inout CGRect,
        zPosition: CGFloat = 1100
    ) {
        panelNode?.removeFromParent()

        let panelW = min(layout.w * 0.78, 600)
        let panelH = min(layout.h * 0.72, 340)

        let panel = SKNode()
        panel.position = layout.center
        panel.zPosition = zPosition

        let dim = SKSpriteNode(color: .black.withAlphaComponent(0.55), size: scene.size)
        dim.position = CGPoint(x: scene.size.width / 2 - layout.center.x,
                               y: scene.size.height / 2 - layout.center.y)
        dim.zPosition = 0
        panel.addChild(dim)

        let bg = SKSpriteNode(color: DLOColor.terminalBG,
                              size: CGSize(width: panelW, height: panelH))
        bg.zPosition = 1
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 4)
        border.strokeColor = DLOColor.terminalAmber
        border.lineWidth = 1.5
        border.fillColor = .clear
        border.zPosition = 2
        panel.addChild(border)

        let title = DLOFont.titleLabel(text: modalTitle, size: 12)
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: panelH * 0.34)
        title.zPosition = 3
        panel.addChild(title)

        let body = SKLabelNode()
        body.fontName = "Menlo"
        body.fontSize = 9 * GameState.shared.textSizeMultiplier
        body.fontColor = DLOColor.uiBorder
        body.horizontalAlignmentMode = .center
        body.verticalAlignmentMode = .center
        body.numberOfLines = 0
        body.preferredMaxLayoutWidth = panelW * 0.86
        body.text = modalBody
        body.position = CGPoint(x: 0, y: panelH * 0.02)
        body.zPosition = 3
        panel.addChild(body)

        let okLbl = DLOFont.terminalLabel(text: "[ OK ]", size: 11)
        okLbl.fontColor = DLOColor.terminalAmber
        okLbl.horizontalAlignmentMode = .center
        okLbl.position = CGPoint(x: 0, y: -panelH * 0.36)
        okLbl.zPosition = 3
        panel.addChild(okLbl)

        scene.addChild(panel)
        panelNode = panel

        let btnY = layout.center.y - panelH * 0.36
        okRect = CGRect(x: layout.center.x - 70, y: btnY - 22, width: 140, height: 44)
    }
}
