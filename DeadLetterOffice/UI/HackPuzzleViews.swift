import SpriteKit

// MARK: - Shared chrome

enum HackPuzzleChrome {
    static let panelFill = SKColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 1)
    static let border = SKColor(red: 0.38, green: 0.48, blue: 0.42, alpha: 1)
    static let header = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 1)
    static let body = SKColor(red: 0.78, green: 0.84, blue: 0.74, alpha: 0.9)
    static let pathGlow = SKColor(red: 0.72, green: 0.88, blue: 1.0, alpha: 1)
    static let blocked = SKColor(red: 0.45, green: 0.12, blue: 0.12, alpha: 0.9)

    static func makePanel(size: CGSize, mult: CGFloat) -> SKNode {
        let panel = SKNode()
        let bg = SKSpriteNode(color: panelFill, size: size)
        bg.alpha = 0.97
        panel.addChild(bg)
        let border = SKShapeNode(rectOf: CGSize(width: size.width - 2, height: size.height - 2), cornerRadius: 10)
        border.strokeColor = HackPuzzleChrome.border
        border.lineWidth = 1.5
        border.fillColor = .clear
        panel.addChild(border)
        return panel
    }

    static func addHeader(to panel: SKNode, panelH: CGFloat, mult: CGFloat,
                          system: String, title: String, subtitle: String?) {
        let hdr = DLOFont.terminalLabel(text: system, size: 11 * mult)
        hdr.fontColor = header
        hdr.horizontalAlignmentMode = .center
        hdr.position = CGPoint(x: 0, y: panelH / 2 - 26)
        panel.addChild(hdr)

        let instr = DLOFont.terminalLabel(text: title, size: 9 * mult)
        instr.fontColor = body
        instr.horizontalAlignmentMode = .center
        instr.position = CGPoint(x: 0, y: panelH / 2 - 46)
        panel.addChild(instr)

        if let subtitle, !subtitle.isEmpty {
            let sub = DLOFont.terminalLabel(text: subtitle, size: 7.5 * mult)
            sub.fontColor = body.withAlphaComponent(0.55)
            sub.horizontalAlignmentMode = .center
            sub.preferredMaxLayoutWidth = 420
            sub.numberOfLines = 2
            sub.position = CGPoint(x: 0, y: panelH / 2 - 64)
            panel.addChild(sub)
        }
    }

    static func addCancel(to panel: SKNode, panelH: CGFloat, action: @escaping () -> Void) {
        let cancel = PanelButtonNode(label: "[ CANCEL ]", action: action)
        cancel.position = CGPoint(x: 0, y: -panelH / 2 + 24)
        panel.addChild(cancel)
    }
}

// MARK: - Signal Routing (grid)

enum SignalRoutingPuzzleView {

    static func build(config: SignalRoutingConfig, panelSize: CGSize, mult: CGFloat,
                      onSuccess: @escaping () -> Void, onCancel: @escaping () -> Void) -> SKNode {
        let panel = HackPuzzleChrome.makePanel(size: panelSize, mult: mult)
        HackPuzzleChrome.addHeader(to: panel, panelH: panelSize.height, mult: mult,
                                   system: "MARA PDA — SIGNAL ROUTING",
                                   title: "ROUTE START → EXIT",
                                   subtitle: "Tap adjacent nodes. Blocked nodes reject. Unstable nodes reset route.")

        var path: [Int] = []
        let total = config.rows * config.columns
        let blocked = Set(config.blockedIndices)
        let unstable = Set(config.unstableIndices)

        let status = DLOFont.terminalLabel(text: "STATUS: TAP START", size: 8 * mult)
        status.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.7)
        status.horizontalAlignmentMode = .center
        status.position = CGPoint(x: 0, y: -panelSize.height / 2 + 78)
        panel.addChild(status)

        let gridW = min(panelSize.width - 48, 340)
        let cell = min(56, gridW / CGFloat(config.columns))
        let gridH = cell * CGFloat(config.rows)
        let origin = CGPoint(x: -gridW / 2 + cell / 2, y: -8 - gridH / 2 + cell / 2)
        var cells: [HackGridCell] = []

