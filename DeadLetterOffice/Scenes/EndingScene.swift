import SpriteKit

final class EndingScene: SKScene {

    var endingType: EndingType = .erasure
    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = .black
        buildScene()
        AudioManager.shared.playMusic(named: "ambient_ending")
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        removeAllChildren()
        removeAllActions()
        canContinue = false
        isUserInteractionEnabled = false
        buildScene()
    }

    private func buildScene() {
        layout = SceneLayout.make(scene: self)
        let content = endingContent(for: endingType)
        buildEnding(title: content.title, body: content.body, color: content.color)
    }

    private struct EndingContent {
        let title: String
        let body: String
        let color: SKColor
    }

    private func endingContent(for type: EndingType) -> EndingContent {
        switch type {
        case .broadcast:
            return EndingContent(
                title: "ENDING A: BROADCAST",
                body: """
MARA VENN released the dead archive to every receiver node in Veyr.

For three hours, the city heard the voices of the living declared dead.

The government fell within a week.

The Post-Mortem Communications Authority was dissolved.

Some of the voices were Mara's too.

She never heard her own.

But somewhere below, in the tunnels, the Quiet Choir kept singing.

TRUTH SURVIVES.
""",
                color: DLOColor.terminalAmber
            )
        case .control:
            return EndingContent(
                title: "ENDING B: CONTROL",
                body: """
MARA VENN did not release the archive.

She understood now what the archive was — the last leverage point.

She took Director Calyx's seat.

She updated the criteria. Fewer names on the list. For now.

The city continued. Quieter.

Mara told herself she would do better.

She still tells herself that.

UNDER NEW MANAGEMENT.
""",
                color: DLOColor.rejectBlue
            )
        case .erasure:
            return EndingContent(
                title: "ENDING C: ERASURE",
                body: """
MARA VENN deleted herself from every civic record.

She pulled forty-seven names from the death register with her.

None of them would be found.

The system continued without her.

Somewhere in the undercity, a clerk named Mara helped forty-seven people rebuild.

Her name appears in no archive.

It never will.

MEMORY PROTECTED.
""",
                color: DLOColor.terminalGreen
            )
        }
    }

    private func buildEnding(title: String, body: String, color: SKColor) {
        let titleLbl = DLOFont.titleLabel(text: title, size: 22, color: color)
        titleLbl.position = CGPoint(x: layout.midX, y: layout.y(0.80))
        titleLbl.alpha = 0
        addChild(titleLbl)

        let divider = SKSpriteNode(color: color.withAlphaComponent(0.5),
                                   size: CGSize(width: layout.w * 0.35, height: 1))
        divider.position = CGPoint(x: layout.midX, y: layout.y(0.73))
        divider.alpha = 0
        addChild(divider)

        let bodyLbl = SKLabelNode(text: body)
        bodyLbl.fontName = "Menlo"
        bodyLbl.fontSize = 12
        bodyLbl.fontColor = color.withAlphaComponent(0.85)
        bodyLbl.horizontalAlignmentMode = .center
        bodyLbl.verticalAlignmentMode = .top
        bodyLbl.numberOfLines = 0
        bodyLbl.preferredMaxLayoutWidth = layout.w * 0.6
        bodyLbl.position = CGPoint(x: layout.midX, y: layout.y(0.69))
        bodyLbl.alpha = 0
        addChild(bodyLbl)

        let continueLbl = DLOFont.terminalLabel(text: "TAP TO CONTINUE", size: 10)
        continueLbl.horizontalAlignmentMode = .center
        continueLbl.position = CGPoint(x: layout.midX, y: layout.y(0.08))
        continueLbl.alpha = 0
        addChild(continueLbl)

        continueLbl.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.8),
            SKAction.fadeAlpha(to: 0.9, duration: 0.8)
        ])))

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { titleLbl.run(SKAction.fadeIn(withDuration: 1.0)) },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { divider.run(SKAction.fadeIn(withDuration: 0.5)) },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { bodyLbl.run(SKAction.fadeIn(withDuration: 1.5)) },
            SKAction.wait(forDuration: 1.5),
            SKAction.run { continueLbl.alpha = 1 }
        ]))

        buildAmbientParticles(color: color)
        addChild(CRTEffectNode(size: size))
        isUserInteractionEnabled = true
    }

    private var canContinue = false

    private func buildAmbientParticles(color: SKColor) {
        for _ in 0..<40 {
            let particle = SKSpriteNode(
                color: color.withAlphaComponent(CGFloat.random(in: 0.05...0.2)),
                size: CGSize(width: 2, height: 2))
            particle.position = CGPoint(x: CGFloat.random(in: layout.left...layout.right),
                                        y: CGFloat.random(in: layout.bottom...layout.top))
            addChild(particle)
            particle.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -30...30),
                                y: CGFloat.random(in: -30...30),
                                duration: Double.random(in: 3...8)),
                SKAction.moveBy(x: CGFloat.random(in: -30...30),
                                y: CGFloat.random(in: -30...30),
                                duration: Double.random(in: 3...8))
            ])))
        }

        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run { [weak self] in self?.canContinue = true }
        ]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canContinue else { return }
        SceneManager.shared.transition(to: .credits, from: self)
    }
}
