import SpriteKit

final class SettingsScene: SKScene {

    private var layout  = SceneLayout.fallback(size: CGSize(width: 844, height: 390))
    private var backRect:       CGRect = .zero
    private var resumeRect:     CGRect = .zero
    private var deleteRect:     CGRect = .zero
    private var confirmPanel: SKNode?
    private var confirmRect:   CGRect = .zero
    private var cancelledRect: CGRect = .zero
    private var awaitingConfirm = false
    private var voiceHelpPanel: SKNode?
    private var voiceHelpOkRect = CGRect.zero
    private var voiceQualityHelpRect = CGRect.zero
    private var awaitingVoiceHelpModal = false

    // Scene-level interactive tracking (proven DeskScene/MainMenuScene pattern)
    private struct ToggleItem {
        var hitRect: CGRect
        var isOn: Bool
        weak var indicator: SKShapeNode?
        weak var bg: SKShapeNode?
        let onChange: (Bool) -> Void
    }
    private struct SliderItem {
        var hitRect: CGRect
        var trackLeft: CGFloat
        var trackWidth: CGFloat
        var currentValue: CGFloat
        weak var knob: SKShapeNode?
        let onChange: (CGFloat) -> Void
    }
    private var toggleItems: [ToggleItem] = []
    private var sliderItems: [SliderItem] = []
    private var activeSliderIndex: Int? = nil

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = DLOColor.background
        buildScene()
        if GameState.shared.settingsReturnDestination == nil {
            AudioManager.shared.playMainMenuMusic()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        confirmPanel = nil
        toggleItems.removeAll()
        sliderItems.removeAll()
        activeSliderIndex = nil
        removeAllChildren()
        buildScene()
    }

    private func buildScene() {
        layout = SceneLayout.make(scene: self)
        toggleItems.removeAll()
        sliderItems.removeAll()
        buildLayout()
        addChild(CRTEffectNode(size: size))
    }

    // MARK: - Layout

    private func buildLayout() {
        let hdr = DLOFont.titleLabel(text: "SETTINGS", size: 22)
        hdr.position = CGPoint(x: layout.midX, y: layout.y(0.86))
        addChild(hdr)

        let divider = SKSpriteNode(color: DLOColor.uiBorder,
                                   size: CGSize(width: layout.w * 0.6, height: 1))
        divider.position = CGPoint(x: layout.midX, y: layout.y(0.80))
        addChild(divider)

        let state = GameState.shared
        var yPos: CGFloat = layout.y(0.72)
        let rowStep: CGFloat = layout.h * 0.11

        addToggle(label: "SUBTITLES", value: state.subtitlesEnabled, y: yPos) { val in
            GameState.shared.subtitlesEnabled = val; GameState.shared.save()
        }
        yPos -= rowStep

        addToggle(label: "REDUCED FLASHING", value: state.reducedFlashingEnabled, y: yPos) { val in
            GameState.shared.reducedFlashingEnabled = val; GameState.shared.save()
        }
        yPos -= rowStep

        addToggle(label: "AUTO-READ FIELD NOTES", value: state.autoReadFieldNotes, y: yPos) { val in
            GameState.shared.autoReadFieldNotes = val
            GameState.shared.hasChosenPlayStyle = true
            GameState.shared.save()
        }
        addFieldNotesVoiceHint(y: yPos - rowStep * 0.52)
        yPos -= rowStep

        addSlider(label: "MUSIC VOLUME", value: CGFloat(state.musicVolume), y: yPos) { val in
            GameState.shared.musicVolume = Float(val)
            AudioManager.shared.setMusicVolume(Float(val))
            GameState.shared.save()
        }
        yPos -= rowStep

        addSlider(label: "SFX VOLUME", value: CGFloat(state.sfxVolume), y: yPos) { val in
            GameState.shared.sfxVolume = Float(val); GameState.shared.save()
        }
        yPos -= rowStep

        addSlider(label: "TEXT SIZE", value: (state.textSizeMultiplier - 0.8) / 0.8, y: yPos) { val in
            GameState.shared.textSizeMultiplier = 0.8 + val * 0.8; GameState.shared.save()
        }
        yPos -= rowStep * 1.2

        let btnH: CGFloat = 36
        let btnW: CGFloat = layout.w * 0.34
        let hasReturn = GameState.shared.settingsReturnDestination != nil

        if hasReturn {
            buildTextButton(text: "> RETURN TO GAME", x: layout.midX, y: yPos, color: DLOColor.teal)
            resumeRect = CGRect(x: layout.midX - btnW / 2, y: yPos - btnH / 2, width: btnW, height: btnH)
            yPos -= rowStep * 0.95
        } else {
            resumeRect = .zero
        }

        buildTextButton(text: "< BACK TO MENU", x: layout.x(0.15), y: yPos, color: DLOColor.terminalAmber)
        backRect = CGRect(x: layout.x(0.15) - 8, y: yPos - btnH / 2, width: btnW, height: btnH)
        buildTextButton(text: "DELETE SAVE DATA", x: layout.x(0.62), y: yPos, color: DLOColor.danger)
        deleteRect = CGRect(x: layout.x(0.62) - 8, y: yPos - btnH / 2, width: btnW, height: btnH)
    }