        func refreshCells() {
            for c in cells {
                let onPath = path.contains(c.index)
                c.setState(blocked: blocked.contains(c.index),
                           unstable: unstable.contains(c.index),
                           isStart: c.index == config.startIndex,
                           isExit: c.index == config.exitIndex,
                           onPath: onPath)
            }
        }

        func flashInvalid() {
            status.text = "INVALID NODE"
            status.fontColor = DLOColor.danger
            panel.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.35),
                SKAction.run { status.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.7) }
            ]))
        }

        func resetPath(unstableHit: Bool) {
            path.removeAll()
            refreshCells()
            status.text = unstableHit ? "UNSTABLE NODE — ROUTE CLEARED" : "STATUS: TAP START"
            status.fontColor = unstableHit ? DLOColor.danger : HackPuzzleChrome.body.withAlphaComponent(0.7)
        }

        func adjacent(_ a: Int, _ b: Int) -> Bool {
            let ar = a / config.columns, ac = a % config.columns
            let br = b / config.columns, bc = b % config.columns
            return (ar == br && abs(ac - bc) == 1) || (ac == bc && abs(ar - br) == 1)
        }

        func handleTap(_ index: Int) {
            guard !blocked.contains(index) else { flashInvalid(); return }
            if path.isEmpty {
                guard index == config.startIndex else { flashInvalid(); return }
                path = [index]
            } else if let last = path.last {
                if unstable.contains(index) && !adjacent(last, index) {
                    resetPath(unstableHit: true)
                    return
                }
                guard adjacent(last, index), !path.contains(index) else {
                    if unstable.contains(index) { resetPath(unstableHit: true) } else { flashInvalid() }
                    return
                }
                path.append(index)
            }
            refreshCells()
            if path.last == config.exitIndex {
                status.text = "ROUTE VERIFIED — ACCESS GRANTED"
                status.fontColor = HackPuzzleChrome.header
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onSuccess() }
            } else {
                status.text = "TRACE: \(path.count) nodes"
            }
        }

        let gridNode = SKNode()
        gridNode.position = CGPoint(x: 0, y: 0)
        panel.addChild(gridNode)

        for i in 0..<total {
            let row = i / config.columns
            let col = i % config.columns
            let cellNode = HackGridCell(index: i, cellSize: CGSize(width: cell - 6, height: cell - 6)) {
                handleTap(i)
            }
            cellNode.position = CGPoint(x: origin.x + CGFloat(col) * cell,
                                        y: origin.y + CGFloat(config.rows - 1 - row) * cell)
            gridNode.addChild(cellNode)
            cells.append(cellNode)
        }
        refreshCells()

        let clear = PanelButtonNode(label: "[ CLEAR ]") { resetPath(unstableHit: false) }
        clear.position = CGPoint(x: -90, y: -panelSize.height / 2 + 24)
        panel.addChild(clear)
        HackPuzzleChrome.addCancel(to: panel, panelH: panelSize.height, action: onCancel)
        return panel
    }
}

private final class HackGridCell: SKNode {
    let index: Int
    private let bg: SKShapeNode
    private let label: SKLabelNode
    private let action: () -> Void

    init(index: Int, cellSize: CGSize, action: @escaping () -> Void) {
        self.index = index
        self.action = action
        bg = SKShapeNode(rectOf: cellSize, cornerRadius: 6)
        label = DLOFont.terminalLabel(text: "", size: 6)
        super.init()
        isUserInteractionEnabled = true
        bg.lineWidth = 1.5
        addChild(bg)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        addChild(label)
        userData = NSMutableDictionary()
    }

    required init?(coder: NSCoder) { fatalError() }

