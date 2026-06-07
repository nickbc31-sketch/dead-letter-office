import SpriteKit

final class DialogueScene: SKScene {

    var dialogueID: String = ""
    var returnSceneType: SceneType = .mainMenu
    var startNodeID: String?

    private var dialogueFile: DialogueFile?
    private var currentNodeIndex: Int = 0
    private var currentLineIndex: Int = 0
    private var isAdvancing: Bool = false
    private var isTyping: Bool = false
    private var awaitingDialogueEnd: Bool = false

    private var portraitNode: SKSpriteNode!
    private var nameLabel: SKLabelNode!
    private var textBox: SKNode!
    private var textLabel: SKLabelNode!
    private var advanceIndicator: SKLabelNode!
    private var choiceContainer: SKNode!
    private var typingTimer: Timer?

    private var layout = SceneLayout.fallback(size: CGSize(width: 844, height: 390))
    private var exitButtonRect = CGRect.zero

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = DLOColor.background
        buildScene()
        loadDialogue()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        // Preserve dialogue state; stop typing and rebuild UI
        typingTimer?.invalidate()
        typingTimer = nil
        isTyping = false
        removeAllChildren()
        buildScene()
        // Re-display the current line with fully-revealed text (skip re-typing)
        if let file = dialogueFile,
           file.nodes.indices.contains(currentNodeIndex),
           file.nodes[currentNodeIndex].lines.indices.contains(currentLineIndex) {
            let line = file.nodes[currentNodeIndex].lines[currentLineIndex]
            nameLabel.text = line.speaker.uppercased()
            textLabel.text = line.text
            advanceIndicator.alpha = 1
        }
    }

    private func buildScene() {
        layout = SceneLayout.make(scene: self)
        buildUI()
    }

    // MARK: - UI
    private func buildUI() {
        let bg = SKSpriteNode(color: DLOColor.background, size: size)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -1
        addChild(bg)

        // Portrait frame — positioned using layout so it stays inside the safe area
        let portraitSize: CGFloat = layout.h * 0.38   // scales with available height
        let portraitCX = layout.x(0.12)
        let portraitCY = layout.y(0.48)

        let portraitFrame = SKShapeNode(rectOf: CGSize(width: portraitSize, height: portraitSize), cornerRadius: 4)
        portraitFrame.strokeColor = DLOColor.uiBorder
        portraitFrame.lineWidth = 2
        portraitFrame.fillColor = DLOColor.terminalBG
        portraitFrame.position = CGPoint(x: portraitCX, y: portraitCY)
        portraitFrame.zPosition = 5
        addChild(portraitFrame)

        portraitNode = SKSpriteNode(color: DLOColor.terminalBG,
                                    size: CGSize(width: portraitSize - 4, height: portraitSize - 4))
        portraitNode.position = portraitFrame.position
        portraitNode.zPosition = 6
        addChild(portraitNode)

        let scanLines = CRTEffectNode(size: CGSize(width: portraitSize, height: portraitSize))
        // CRTEffectNode centres children at (size/2, size/2) in local space,
        // so anchor it at the portrait's bottom-left corner to align correctly.
        scanLines.position = CGPoint(x: portraitCX - portraitSize / 2,
                                     y: portraitCY - portraitSize / 2)
        scanLines.zPosition = 7
        addChild(scanLines)

        let namePlate = SKSpriteNode(color: .black,
                                     size: CGSize(width: portraitSize, height: 24))
        namePlate.position = CGPoint(x: portraitCX, y: portraitCY - portraitSize / 2 - 12)
        namePlate.zPosition = 8
        addChild(namePlate)

        nameLabel = SKLabelNode(text: "")
        nameLabel.fontName = "Menlo-Bold"
        nameLabel.fontSize = 10
        nameLabel.fontColor = DLOColor.terminalAmber
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = namePlate.position
        nameLabel.zPosition = 15  // above textBox bg (global z=10) and border (z=11)
        addChild(nameLabel)

        textBox = buildTextBox()
        addChild(textBox)

        // Advance indicator sits inside the textbox at its bottom-right corner
        // so it never dips below the box or overlaps the home-indicator zone.
        let boxBottomY = layout.y(0.04)
        advanceIndicator = SKLabelNode(text: "▼ TAP TO CONTINUE")
        advanceIndicator.fontName = "Menlo"
        advanceIndicator.fontSize = 10
        advanceIndicator.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
        advanceIndicator.horizontalAlignmentMode = .right
        advanceIndicator.position = CGPoint(x: layout.right - 16, y: boxBottomY + 14)
        advanceIndicator.zPosition = 20
        advanceIndicator.alpha = 0
        advanceIndicator.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.6),
            SKAction.fadeAlpha(to: 0.9, duration: 0.6)
        ])))
        addChild(advanceIndicator)

        choiceContainer = SKNode()
        choiceContainer.position = CGPoint(x: layout.x(0.22), y: layout.y(0.20))
        choiceContainer.zPosition = 30
        addChild(choiceContainer)

        addChild(CRTEffectNode(size: size))

        // Exit button — top-left corner, visibly tappable (~2× the old size).
        let exitH: CGFloat = 48
        let exitW: CGFloat = 120
        let exitCX = layout.left + exitW / 2
        let exitCY = layout.top - exitH / 2

        let exitBG = SKShapeNode(rectOf: CGSize(width: exitW, height: exitH), cornerRadius: 5)
        exitBG.fillColor   = DLOColor.terminalBG.withAlphaComponent(0.88)
        exitBG.strokeColor = DLOColor.terminalAmber.withAlphaComponent(0.55)
        exitBG.lineWidth   = 1.4
        exitBG.position    = CGPoint(x: exitCX, y: exitCY)
        exitBG.zPosition   = 24
        addChild(exitBG)

        let exitLbl = DLOFont.terminalLabel(text: "✕  MENU", size: 13)
        exitLbl.fontColor              = DLOColor.terminalAmber
        exitLbl.horizontalAlignmentMode = .center
        exitLbl.position   = CGPoint(x: exitCX, y: exitCY - 2)
        exitLbl.zPosition  = 25
        addChild(exitLbl)

        exitButtonRect = CGRect(x: layout.left, y: layout.top - exitH,
                                width: exitW, height: exitH)
    }

    private func buildTextBox() -> SKNode {
        let container = SKNode()

        let boxLeft   = layout.x(0.21)
        let boxBottom = layout.y(0.04)
        let boxW      = layout.right - boxLeft - 8
        let boxH: CGFloat = layout.h * 0.28

        let boxBG = SKSpriteNode(color: DLOColor.terminalBG,
                                  size: CGSize(width: boxW, height: boxH))
        boxBG.anchorPoint = CGPoint(x: 0, y: 0)
        boxBG.position = CGPoint(x: boxLeft, y: boxBottom)
        boxBG.zPosition = 10
        container.addChild(boxBG)

        let boxBorder = SKShapeNode(rectOf: CGSize(width: boxW, height: boxH), cornerRadius: 3)
        boxBorder.strokeColor = DLOColor.uiBorder
        boxBorder.lineWidth = 1.5
        boxBorder.fillColor = .clear
        boxBorder.position = CGPoint(x: boxLeft + boxW / 2, y: boxBottom + boxH / 2)
        boxBorder.zPosition = 11
        container.addChild(boxBorder)

        let fontSize = GameState.shared.subtitlesEnabled
            ? 12 * GameState.shared.textSizeMultiplier
            : CGFloat(12)
        textLabel = SKLabelNode(text: "")
        textLabel.fontName = "Menlo"
        textLabel.fontSize = fontSize
        textLabel.fontColor = DLOColor.terminalAmber
        textLabel.horizontalAlignmentMode = .left
        textLabel.verticalAlignmentMode = .top
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = boxW - 28
        textLabel.position = CGPoint(x: boxLeft + 14, y: boxBottom + boxH - 12)
        textLabel.zPosition = 12
        container.addChild(textLabel)

        return container
    }

    // MARK: - Dialogue Logic
    private func loadDialogue() {
        dialogueFile = DialogueFile.load(id: dialogueID) ?? makeFallbackDialogue()
        if let startID = startNodeID,
           let file = dialogueFile,
           let idx = file.nodes.firstIndex(where: { $0.id == startID }) {
            currentNodeIndex = idx
        } else {
            currentNodeIndex = 0
        }
        currentLineIndex = 0
        presentCurrentLine()
    }

    private func makeFallbackDialogue() -> DialogueFile {
        let line = DialogueLine(speaker: "AUDIT VOICE",
                                portraitAsset: "portrait_audit_voice",
                                text: "Welcome to the Post-Mortem Communications Authority. You will process the final messages of deceased citizens. Do your job. Do not ask questions.",
                                voiceFilter: "terminal")
        let node = DialogueNode(id: "n0", lines: [line], choices: nil,
                                autoAdvance: false, flagsRequired: nil,
                                flagsSet: nil, nextID: nil)
        return DialogueFile(id: "fallback", chapter: "ch1",
                            returnSceneHint: nil, nodes: [node])
    }

    private func presentCurrentLine() {
        guard let file = dialogueFile,
              file.nodes.indices.contains(currentNodeIndex) else {
            endDialogue(); return
        }

        let node = file.nodes[currentNodeIndex]

        if let required = node.flagsRequired,
           !required.allSatisfy({ GameState.shared.hasFlag($0) }) {
            currentNodeIndex += 1
            presentCurrentLine()
            return
        }

        node.flagsSet?.forEach { GameState.shared.setFlag($0) }

        if node.lines.indices.contains(currentLineIndex) {
            displayLine(node.lines[currentLineIndex])
        } else {
            if let choices = node.choices, !choices.isEmpty {
                showChoices(choices)
            } else if let nextID = node.nextID,
                      let nextIdx = file.nodes.firstIndex(where: { $0.id == nextID }) {
                currentNodeIndex = nextIdx
                currentLineIndex = 0
                presentCurrentLine()
            } else {
                // Terminal node: all lines shown, no choices, no nextID.
                // Show advance indicator; flag so the next tap calls endDialogue().
                advanceIndicator.alpha = 1
                awaitingDialogueEnd = true
            }
        }
    }

    private func displayLine(_ line: DialogueLine) {
        advanceIndicator.alpha = 0
        choiceContainer.removeAllChildren()

        if let asset = line.portraitAsset {
            if UIImage(named: asset) != nil {
                portraitNode.texture = SKTexture(imageNamed: asset)
                portraitNode.color = .clear
                portraitNode.colorBlendFactor = 0
            } else {
                portraitNode.texture = nil
                portraitNode.color = generatePlaceholderPortraitColor(for: line.speaker)
                portraitNode.colorBlendFactor = 1
            }
        }

        nameLabel.text = line.speaker.uppercased()
        typeText(line.text, filter: line.voiceFilter)
    }

    private func generatePlaceholderPortraitColor(for speaker: String) -> SKColor {
        let colors: [SKColor] = [
            DLOColor.terminalBG, .fromHex("#0A1520"), .fromHex("#12203A"),
            .fromHex("#0E1826"), .fromHex("#161C28")
        ]
        return colors[abs(speaker.hashValue) % colors.count]
    }

    private func typeText(_ text: String, filter: String?) {
        isTyping = true
        textLabel.text = ""

        let chars = Array(text)
        var displayedChars: [Character] = []
        var charIndex = 0
        let interval: TimeInterval = filter == "terminal" ? 0.02 : 0.03

        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self, charIndex < chars.count else {
                self?.isTyping = false
                self?.advanceIndicator.alpha = 1
                timer.invalidate()
                return
            }
            displayedChars.append(chars[charIndex])
            charIndex += 1
            DispatchQueue.main.async { self.textLabel.text = String(displayedChars) }
        }
    }

    private func showChoices(_ choices: [DialogueChoice]) {
        choiceContainer.removeAllChildren()
        advanceIndicator.alpha = 0

        let file = dialogueFile!
        // Width fits the right portion of the scene from choiceContainer's column to safe right edge.
        let btnWidth = max(180, layout.right - layout.x(0.22) - 8)
        var yOff: CGFloat = 0
        for choice in choices {
            if let req = choice.flagsRequired,
               !req.allSatisfy({ GameState.shared.hasFlag($0) }) { continue }

            let btn = ChoiceButtonNode(text: choice.text, width: btnWidth) { [weak self] in
                guard let self = self else { return }
                choice.flagsSet?.forEach { GameState.shared.setFlag($0) }
                if let nextID = choice.nextDialogueID,
                   let nextIdx = file.nodes.firstIndex(where: { $0.id == nextID }) {
                    self.currentNodeIndex = nextIdx
                    self.currentLineIndex = 0
                    self.choiceContainer.removeAllChildren()
                    self.presentCurrentLine()
                } else {
                    self.endDialogue()
                }
            }
            btn.position = CGPoint(x: 0, y: yOff)
            choiceContainer.addChild(btn)
            yOff -= 36
        }
    }

    private func endDialogue() {
        GameState.shared.save()
        SceneManager.shared.transition(to: returnSceneType, from: self)
    }

    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Exit-to-menu button takes priority over dialogue advance.
        if let touch = touches.first {
            let pos = touch.location(in: self)
            if exitButtonRect.contains(pos) {
                typingTimer?.invalidate()
                AudioManager.shared.playUIClick()
                SceneManager.shared.transition(to: .mainMenu, from: self)
                return
            }
        }

        if isTyping {
            typingTimer?.invalidate()
            isTyping = false
            if let file = dialogueFile,
               file.nodes.indices.contains(currentNodeIndex),
               file.nodes[currentNodeIndex].lines.indices.contains(currentLineIndex) {
                textLabel.text = file.nodes[currentNodeIndex].lines[currentLineIndex].text
            }
            advanceIndicator.alpha = 1
            return
        }

        guard !isAdvancing else { return }

        // Terminal node reached — next tap ends the dialogue
        if awaitingDialogueEnd {
            endDialogue()
            return
        }

        let node = dialogueFile?.nodes[safe: currentNodeIndex]
        if node?.choices != nil && !(node?.choices?.isEmpty ?? true) { return }

        currentLineIndex += 1
        AudioManager.shared.playDialogueContinue()
        presentCurrentLine()
    }
}

// MARK: - Choice Button
private final class ChoiceButtonNode: SKNode {
    private let tapAction: () -> Void

    init(text: String, width: CGFloat = 400, action: @escaping () -> Void) {
        self.tapAction = action
        super.init()
        isUserInteractionEnabled = true

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: 30), cornerRadius: 3)
        bg.fillColor = DLOColor.terminalBG
        bg.strokeColor = DLOColor.uiBorder
        bg.lineWidth = 1
        addChild(bg)

        let lbl = SKLabelNode(text: "> \(text)")
        lbl.fontName = "Menlo"
        lbl.fontSize = 11
        lbl.fontColor = DLOColor.terminalAmber
        lbl.horizontalAlignmentMode = .left
        lbl.verticalAlignmentMode = .center
        lbl.numberOfLines = 0
        lbl.preferredMaxLayoutWidth = width - 20
        lbl.position = CGPoint(x: -width / 2 + 10, y: 0)
        addChild(lbl)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 0.6 }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1.0
        AudioManager.shared.playDialogueContinue()
        tapAction()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 1.0 }
}

// Safe subscript for arrays
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
