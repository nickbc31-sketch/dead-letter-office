#if DEBUG
import SpriteKit

/// DEBUG-only field/platform launcher for visual QA — Shifts 1–8.
final class DebugFieldTestScene: SKScene {

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))

    private struct ButtonTarget {
        let rect: CGRect
        let action: () -> Void
    }
    private var buttonTargets: [ButtonTarget] = []

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = DLOColor.background
        buildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        buildScene()
    }

    private func buildScene() {
        removeAllChildren()
        buttonTargets.removeAll()
        layout = SceneLayout.make(scene: self)

        let hdr = DLOFont.titleLabel(text: "DEBUG FIELD TEST", size: 18)
        hdr.position = CGPoint(x: layout.midX, y: layout.y(0.90))
        addChild(hdr)

        let sub = DLOFont.terminalLabel(text: "VISUAL QA — LAUNCH DIRECTLY INTO FIELD SECTIONS", size: 8)
        sub.fontColor = DLOColor.uiBorder
        sub.horizontalAlignmentMode = .center
        sub.position = CGPoint(x: layout.midX, y: layout.y(0.84))
        addChild(sub)

        buildShiftButtons()
        buildFooterButtons()
        addChild(CRTEffectNode(size: size))
    }

    private func buildShiftButtons() {
        let colW = layout.w * 0.24
        let rowH: CGFloat = 34
        var x = layout.x(0.06)
        var y = layout.y(0.72)

        for shift in 1...8 {
            let levelID = "level_ch\(shift)"
            let exists = LevelData.load(id: levelID) != nil
            let label = exists
                ? "FIELD TEST — SHIFT \(shift)"
                : "SHIFT \(shift) (MISSING)"
            addButton(
                label: label,
                x: x + colW / 2,
                y: y,
                width: colW - 10,
                enabled: exists
            ) { [weak self] in
                guard let self else { return }
                DebugFieldTestSession.launchShift(shift, from: self)
            }

            x += colW
            if shift % 4 == 0 {
                x = layout.x(0.06)
                y -= rowH
            }
        }
    }

    private func buildFooterButtons() {
        addButton(label: "< MAIN MENU", x: layout.x(0.20), y: layout.y(0.10),
                  width: layout.w * 0.28) { [weak self] in
            guard let self else { return }
            DebugFieldTestSession.endAndReturnToMainMenu(from: self)
        }

        addButton(label: "FULL DEBUG MENU", x: layout.x(0.52), y: layout.y(0.10),
                  width: layout.w * 0.28) { [weak self] in
            guard let self else { return }
            DebugFieldTestSession.restoreSnapshotOnly()
            SceneManager.shared.transition(to: .debug, from: self)
        }

        addButton(label: "END SESSION + RESET SAVE VIEW", x: layout.x(0.82), y: layout.y(0.10),
                  width: layout.w * 0.30, color: DLOColor.danger) { [weak self] in
            guard let self else { return }
            DebugFieldTestSession.restoreSnapshotOnly()
            self.buildScene()
        }
    }

    private func addButton(
        label: String,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        color: SKColor = DLOColor.uiBorder,
        enabled: Bool = true,
        action: @escaping () -> Void
    ) {
        let h: CGFloat = 28
        let alpha: CGFloat = enabled ? 1.0 : 0.35
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: h), cornerRadius: 3)
        bg.fillColor = color.withAlphaComponent(0.15 * alpha)
        bg.strokeColor = color.withAlphaComponent(0.55 * alpha)
        bg.lineWidth = 1
        bg.position = CGPoint(x: x, y: y)
        addChild(bg)

        let lbl = DLOFont.terminalLabel(text: label, size: 7)
        lbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(alpha)
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: x, y: y - 3)
        addChild(lbl)

        if enabled {
            buttonTargets.append(ButtonTarget(
                rect: CGRect(x: x - width / 2, y: y - h / 2, width: width, height: h),
                action: action))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)
        for target in buttonTargets where target.rect.contains(pos) {
            target.action()
            return
        }
    }
}
#endif