    func setState(blocked: Bool, unstable: Bool, isStart: Bool, isExit: Bool, onPath: Bool) {
        if blocked {
            bg.fillColor = HackPuzzleChrome.blocked
            bg.strokeColor = DLOColor.danger.withAlphaComponent(0.8)
            label.text = "X"
            label.fontColor = DLOColor.danger
        } else if isStart {
            bg.fillColor = SKColor(red: 0.08, green: 0.22, blue: 0.24, alpha: 1)
            bg.strokeColor = DLOColor.teal
            label.text = "START"
            label.fontColor = DLOColor.teal
        } else if isExit {
            bg.fillColor = SKColor(red: 0.18, green: 0.14, blue: 0.06, alpha: 1)
            bg.strokeColor = DLOColor.terminalAmber
            label.text = "EXIT"
            label.fontColor = DLOColor.terminalAmber
        } else {
            bg.fillColor = onPath
                ? SKColor(red: 0.18, green: 0.28, blue: 0.34, alpha: 1)
                : SKColor(red: 0.14, green: 0.18, blue: 0.20, alpha: 1)
            bg.strokeColor = onPath ? HackPuzzleChrome.pathGlow : HackPuzzleChrome.border
            label.text = unstable ? "~" : "•"
            label.fontColor = unstable
                ? DLOColor.terminalAmber.withAlphaComponent(0.8)
                : HackPuzzleChrome.body.withAlphaComponent(0.5)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        action()
        run(SKAction.sequence([
            SKAction.scale(to: 0.92, duration: 0.04),
            SKAction.scale(to: 1.0, duration: 0.04),
        ]))
    }
}

// MARK: - Frequency Match

enum FrequencyMatchPuzzleView {

    static func build(config: FrequencyMatchConfig, panelSize: CGSize, mult: CGFloat,
                      onSuccess: @escaping () -> Void, onCancel: @escaping () -> Void,
                      onFail: @escaping (String) -> Void) -> SKNode {
        let panel = HackPuzzleChrome.makePanel(size: panelSize, mult: mult)
        HackPuzzleChrome.addHeader(to: panel, panelH: panelSize.height, mult: mult,
                                   system: "MARA PDA — FREQUENCY MATCH",
                                   title: "ALIGN SURVEILLANCE BANDS",
                                   subtitle: "Drag markers into highlighted target zones")

        let bandCount = min(config.bandCount, config.targetValues.count, config.tolerances.count)
        var sliders: [HackFrequencySlider] = []
        let trackW = panelSize.width - 80
        let startY: CGFloat = 30
        let spacing: CGFloat = bandCount > 2 ? 44 : 56

        let status = DLOFont.terminalLabel(text: "STATUS: ADJUST BANDS", size: 8 * mult)
        status.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.7)
        status.horizontalAlignmentMode = .center
        status.position = CGPoint(x: 0, y: -panelSize.height / 2 + 78)
        panel.addChild(status)

        func checkAlignment() {
            let aligned = (0..<bandCount).allSatisfy { i in
                abs(sliders[i].value - config.targetValues[i]) <= config.tolerances[i]
            }
            if aligned {
                status.text = "SIGNAL LOCKED — LOOP ACTIVE"
                status.fontColor = HackPuzzleChrome.header
                if config.autoSuccess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onSuccess() }
                }
            } else {
                status.text = "STATUS: \(alignedCount()) / \(bandCount) ALIGNED"
                status.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.7)
            }
        }

        func alignedCount() -> Int {
            (0..<bandCount).filter { abs(sliders[$0].value - config.targetValues[$0]) <= config.tolerances[$0] }.count
        }

        for i in 0..<bandCount {
            let slider = HackFrequencySlider(
                bandIndex: i,
                trackWidth: trackW,
                target: config.targetValues[i],
                tolerance: config.tolerances[i],
                jitter: config.jitterAmount ?? 0,
                initial: CGFloat.random(in: 0.12...0.88),
                onChange: { checkAlignment() })
            slider.position = CGPoint(x: 0, y: startY - CGFloat(i) * spacing)
            panel.addChild(slider)
            sliders.append(slider)
        }

        if !config.autoSuccess {
            let submit = PanelButtonNode(label: "[ LOCK SIGNAL ]") {
                if alignedCount() == bandCount { onSuccess() }
                else { onFail("Frequency mismatch — adjust all bands") }
            }
            submit.position = CGPoint(x: 90, y: -panelSize.height / 2 + 24)
            panel.addChild(submit)
        }

        HackPuzzleChrome.addCancel(to: panel, panelH: panelSize.height, action: onCancel)
        return panel
    }
}

