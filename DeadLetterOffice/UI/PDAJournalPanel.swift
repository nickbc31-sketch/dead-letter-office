import SpriteKit

/// Full investigation PDA — boot, hub menu, and scrollable section views.
enum PDAJournalPanel {

    enum Screen: Equatable {
        case boot
        case hub
        case section(PDASection, shift: Int)
    }

    enum PDASection: String, Equatable {
        case journal
        case objectives
        case discoveries
    }

    struct HitRegions {
        var close: CGRect = .zero
        var scrollBody: CGRect = .zero
        var shiftBar: CGRect = .zero
        var buttons: [(CGRect, String)] = []
    }

    struct BuildResult {
        let panel: SKNode
        var scrollState: ScrollableReadablePanel.ScrollState?
        let regions: HitRegions
        let screen: Screen
    }

    private static let pdaTeal = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 1)
    private static let pdaBorder = SKColor(red: 0.38, green: 0.48, blue: 0.42, alpha: 1)
    private static let pdaBG = SKColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 1)
    private static let pdaText = SKColor(red: 0.78, green: 0.84, blue: 0.74, alpha: 1)

    // MARK: - Build

    static func build(
        screen: Screen,
        panelSize: CGSize,
        center: CGPoint,
        textMultiplier: CGFloat,
        currentShift: Int,
        chapterID: String? = nil,
        fieldObjective: String? = nil,
        onRebuild: @escaping (Screen) -> Void,
        onClose: @escaping () -> Void
    ) -> BuildResult {
        switch screen {
        case .boot:
            return buildBoot(panelSize: panelSize, center: center, textMultiplier: textMultiplier,
                             onRebuild: onRebuild, onClose: onClose)
        case .hub:
            return buildHub(panelSize: panelSize, center: center, textMultiplier: textMultiplier,
                            onRebuild: onRebuild, onClose: onClose)
        case .section(let section, let shift):
            return buildSection(section, shift: shift, currentShift: currentShift,
                                panelSize: panelSize, center: center,
                                textMultiplier: textMultiplier, chapterID: chapterID,
                                fieldObjective: fieldObjective, onRebuild: onRebuild, onClose: onClose)
        }
    }

    static func initialScreen(currentShift: Int, skipBoot: Bool) -> Screen {
        if skipBoot { return .hub }
        return .boot
    }

    // MARK: - Boot

    private static func buildBoot(
        panelSize: CGSize, center: CGPoint, textMultiplier: CGFloat,
        onRebuild: @escaping (Screen) -> Void, onClose: @escaping () -> Void
    ) -> BuildResult {
        let panel = SKNode()
        panel.position = center
        var regions = HitRegions()

        addChrome(to: panel, size: panelSize, header: "MARA PDA")

        let bodySize = CGSize(width: panelSize.width - 24, height: panelSize.height - 120)
        let bodyY = -panelSize.height / 2 + 70

        let lines = [
            "PMCA PERSONAL DEVICE",
            "MARA VENN",
            "",
            "AUTHENTICATING...",
            "",
            "WELCOME BACK, MARA",
        ]
        let lbl = makeBodyLabel(text: lines.joined(separator: "\n"), width: bodySize.width, size: 13 * textMultiplier)
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: 0, y: bodyY + bodySize.height / 2 - 8)
        panel.addChild(lbl)

        let closeY = -panelSize.height / 2 + 26
        let openY = closeY + 52
        let openW: CGFloat = min(panelSize.width * 0.55, 200)
        let openH: CGFloat = max(36, 30 * textMultiplier)
        regions.buttons.append((buttonHitRect(center: center, width: openW, height: openH, localY: openY), "open_pda"))

        let openBtn = makeButton(label: "[ OPEN PDA ]", width: openW, size: 12 * textMultiplier)
        openBtn.position = CGPoint(x: 0, y: openY)
        panel.addChild(openBtn)

        regions.close = closeRect(panelSize: panelSize, center: center, labelSize: 11 * textMultiplier)
        addCloseButton(to: panel, panelSize: panelSize, size: 11 * textMultiplier)

        return BuildResult(panel: panel, scrollState: nil, regions: regions, screen: .boot)
    }

    // MARK: - Hub (Journal / Objectives / Discoveries / Close)

    private static func buildHub(
        panelSize: CGSize, center: CGPoint, textMultiplier: CGFloat,
        onRebuild: @escaping (Screen) -> Void, onClose: @escaping () -> Void
    ) -> BuildResult {
        let panel = SKNode()
        panel.position = center
        var regions = HitRegions()

        addChrome(to: panel, size: panelSize, header: "MARA PDA")

        let btnW: CGFloat = min(panelSize.width * 0.55, 220)
        let btnH: CGFloat = max(36, 30 * textMultiplier)
        let btnGap: CGFloat = max(12, 8 * textMultiplier)
        var y = panelSize.height / 2 - 96
        let items: [(String, String)] = [
            ("[ JOURNAL ]", "section_journal"),
            ("[ OBJECTIVES ]", "section_objectives"),
            ("[ DISCOVERIES ]", "section_discoveries"),
        ]
        for (label, action) in items {
            let btn = makeButton(label: label, width: btnW, size: 12 * textMultiplier)
            btn.position = CGPoint(x: 0, y: y)
            panel.addChild(btn)
            regions.buttons.append((buttonHitRect(center: center, width: btnW, height: btnH, localY: y), action))
            y -= btnH + btnGap
        }

        regions.close = closeRect(panelSize: panelSize, center: center, labelSize: 11 * textMultiplier)
        addCloseButton(to: panel, panelSize: panelSize, size: 11 * textMultiplier)

        return BuildResult(panel: panel, scrollState: nil, regions: regions, screen: .hub)
    }

    // MARK: - Scrollable section

    private static func buildSection(
        _ section: PDASection,
        shift: Int,
        currentShift: Int,
        panelSize: CGSize,
        center: CGPoint,
        textMultiplier: CGFloat,
        chapterID: String?,
        fieldObjective: String?,
        onRebuild: @escaping (Screen) -> Void,
        onClose: @escaping () -> Void
    ) -> BuildResult {
        let panel = SKNode()
        panel.position = center
        var regions = HitRegions()

        let header: String
        let bodyText: String
        let shiftChapter = PDAJournalManager.chapterID(forShift: shift)
        let activeFieldObjective = shift == currentShift ? fieldObjective : nil
        switch section {
        case .journal:
            header = "JOURNAL"
            bodyText = PDAJournalManager.journalBody(forShift: shift)
        case .objectives:
            header = "OBJECTIVES"
            bodyText = PDAJournalManager.objectivesBody(
                forShift: shift, chapterID: shiftChapter, fieldObjective: activeFieldObjective)
        case .discoveries:
            header = "DISCOVERIES"
            bodyText = PDAJournalManager.discoveriesBody(forShift: shift)
        }

        addChrome(to: panel, size: panelSize, header: header)
        addShiftSelector(to: panel, panelSize: panelSize, center: center,
                         section: section, viewingShift: shift,
                         textMultiplier: textMultiplier, regions: &regions)

        let footerH: CGFloat = 88
        let headerH: CGFloat = 72
        let shiftBarH: CGFloat = 34
        let bodyW = panelSize.width - 28
        let bodyH = panelSize.height - headerH - shiftBarH - footerH
        let bodyTop = panelSize.height / 2 - headerH - shiftBarH

        let bodyLbl = makeBodyLabel(text: bodyText, width: bodyW, size: 11.5 * textMultiplier)
        bodyLbl.horizontalAlignmentMode = .left
        bodyLbl.verticalAlignmentMode = .top

        let clip = SKCropNode()
        let mask = SKSpriteNode(color: .white, size: CGSize(width: bodyW, height: bodyH))
        mask.position = CGPoint(x: 0, y: bodyTop - bodyH / 2)
        clip.maskNode = mask

        let content = SKNode()
        bodyLbl.position = CGPoint(x: -bodyW / 2, y: bodyH / 2)
        content.addChild(bodyLbl)
        clip.addChild(content)
        panel.addChild(clip)

        let scrollState = ScrollableReadablePanel.ScrollState()
        scrollState.content = content
        scrollState.bodyLabel = bodyLbl
        scrollState.viewportHeight = bodyH
        scrollState.recalculateBounds()

        regions.scrollBody = CGRect(
            x: center.x - bodyW / 2,
            y: center.y + bodyTop - bodyH,
            width: bodyW,
            height: bodyH)

        let backRect = CGRect(x: center.x - panelSize.width / 2 + 8,
                              y: center.y - panelSize.height / 2 + 8,
                              width: 80, height: 32)
        regions.buttons.append((backRect, "back"))

        let backLbl = DLOFont.terminalLabel(text: "◂ BACK", size: 10 * textMultiplier)
        backLbl.fontColor = pdaTeal.withAlphaComponent(0.8)
        backLbl.horizontalAlignmentMode = .left
        backLbl.position = CGPoint(x: -panelSize.width / 2 + 16, y: -panelSize.height / 2 + 20)
        panel.addChild(backLbl)

        regions.close = closeRect(panelSize: panelSize, center: center, labelSize: 11 * textMultiplier)
        addCloseButton(to: panel, panelSize: panelSize, size: 11 * textMultiplier)

        return BuildResult(panel: panel, scrollState: scrollState, regions: regions,
                           screen: .section(section, shift: shift))
    }

    // MARK: - Touch routing

    static func handleTap(
        at scenePos: CGPoint,
        build: BuildResult,
        currentShift: Int,
        onRebuild: @escaping (Screen) -> Void,
        onClose: @escaping () -> Void
    ) -> Bool {
        if build.regions.close.contains(scenePos) {
            onClose()
            return true
        }

        if case .section(let section, let viewingShift) = build.screen,
           !build.regions.shiftBar.isEmpty,
           build.regions.shiftBar.contains(scenePos),
           let tappedShift = shiftAtTap(scenePos, shiftBar: build.regions.shiftBar,
                                        in: build.regions.buttons) {
            if tappedShift != viewingShift {
                onRebuild(.section(section, shift: tappedShift))
            }
            return true
        }

        for (rect, action) in build.regions.buttons {
            guard !action.hasPrefix("shift_") else { continue }
            guard rect.contains(scenePos) else { continue }
            switch action {
            case "open_pda":
                PDAJournalManager.markBootSeen()
                onRebuild(.hub)
            case "section_journal":
                onRebuild(.section(.journal, shift: currentShift))
            case "section_objectives":
                onRebuild(.section(.objectives, shift: currentShift))
            case "section_discoveries":
                onRebuild(.section(.discoveries, shift: currentShift))
            case "back":
                onRebuild(.hub)
            default:
                break
            }
            return true
        }
        return false
    }

    /// Resolve a shift tab from a tap — rect hit first, then equal-width columns across the bar.
    private static func shiftAtTap(
        _ scenePos: CGPoint,
        shiftBar: CGRect,
        in buttons: [(CGRect, String)]
    ) -> Int? {
        let ordered: [(CGFloat, Int)] = buttons.compactMap { rect, action in
            guard action.hasPrefix("shift_"),
                  let shift = Int(action.dropFirst("shift_".count)) else { return nil }
            return (rect.midX, shift)
        }.sorted { $0.0 < $1.0 }
        guard !ordered.isEmpty else { return nil }

        for (rect, action) in buttons where action.hasPrefix("shift_") {
            guard rect.contains(scenePos),
                  let shift = Int(action.dropFirst("shift_".count)) else { continue }
            return shift
        }

        guard shiftBar.contains(scenePos) else { return nil }
        let colW = shiftBar.width / CGFloat(ordered.count)
        let idx = min(ordered.count - 1, max(0, Int((scenePos.x - shiftBar.minX) / colW)))
        return ordered[idx].1
    }

    // MARK: - Chrome helpers

    private static func addShiftSelector(
        to panel: SKNode,
        panelSize: CGSize,
        center: CGPoint,
        section: PDASection,
        viewingShift: Int,
        textMultiplier: CGFloat,
        regions: inout HitRegions
    ) {
        let shifts = PDAJournalManager.visibleShifts()
        guard !shifts.isEmpty else { return }

        let y = panelSize.height / 2 - 72
        let pillH = max(26, 22 * textMultiplier)
        let gap: CGFloat = max(10, 6 * textMultiplier)
        let pillW = min(84, (panelSize.width - 28 - CGFloat(shifts.count - 1) * gap) / CGFloat(shifts.count))
        let totalW = CGFloat(shifts.count) * pillW + CGFloat(shifts.count - 1) * gap
        var x = -totalW / 2 + pillW / 2
        var shiftRects: [CGRect] = []

        for shift in shifts {
            let selected = shift == viewingShift
            let pill = SKShapeNode(rectOf: CGSize(width: pillW, height: pillH), cornerRadius: 3)
            pill.fillColor = selected
                ? pdaTeal.withAlphaComponent(0.22)
                : pdaTeal.withAlphaComponent(0.06)
            pill.strokeColor = selected ? pdaTeal : pdaBorder.withAlphaComponent(0.7)
            pill.lineWidth = selected ? 1.4 : 1.0
            pill.position = CGPoint(x: x, y: y)
            pill.zPosition = 4
            panel.addChild(pill)

            let lbl = centeredTerminalLabel(text: "SHIFT \(shift)", size: 8.5 * textMultiplier)
            lbl.fontColor = selected ? pdaTeal : pdaText.withAlphaComponent(0.55)
            lbl.position = CGPoint(x: x, y: y - 1)
            lbl.zPosition = 5
            panel.addChild(lbl)

            let hitRect = buttonHitRect(center: center, localX: x, width: pillW, height: pillH + 6, localY: y)
            shiftRects.append(hitRect)
            regions.buttons.append((hitRect, "shift_\(shift)"))
            x += pillW + gap
        }

        if let first = shiftRects.first {
            let last = shiftRects.last!
            regions.shiftBar = CGRect(
                x: first.minX,
                y: min(first.minY, last.minY),
                width: last.maxX - first.minX,
                height: max(first.maxY, last.maxY) - min(first.minY, last.minY))
        }
    }

    private static func addChrome(to panel: SKNode, size: CGSize, header: String) {
        let bg = SKSpriteNode(color: pdaBG, size: size)
        bg.zPosition = 0
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: size.width - 2, height: size.height - 2), cornerRadius: 6)
        border.strokeColor = pdaBorder
        border.lineWidth = 1.5
        border.fillColor = .clear
        border.zPosition = 1
        panel.addChild(border)

        let headerBar = SKSpriteNode(color: SKColor(red: 0.13, green: 0.15, blue: 0.17, alpha: 1),
                                     size: CGSize(width: size.width, height: 36))
        headerBar.position = CGPoint(x: 0, y: size.height / 2 - 18)
        headerBar.zPosition = 2
        panel.addChild(headerBar)

        let hdr = centeredTerminalLabel(text: header, size: 12)
        hdr.fontColor = pdaTeal
        hdr.position = CGPoint(x: 0, y: size.height / 2 - 22)
        hdr.zPosition = 3
        panel.addChild(hdr)

        let meta = centeredTerminalLabel(text: "MARA-UNIT-7  |  LOCAL ONLY", size: 7)
        meta.fontColor = pdaText.withAlphaComponent(0.45)
        meta.position = CGPoint(x: 0, y: size.height / 2 - 38)
        meta.zPosition = 3
        panel.addChild(meta)
    }

    private static func addCloseButton(to panel: SKNode, panelSize: CGSize, size: CGFloat) {
        let lbl = centeredTerminalLabel(text: "[ CLOSE ]", size: size)
        lbl.fontColor = pdaTeal
        lbl.position = CGPoint(x: 0, y: -panelSize.height / 2 + 26)
        lbl.zPosition = 5
        panel.addChild(lbl)
    }

    private static func closeRect(panelSize: CGSize, center: CGPoint, labelSize: CGFloat) -> CGRect {
        let labelW = estimatedLabelWidth(text: "[ CLOSE ]", fontSize: labelSize)
        let w = max(160, labelW + 48)
        let h = max(44, labelSize + 28)
        return CGRect(
            x: center.x - w / 2,
            y: center.y - panelSize.height / 2 + 2,
            width: w,
            height: h)
    }

    private static func buttonHitRect(
        center: CGPoint, localX: CGFloat = 0, width: CGFloat, height: CGFloat, localY: CGFloat
    ) -> CGRect {
        CGRect(
            x: center.x + localX - width / 2,
            y: center.y + localY - height / 2,
            width: width,
            height: height)
    }

    private static func centeredTerminalLabel(text: String, size: CGFloat) -> SKLabelNode {
        let lbl = DLOFont.terminalLabel(text: text, size: size)
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode = .center
        return lbl
    }

    private static func estimatedLabelWidth(text: String, fontSize: CGFloat) -> CGFloat {
        CGFloat(text.count) * fontSize * 0.62
    }

    private static func makeButton(label: String, width: CGFloat, size: CGFloat) -> SKNode {
        let node = SKNode()
        let btnH = max(32, 26 * (size / 12))
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: btnH), cornerRadius: 4)
        bg.fillColor = pdaTeal.withAlphaComponent(0.12)
        bg.strokeColor = pdaBorder
        bg.lineWidth = 1.2
        node.addChild(bg)
        let lbl = centeredTerminalLabel(text: label, size: size)
        lbl.fontColor = pdaTeal
        node.addChild(lbl)
        return node
    }

    private static func makeBodyLabel(text: String, width: CGFloat, size: CGFloat) -> SKLabelNode {
        let lbl = DLOFont.terminalLabel(text: text, size: size)
        lbl.fontColor = pdaText
        lbl.numberOfLines = 0
        lbl.preferredMaxLayoutWidth = width
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }
}