    private func addFieldNotesVoiceHint(y: CGFloat) {
        let rowWidth = layout.w * 0.6
        let hint = SKLabelNode()
        hint.fontName = "Menlo"
        hint.fontSize = 8
        hint.fontColor = DLOColor.uiBorder.withAlphaComponent(0.7)
        hint.horizontalAlignmentMode = .left
        hint.verticalAlignmentMode = .center
        hint.numberOfLines = 0
        hint.preferredMaxLayoutWidth = rowWidth * 0.88
        hint.text = FieldNotesVoiceHelp.settingsHint
        hint.position = CGPoint(x: layout.midX - rowWidth / 2 + 10, y: y + 6)
        addChild(hint)

        let link = DLOFont.terminalLabel(text: FieldNotesVoiceHelp.linkLabel, size: 9)
        link.fontColor = DLOColor.teal.withAlphaComponent(0.9)
        link.horizontalAlignmentMode = .left
        link.position = CGPoint(x: layout.midX - rowWidth / 2 + 10, y: y - 14)
        addChild(link)

        voiceQualityHelpRect = CGRect(
            x: layout.midX - rowWidth / 2,
            y: y - 28,
            width: rowWidth,
            height: 36)
    }

    private func showVoiceQualityHelp() {
        FieldNotesVoiceHelp.showModal(
            in: self, layout: layout,
            panelNode: &voiceHelpPanel,
            okRect: &voiceHelpOkRect)
        awaitingVoiceHelpModal = true
    }

    private func dismissVoiceQualityHelp() {
        awaitingVoiceHelpModal = false
        voiceHelpPanel?.removeFromParent()
        voiceHelpPanel = nil
        voiceHelpOkRect = .zero
    }

    // MARK: - Toggle (scene-level touch, no isUserInteractionEnabled on node)

    private func addToggle(label: String, value: Bool, y: CGFloat,
                            onChange: @escaping (Bool) -> Void) {
        let rowWidth = layout.w * 0.6

        let lbl = DLOFont.terminalLabel(text: label, size: 11)
        lbl.horizontalAlignmentMode = .left
        lbl.position = CGPoint(x: layout.midX - rowWidth / 2 + 10, y: y)
        addChild(lbl)

        let toggleX = layout.midX + rowWidth / 2 - 40
        let toggleBG = SKShapeNode(rectOf: CGSize(width: 52, height: 24), cornerRadius: 12)
        toggleBG.position = CGPoint(x: toggleX, y: y)
        toggleBG.strokeColor = DLOColor.uiBorder
        toggleBG.fillColor = value ? DLOColor.teal.withAlphaComponent(0.3) : DLOColor.terminalBG
        addChild(toggleBG)

        let indicator = SKShapeNode(circleOfRadius: 10)
        indicator.fillColor = value ? DLOColor.teal : DLOColor.uiBorder
        indicator.strokeColor = .clear
        indicator.position = CGPoint(x: toggleX + (value ? 12 : -12), y: y)
        addChild(indicator)

        let hitRect = CGRect(x: layout.midX - rowWidth / 2,
                             y: y - 22, width: rowWidth, height: 44)
        toggleItems.append(ToggleItem(hitRect: hitRect, isOn: value,
                                      indicator: indicator, bg: toggleBG,
                                      onChange: onChange))
    }