private final class HackFrequencySlider: SKNode {
    private(set) var value: CGFloat = 0.5
    private let trackW: CGFloat
    private let target: CGFloat
    private let tolerance: CGFloat
    private let marker: SKShapeNode
    private let zone: SKShapeNode
    private let onChange: () -> Void
    private var dragging = false

    init(bandIndex: Int, trackWidth: CGFloat, target: CGFloat, tolerance: CGFloat,
         jitter: CGFloat, initial: CGFloat, onChange: @escaping () -> Void) {
        trackW = trackWidth
        self.target = target
        self.tolerance = tolerance
        self.onChange = onChange
        value = initial
        marker = SKShapeNode(circleOfRadius: 11)
        zone = SKShapeNode(rectOf: CGSize(width: trackWidth * tolerance * 2, height: 22), cornerRadius: 4)
        super.init()
        isUserInteractionEnabled = true

        let lbl = DLOFont.terminalLabel(text: "BAND \(bandIndex + 1)", size: 6)
        lbl.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.65)
        lbl.horizontalAlignmentMode = .left
        lbl.position = CGPoint(x: -trackW / 2, y: 18)
        addChild(lbl)

        let track = SKShapeNode(rectOf: CGSize(width: trackWidth, height: 4), cornerRadius: 2)
        track.fillColor = SKColor(white: 0.12, alpha: 1)
        track.strokeColor = HackPuzzleChrome.border.withAlphaComponent(0.5)
        addChild(track)

        zone.fillColor = DLOColor.terminalAmber.withAlphaComponent(0.22)
        zone.strokeColor = DLOColor.terminalAmber.withAlphaComponent(0.55)
        zone.position = CGPoint(x: (target - 0.5) * trackW, y: 0)
        addChild(zone)

        marker.fillColor = DLOColor.teal
        marker.strokeColor = HackPuzzleChrome.pathGlow
        marker.lineWidth = 1.5
        marker.position = CGPoint(x: (value - 0.5) * trackW, y: 0)
        addChild(marker)

        if jitter > 0 {
            run(SKAction.repeatForever(SKAction.sequence([
                SKAction.run { [weak self] in self?.applyJitter(jitter) },
                SKAction.wait(forDuration: 0.12)
            ])))
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    private func applyJitter(_ amount: CGFloat) {
        guard !dragging else { return }
        value = max(0.05, min(0.95, value + CGFloat.random(in: -amount...amount)))
        marker.position.x = (value - 0.5) * trackW
        onChange()
    }

    private func setValueFromTouch(_ touch: UITouch) {
        let loc = touch.location(in: self)
        let frac = max(0, min(1, (loc.x + trackW / 2) / trackW))
        value = frac
        marker.position.x = (frac - 0.5) * trackW
        let aligned = abs(value - target) <= tolerance
        marker.fillColor = aligned ? DLOColor.terminalGreen : DLOColor.teal
        onChange()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        dragging = true
        setValueFromTouch(t)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        setValueFromTouch(t)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragging = false
    }
}

// MARK: - Credential Injection

enum CredentialInjectionPuzzleView {

    static func build(config: CredentialInjectionConfig, panelSize: CGSize, mult: CGFloat,
                      unlockedTags: Set<String>,
                      onSuccess: @escaping () -> Void, onCancel: @escaping () -> Void,
                      onFail: @escaping (String) -> Void) -> SKNode {
        let panel = HackPuzzleChrome.makePanel(size: panelSize, mult: mult)
        HackPuzzleChrome.addHeader(to: panel, panelH: panelSize.height, mult: mult,
                                   system: "MARA PDA — CREDENTIAL INJECTION",
                                   title: "ASSEMBLE VERIFIED FRAGMENTS",
                                   subtitle: nil)

        let top = panelSize.height / 2
        let bottom = -panelSize.height / 2
        let footerH: CGFloat = 44
        let footerY = bottom + footerH / 2
        let bodyTop = top - 54
        let bodyBottom = bottom + footerH + 4
        let bodyH = bodyTop - bodyBottom
        let margin: CGFloat = 14

        // Landscape: request/status on the left, fragment chips on the right.
        let splitX: CGFloat = -panelSize.width * 0.06
        let leftW = panelSize.width * 0.38
        let rightW = panelSize.width * 0.48
        let leftCenterX = splitX - rightW / 2 - margin + leftW / 2
        let rightCenterX = splitX + leftW / 2 + margin + rightW / 2

        var leftY = bodyTop - 8

        let hasTags = (config.requiredPDATags ?? []).allSatisfy { unlockedTags.contains($0) }
        if !hasTags && config.allowPartialHints {
            let warn = DLOFont.terminalLabel(
                text: "⚠ Insufficient verified data — cross-check PDA journal",
                size: 7 * mult)
            warn.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.85)
            warn.horizontalAlignmentMode = .left
            warn.preferredMaxLayoutWidth = leftW - 8
            warn.numberOfLines = 3
            warn.position = CGPoint(x: leftCenterX - leftW / 2 + 4, y: leftY)
            panel.addChild(warn)
            leftY -= 28
        }

