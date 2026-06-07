import SpriteKit

final class ChapterSelectScene: SKScene {

    private var chapters: [ChapterData] = []
    private var layout  = SceneLayout.fallback(size: CGSize(width: 844, height: 390))
    private var backRect = CGRect.zero

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        backgroundColor = DLOColor.background
        chapters = ChapterData.loadAll()
        if chapters.isEmpty { chapters = placeholderChapters() }
        buildScene()
        AudioManager.shared.playMainMenuMusic()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 100, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 5 || abs(size.height - oldSize.height) > 5 else { return }
        removeAllChildren()
        buildScene()
    }

    private func buildScene() {
        layout = SceneLayout.make(scene: self)
        buildLayout()
        addChild(CRTEffectNode(size: size))
    }

    private func buildLayout() {
        let hdr = DLOFont.titleLabel(text: "CHAPTER SELECT", size: 22)
        hdr.position = CGPoint(x: layout.midX, y: layout.y(0.88))
        addChild(hdr)

        let subHdr = DLOFont.terminalLabel(text: "SELECT SHIFT TO RESUME OR REPLAY", size: 10)
        subHdr.position = CGPoint(x: layout.x(0.05), y: layout.y(0.80))
        subHdr.fontColor = DLOColor.uiBorder
        addChild(subHdr)

        let state = GameState.shared
        let colCount = 4
        let cellW = layout.w * 0.22
        let cellH: CGFloat = 100
        let startX = layout.x(0.02) + cellW / 2
        let startY = layout.y(0.65)

        for (i, chapter) in chapters.enumerated() {
            let col = i % colCount
            let row = i / colCount
            let x = startX + CGFloat(col) * (cellW + 12)
            let y = startY - CGFloat(row) * (cellH + 16)

            let isUnlocked = isChapterUnlocked(chapter, state: state)
            let cell = ChapterCellNode(
                chapter: chapter,
                isUnlocked: isUnlocked,
                isCompleted: state.completedCaseIDs.contains(where: { $0.hasPrefix(chapter.id) }),
                size: CGSize(width: cellW - 8, height: cellH)) { [weak self] in
                    guard let self = self, isUnlocked else { return }
                    AudioManager.shared.stopMainMenuMusic()
                    GameState.shared.currentChapterID = chapter.id
                    SceneManager.shared.transition(to: .desk(chapterID: chapter.id), from: self)
                }
            cell.position = CGPoint(x: x, y: y)
            addChild(cell)
        }

        let backLbl = DLOFont.terminalLabel(text: "< BACK", size: 11)
        backLbl.fontColor = DLOColor.uiBorder
        backLbl.position = CGPoint(x: layout.x(0.07), y: layout.y(0.05))
        addChild(backLbl)
        backRect = CGRect(x: layout.x(0.07) - 50, y: layout.y(0.05) - 20,
                          width: 120, height: 44)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        if backRect.contains(pos) {
            AudioManager.shared.playUIClick()
            SceneManager.shared.transition(to: .mainMenu, from: self)
        }
    }

    private func isChapterUnlocked(_ chapter: ChapterData, state: GameState) -> Bool {
        guard let required = chapter.unlockRequires else { return true }
        return required.allSatisfy { state.hasFlag($0) }
    }

    private func placeholderChapters() -> [ChapterData] {
        let chapterMeta: [(String, String, String)] = [
            ("ch1", "I. ORIENTATION",        "Your first shift begins."),
            ("ch2", "II. THE MISFILED LIVING","Something is wrong."),
            ("ch3", "III. THE DAUGHTER CLAUSE","A father's last plea."),
            ("ch4", "IV. GHOST AUDIT",        "Your name is on the list."),
            ("ch5", "V. AFTERLIFE PREMIUM",   "Death is a luxury product."),
            ("ch6", "VI. BLACK MAIL TRAIN",   "Forbidden letters in motion."),
            ("ch7", "VII. THE CHOIR BENEATH", "The living, buried in the city."),
            ("ch8", "VIII. DEAD LETTER OFFICE","Your final shift.")
        ]
        return chapterMeta.map { (id, title, subtitle) in
            ChapterData(id: id, title: title, subtitle: subtitle,
                        splashImageName: "splash_\(id)",
                        ambientMusicTrack: "ambient_desk",
                        segments: [],
                        unlockRequires: id == "ch1" ? nil : ["\(id)_unlocked"],
                        summary: subtitle)
        }
    }
}