    // MARK: - Slider (scene-level drag, no isUserInteractionEnabled on node)

    private func addSlider(label: String, value: CGFloat, y: CGFloat,
                            onChange: @escaping (CGFloat) -> Void) {
        let rowWidth = layout.w * 0.6
        let trackWidth = rowWidth * 0.45
        // Track center in scene coords: node is at midX, track offset is (rowWidth/2 - trackWidth/2 - 10)
        let trackCenterX = layout.midX + rowWidth / 2 - trackWidth / 2 - 10
        let trackLeft    = trackCenterX - trackWidth / 2

        let lbl = DLOFont.terminalLabel(text: label, size: 11)
        lbl.horizontalAlignmentMode = .left
        lbl.position = CGPoint(x: layout.midX - rowWidth / 2 + 10, y: y + 10)
        addChild(lbl)

        let track = SKShapeNode(rectOf: CGSize(width: trackWidth, height: 4), cornerRadius: 2)
        track.position = CGPoint(x: trackCenterX, y: y - 2)
        track.fillColor = DLOColor.uiBorder.withAlphaComponent(0.4)
        track.strokeColor = .clear
        addChild(track)

        let knob = SKShapeNode(circleOfRadius: 9)
        knob.fillColor = DLOColor.teal
        knob.strokeColor = DLOColor.teal.withAlphaComponent(0.3)
        knob.lineWidth = 3
        knob.position = CGPoint(x: trackLeft + value * trackWidth, y: y - 2)
        addChild(knob)

        let hitRect = CGRect(x: layout.midX - rowWidth / 2,
                             y: y - 22, width: rowWidth, height: 44)
        sliderItems.append(SliderItem(hitRect: hitRect, trackLeft: trackLeft,
                                      trackWidth: trackWidth, currentValue: value,
                                      knob: knob, onChange: onChange))
    }

    private func buildTextButton(text: String, x: CGFloat, y: CGFloat, color: SKColor) {
        let lbl = DLOFont.terminalLabel(text: text, size: 11)
        lbl.fontColor = color
        lbl.position  = CGPoint(x: x, y: y)
        addChild(lbl)
        let underline = SKSpriteNode(
            color: color.withAlphaComponent(0.4),
            size: CGSize(width: layout.w * 0.28, height: 1))
        underline.anchorPoint = CGPoint(x: 0, y: 0.5)
        underline.position    = CGPoint(x: x, y: y - 14)
        addChild(underline)
    }