        let reqLines = config.systemRequest.split(separator: "\n").map(String.init)
        let lineFont = 8 * mult
        let lineSpacing = lineFont + 3
        let reqPad: CGFloat = 10
        let reqBoxH = min(bodyH - 50, CGFloat(reqLines.count) * lineSpacing + reqPad * 2)
        let reqBoxW = leftW

        leftY -= reqBoxH / 2
        let reqBox = SKShapeNode(rectOf: CGSize(width: reqBoxW, height: reqBoxH), cornerRadius: 6)
        reqBox.fillColor = SKColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1)
        reqBox.strokeColor = HackPuzzleChrome.border
        reqBox.position = CGPoint(x: leftCenterX, y: leftY)
        panel.addChild(reqBox)

        let reqTextLeft = leftCenterX - reqBoxW / 2 + reqPad
        let reqTextTop = leftY + reqBoxH / 2 - reqPad - lineFont / 2
        for (i, line) in reqLines.enumerated() {
            let lbl = DLOFont.terminalLabel(text: line, size: lineFont)
            lbl.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.9)
            lbl.horizontalAlignmentMode = .left
            lbl.position = CGPoint(x: reqTextLeft, y: reqTextTop - CGFloat(i) * lineSpacing)
            panel.addChild(lbl)
        }
        leftY -= reqBoxH / 2 + 12

        var selected: [String] = []
        let pool = Array(Set(config.availableFragments + config.distractorFragments)).sorted()
        var chips: [HackFragmentChip] = []

        let selectedLabel = DLOFont.terminalLabel(text: "INJECTION: (none)", size: 8 * mult)
        selectedLabel.fontColor = HackPuzzleChrome.header
        selectedLabel.horizontalAlignmentMode = .left
        selectedLabel.preferredMaxLayoutWidth = leftW
        selectedLabel.numberOfLines = 3
        selectedLabel.position = CGPoint(x: leftCenterX - leftW / 2 + 4, y: leftY)
        panel.addChild(selectedLabel)

        func refreshSelection() {
            selectedLabel.text = selected.isEmpty
                ? "INJECTION: (none)"
                : "INJECTION: " + selected.joined(separator: " + ")
            for chip in chips {
                chip.setSelected(selected.contains(chip.fragment))
            }
        }

        let cols = 2
        let colGap: CGFloat = 8
        let rowGap: CGFloat = 7
        let chipW = (rightW - colGap) / CGFloat(cols)
        let chipH: CGFloat = max(30, 28 * mult)
        let rows = (pool.count + cols - 1) / cols
        let gridH = CGFloat(rows) * chipH + CGFloat(max(0, rows - 1)) * rowGap
        let gridTopY = bodyTop - 6
        let gridStartY = gridTopY - chipH / 2 - max(0, (bodyH - gridH) / 2)
        let gridLeft = rightCenterX - (chipW + colGap / 2)

        for (i, frag) in pool.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = gridLeft + CGFloat(col) * (chipW + colGap)
            let y = gridStartY - CGFloat(row) * (chipH + rowGap)
            let verified = config.availableFragments.contains(frag)
            let chip = HackFragmentChip(
                fragment: frag, verified: verified, width: chipW, height: chipH, fontSize: 8 * mult
            ) {
                if let idx = selected.firstIndex(of: frag) {
                    selected.remove(at: idx)
                } else {
                    selected.append(frag)
                }
                refreshSelection()
            }
            chip.position = CGPoint(x: x, y: y)
            panel.addChild(chip)
            chips.append(chip)
        }

        let divider = SKSpriteNode(color: HackPuzzleChrome.border.withAlphaComponent(0.35),
                                   size: CGSize(width: 1, height: bodyH - 8))
        divider.position = CGPoint(x: splitX, y: (bodyTop + bodyBottom) / 2)
        panel.addChild(divider)

        let cancel = PanelButtonNode(label: "[ CANCEL ]", action: onCancel)
        cancel.position = CGPoint(x: -82, y: footerY)
        panel.addChild(cancel)

        let submit = PanelButtonNode(label: "[ INJECT ]") {
            let required = Set(config.requiredFragments)
            let picked = Set(selected)
            if picked == required && selected.count == config.requiredFragments.count {
                onSuccess()
            } else {
                onFail("Credential rejected — fragment mismatch")
            }
        }
        submit.position = CGPoint(x: 82, y: footerY)
        panel.addChild(submit)

        return panel
    }
}