private final class ChapterCellNode: SKNode {
    init(chapter: ChapterData, isUnlocked: Bool, isCompleted: Bool,
         size: CGSize, onTap: @escaping () -> Void) {
        super.init()
        isUserInteractionEnabled = true

        let mult = GameState.shared.textSizeMultiplier
        let borderColor: SKColor = isCompleted ? DLOColor.terminalGreen :
                                   isUnlocked  ? DLOColor.uiBorder :
                                                 DLOColor.uiBorder.withAlphaComponent(0.3)
        let bg = SKShapeNode(rectOf: size, cornerRadius: 4)
        bg.fillColor = DLOColor.terminalBG
        bg.strokeColor = borderColor
        bg.lineWidth = 1.5
        bg.alpha = isUnlocked ? 1.0 : 0.35
        addChild(bg)

        let titleLbl = SKLabelNode(text: chapter.title)
        titleLbl.fontName = "Menlo-Bold"
        titleLbl.fontSize = 11 * mult
        titleLbl.fontColor = isUnlocked ? DLOColor.terminalAmber : DLOColor.dimText
        titleLbl.horizontalAlignmentMode = .center
        titleLbl.verticalAlignmentMode = .center
        titleLbl.numberOfLines = 2
        titleLbl.preferredMaxLayoutWidth = size.width - 12
        titleLbl.position = CGPoint(x: 0, y: 12)
        addChild(titleLbl)

        let subLbl = SKLabelNode(text: isUnlocked ? chapter.subtitle : "[ LOCKED ]")
        subLbl.fontName = "Menlo"
        subLbl.fontSize = 9 * mult
        subLbl.fontColor = DLOColor.dimText
        subLbl.horizontalAlignmentMode = .center
        subLbl.verticalAlignmentMode = .center
        subLbl.numberOfLines = 2
        subLbl.preferredMaxLayoutWidth = size.width - 12
        subLbl.position = CGPoint(x: 0, y: -18)
        addChild(subLbl)

        if isCompleted {
            let check = SKLabelNode(text: "✓")
            check.fontName = "Menlo-Bold"
            check.fontSize = 10
            check.fontColor = DLOColor.terminalGreen
            check.position = CGPoint(x: size.width / 2 - 12, y: size.height / 2 - 12)
            addChild(check)
        }

        // SKShapeNode bg already provides a valid accumulated frame; no clear sprite needed.
        userData = NSMutableDictionary()
        userData?["action"] = onTap as AnyObject
    }
    required init?(coder: NSCoder) { fatalError() }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 0.7 }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1.0
        guard userData?["action"] != nil else { return }
        AudioManager.shared.playUIClick()
        (userData?["action"] as? () -> Void)?()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 1.0 }
}

private final class SimpleTextButton: SKNode {
    private let btnSize: CGSize
    init(label: String, size: CGSize, color: SKColor, action: @escaping () -> Void) {
        self.btnSize = size
        super.init()
        isUserInteractionEnabled = true
        let lbl = DLOFont.terminalLabel(text: label, size: 11)
        lbl.fontColor = color
        addChild(lbl)
        userData = NSMutableDictionary()
        userData?["action"] = action as AnyObject
    }
    required init?(coder: NSCoder) { fatalError() }
    override func calculateAccumulatedFrame() -> CGRect {
        // Local-space rect centred on the node's origin (not parent-space position).
        CGRect(x: -btnSize.width / 2, y: -btnSize.height / 2,
               width: btnSize.width, height: btnSize.height)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        (userData?["action"] as? () -> Void)?()
    }
}