    // MARK: - Touch (scene-level)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)
        if awaitingConfirm { return }
        // Start slider drag if touch lands in a slider row
        for (i, slider) in sliderItems.enumerated() {
            if slider.hitRect.contains(pos) {
                activeSliderIndex = i
                applySliderDrag(index: i, touchX: pos.x)
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let idx = activeSliderIndex else { return }
        let pos = touch.location(in: self)
        applySliderDrag(index: idx, touchX: pos.x)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)
        let wasSliding = activeSliderIndex != nil
        activeSliderIndex = nil

        if awaitingVoiceHelpModal {
            if voiceHelpOkRect.contains(pos) {
                AudioManager.shared.playUIClick()
                dismissVoiceQualityHelp()
            }
            return
        }

        if awaitingConfirm {
            if confirmRect.contains(pos) {
                AudioManager.shared.playUIClick()
                awaitingConfirm = false
                confirmPanel?.removeFromParent(); confirmPanel = nil
                SaveManager.shared.deleteSave()
                run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.3),
                    SKAction.run { [weak self] in
                        guard let self else { return }
                        SceneManager.shared.transition(to: .mainMenu, from: self)
                    }
                ]))
            } else if cancelledRect.contains(pos) {
                AudioManager.shared.playUIClick()
                awaitingConfirm = false
                confirmPanel?.removeFromParent(); confirmPanel = nil
            }
            return
        }

        // Slider: don't fire toggle if we were dragging
        if wasSliding { return }

        // Toggle tap
        for (i, toggle) in toggleItems.enumerated() {
            if toggle.hitRect.contains(pos) {
                AudioManager.shared.playUIClick()
                applyToggleTap(index: i)
                return
            }
        }

        if voiceQualityHelpRect.contains(pos) {
            AudioManager.shared.playUIClick()
            showVoiceQualityHelp()
            return
        }

        if resumeRect.contains(pos) { AudioManager.shared.playUIClick(); returnToGame() }
        if backRect.contains(pos)   { AudioManager.shared.playUIClick(); goBack() }
        if deleteRect.contains(pos) { AudioManager.shared.playUIClick(); confirmDeleteSave() }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliderIndex = nil
    }

    // MARK: - Slider update

    private func applySliderDrag(index: Int, touchX: CGFloat) {
        let s = sliderItems[index]
        let clamped = max(0, min(1, (touchX - s.trackLeft) / s.trackWidth))
        sliderItems[index].currentValue = clamped
        sliderItems[index].knob?.position.x = s.trackLeft + clamped * s.trackWidth
        s.onChange(clamped)
    }

    // MARK: - Toggle update

    private func applyToggleTap(index: Int) {
        toggleItems[index].isOn.toggle()
        let isOn = toggleItems[index].isOn
        let curX = toggleItems[index].indicator?.position.x ?? 0
        // Snap to correct position (24pt swing)
        let targetX = curX + (isOn ? 24 : -24)
        toggleItems[index].indicator?.run(SKAction.moveTo(x: targetX, duration: 0.15))
        toggleItems[index].indicator?.fillColor = isOn ? DLOColor.teal : DLOColor.uiBorder
        toggleItems[index].bg?.fillColor = isOn
            ? DLOColor.teal.withAlphaComponent(0.3) : DLOColor.terminalBG
        toggleItems[index].onChange(isOn)
    }

    // MARK: - Actions

    private func goBack() {
        GameState.shared.settingsReturnDestination = nil
        SceneManager.shared.transition(to: .mainMenu, from: self)
    }

    private func returnToGame() {
        SceneManager.shared.returnFromSettings(from: self)
    }

    private func confirmDeleteSave() {
        confirmPanel?.removeFromParent()

        let panelW = layout.w * 0.60
        let panelH = layout.h * 0.28

        let panel = SKNode()
        panel.zPosition = 1000
        panel.position  = layout.center

        let bg = SKSpriteNode(color: DLOColor.terminalBG,
                              size: CGSize(width: panelW, height: panelH))
        bg.strokeBorderWith(DLOColor.danger, width: 1.5, cornerRadius: 4)
        panel.addChild(bg)

        let msg = DLOFont.terminalLabel(
            text: "DELETE ALL SAVE DATA? THIS CANNOT BE UNDONE.", size: 11)
        msg.horizontalAlignmentMode = .center
        msg.position = CGPoint(x: 0, y: panelH * 0.18)
        panel.addChild(msg)

        let btnY: CGFloat = -panelH * 0.22

        let confirmLbl = DLOFont.terminalLabel(text: "CONFIRM DELETE", size: 11)
        confirmLbl.fontColor = DLOColor.danger
        confirmLbl.horizontalAlignmentMode = .center
        confirmLbl.position = CGPoint(x: -panelW * 0.22, y: btnY)
        panel.addChild(confirmLbl)

        let cancelLbl = DLOFont.terminalLabel(text: "CANCEL", size: 11)
        cancelLbl.fontColor = DLOColor.terminalAmber
        cancelLbl.horizontalAlignmentMode = .center
        cancelLbl.position = CGPoint(x: panelW * 0.22, y: btnY)
        panel.addChild(cancelLbl)

        addChild(panel)
        confirmPanel = panel

        let cX = layout.center.x - panelW * 0.22
        let dX = layout.center.x + panelW * 0.22
        let bY = layout.center.y + btnY
        let bH: CGFloat = 44
        confirmRect   = CGRect(x: cX - 80, y: bY - bH / 2, width: 160, height: bH)
        cancelledRect = CGRect(x: dX - 60, y: bY - bH / 2, width: 120, height: bH)
        awaitingConfirm = true
    }
}

// MARK: - SKSpriteNode border helper

private extension SKSpriteNode {
    func strokeBorderWith(_ color: SKColor, width: CGFloat, cornerRadius: CGFloat) {
        let border = SKShapeNode(rectOf: self.size, cornerRadius: cornerRadius)
        border.strokeColor = color
        border.lineWidth   = width
        border.fillColor   = .clear
        border.zPosition   = 1
        addChild(border)
    }
}