private final class HackFragmentChip: SKNode {
    let fragment: String
    private let bg: SKShapeNode
    private let action: () -> Void
    private let verifiedFill: SKColor

    init(fragment: String, verified: Bool, width: CGFloat, height: CGFloat, fontSize: CGFloat,
         action: @escaping () -> Void) {
        self.fragment = fragment
        self.action = action
        verifiedFill = verified
            ? SKColor(red: 0.12, green: 0.18, blue: 0.16, alpha: 1)
            : SKColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1)
        bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 6)
        super.init()
        isUserInteractionEnabled = true
        bg.fillColor = verifiedFill
        bg.strokeColor = verified ? HackPuzzleChrome.border : SKColor(white: 0.25, alpha: 0.6)
        addChild(bg)
        let lbl = DLOFont.terminalLabel(text: fragment, size: fontSize)
        lbl.fontColor = HackPuzzleChrome.body
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode = .center
        addChild(lbl)
    }

    required init?(coder: NSCoder) { fatalError() }

    func setSelected(_ on: Bool) {
        bg.fillColor = on
            ? SKColor(red: 0.16, green: 0.30, blue: 0.26, alpha: 1)
            : verifiedFill
        bg.strokeColor = on ? DLOColor.teal : HackPuzzleChrome.border
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { action() }
}

// MARK: - Pattern Decode

enum PatternDecodePuzzleView {

    static func build(config: PatternDecodeConfig, panelSize: CGSize, mult: CGFloat,
                      onSuccess: @escaping () -> Void, onCancel: @escaping () -> Void) -> SKNode {
        let panel = HackPuzzleChrome.makePanel(size: panelSize, mult: mult)
        HackPuzzleChrome.addHeader(to: panel, panelH: panelSize.height, mult: mult,
                                   system: "MARA PDA — PATTERN DECODE",
                                   title: "REPRODUCE SYMBOL SEQUENCE",
                                   subtitle: "Watch once. Tap symbols in order.")

        var replaysLeft = config.replayLimit
        var playerInput: [Int] = []
        var showing = false

        let preview = DLOFont.terminalLabel(text: "—", size: 28 * mult)
        preview.fontColor = HackPuzzleChrome.pathGlow
        preview.horizontalAlignmentMode = .center
        preview.position = CGPoint(x: 0, y: 40)
        panel.addChild(preview)

        let status = DLOFont.terminalLabel(text: "STATUS: READY", size: 8 * mult)
        status.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.7)
        status.horizontalAlignmentMode = .center
        status.position = CGPoint(x: 0, y: -panelSize.height / 2 + 78)
        panel.addChild(status)

        let inputStrip = DLOFont.terminalLabel(text: "INPUT: ", size: 8 * mult)
        inputStrip.fontColor = HackPuzzleChrome.header
        inputStrip.horizontalAlignmentMode = .center
        inputStrip.position = CGPoint(x: 0, y: -10)
        panel.addChild(inputStrip)

        func showSequence(completion: @escaping () -> Void) {
            showing = true
            status.text = "WATCH SEQUENCE..."
            var steps: [SKAction] = []
            for (i, sym) in config.sequence.enumerated() {
                steps.append(SKAction.run {
                    preview.text = config.symbols[sym]
                })
                steps.append(SKAction.wait(forDuration: config.showDurationPerSymbol))
                if i == config.sequence.count - 1 {
                    steps.append(SKAction.run { preview.text = "?" })
                }
            }
            steps.append(SKAction.run {
                showing = false
                status.text = "STATUS: ENTER SEQUENCE"
                completion()
            })
            panel.run(SKAction.sequence(steps))
        }

        func resetInput() {
            playerInput.removeAll()
            inputStrip.text = "INPUT: "
        }

        func handleSymbol(_ index: Int) {
            guard !showing else { return }
            playerInput.append(index)
            let symbols = playerInput.map { config.symbols[$0] }.joined()
            inputStrip.text = "INPUT: \(symbols)"
            let expected = Array(config.sequence.prefix(playerInput.count))
            if playerInput != expected {
                status.text = "MISMATCH — RETRY"
                status.fontColor = DLOColor.danger
                resetInput()
                panel.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.4),
                    SKAction.run { status.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.7) }
                ]))
                return
            }
            if playerInput.count == config.sequence.count {
                status.text = "PATTERN VERIFIED"
                status.fontColor = HackPuzzleChrome.header
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onSuccess() }
            }
        }

        let buttonRow = SKNode()
        buttonRow.position = CGPoint(x: 0, y: -55)
        panel.addChild(buttonRow)
        let count = config.symbols.count
        let spacing: CGFloat = 52
        let startX = -CGFloat(count - 1) * spacing / 2
        for i in 0..<count {
            let btn = HackSymbolButton(symbol: config.symbols[i], label: symbolName(i)) {
                handleSymbol(i)
            }
            btn.position = CGPoint(x: startX + CGFloat(i) * spacing, y: 0)
            buttonRow.addChild(btn)
        }

        if replaysLeft > 0 || replaysLeft >= 99 {
            let replay = PanelButtonNode(label: "[ REPLAY ]") {
                guard !showing else { return }
                if replaysLeft < 99 {
                    guard replaysLeft > 0 else {
                        status.text = "NO REPLAYS LEFT"
                        return
                    }
                    replaysLeft -= 1
                }
                resetInput()
                showSequence {}
            }
            replay.position = CGPoint(x: -90, y: -panelSize.height / 2 + 24)
            panel.addChild(replay)
        }

        HackPuzzleChrome.addCancel(to: panel, panelH: panelSize.height, action: onCancel)
        showSequence {}
        return panel
    }

    private static func symbolName(_ index: Int) -> String {
        ["CIRCLE", "TRI", "SQUARE", "LINE", "DIAMOND", "EYE"][min(index, 5)]
    }
}

private final class HackSymbolButton: SKNode {
    init(symbol: String, label: String, action: @escaping () -> Void) {
        super.init()
        isUserInteractionEnabled = true
        let bg = SKShapeNode(rectOf: CGSize(width: 44, height: 44), cornerRadius: 6)
        bg.fillColor = SKColor(red: 0.14, green: 0.18, blue: 0.20, alpha: 1)
        bg.strokeColor = HackPuzzleChrome.border
        addChild(bg)
        let sym = DLOFont.terminalLabel(text: symbol, size: 18)
        sym.fontColor = HackPuzzleChrome.pathGlow
        sym.verticalAlignmentMode = .center
        addChild(sym)
        let tag = DLOFont.terminalLabel(text: label, size: 4.5)
        tag.fontColor = HackPuzzleChrome.body.withAlphaComponent(0.45)
        tag.position = CGPoint(x: 0, y: -28)
        addChild(tag)
        userData = NSMutableDictionary()
        userData?["action"] = action
    }

    required init?(coder: NSCoder) { fatalError() }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        (userData?["action"] as? () -> Void)?()
    }
}
