import SpriteKit

final class VirtualPadNode: SKNode {

    struct Input {
        var left: Bool = false
        var right: Bool = false
        var jump: Bool = false
        var crouch: Bool = false
        var interact: Bool = false
    }

    private(set) var currentInput = Input()

    // Touch tracking: touch uid → button name
    private var activeTouches: [UITouch: String] = [:]

    // Button rects in this node's coordinate space
    private let btnSize = CGSize(width: 60, height: 60)
    private let jumpBtnSize = CGSize(width: 70, height: 70)

    private var leftRect  = CGRect.zero
    private var rightRect = CGRect.zero
    private var jumpRect  = CGRect.zero
    private var interactRect = CGRect.zero

    override init() {
        super.init()
        isUserInteractionEnabled = true
        buildPad()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildPad() {
        // Left cluster (d-pad)
        let leftCluster = SKNode()
        leftCluster.name = "leftCluster"
        addChild(leftCluster)

        let leftBtn = makeButton(color: DLOColor.uiBorder.withAlphaComponent(0.35), size: btnSize, label: "◀")
        leftBtn.name = "left"
        leftBtn.position = CGPoint(x: 30, y: 30)
        leftCluster.addChild(leftBtn)
        leftRect = CGRect(x: 0, y: 0, width: btnSize.width, height: btnSize.height)

        let rightBtn = makeButton(color: DLOColor.uiBorder.withAlphaComponent(0.35), size: btnSize, label: "▶")
        rightBtn.name = "right"
        rightBtn.position = CGPoint(x: 96, y: 30)
        leftCluster.addChild(rightBtn)
        rightRect = CGRect(x: 66, y: 0, width: btnSize.width, height: btnSize.height)

        // Right cluster (action buttons)
        let rightCluster = SKNode()
        rightCluster.name = "rightCluster"
        addChild(rightCluster)

        let jumpBtn = makeButton(color: DLOColor.terminalAmber.withAlphaComponent(0.35),
                                 size: jumpBtnSize, label: "↑")
        jumpBtn.name = "jump"
        jumpBtn.position = CGPoint(x: 80, y: 35)
        rightCluster.addChild(jumpBtn)
        jumpRect = CGRect(x: 45, y: 0, width: jumpBtnSize.width, height: jumpBtnSize.height)
    }

    private func makeButton(color: SKColor, size: CGSize, label: String) -> SKNode {
        let node = SKNode()
        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = color
        bg.strokeColor = DLOColor.uiBorder.withAlphaComponent(0.6)
        bg.lineWidth = 1.5
        node.addChild(bg)
        let lbl = SKLabelNode(text: label)
        lbl.fontName = "Menlo-Bold"
        lbl.fontSize = 18
        lbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.8)
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        node.addChild(lbl)
        return node
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let pos = touch.location(in: self)
            let name = hitName(for: pos)
            activeTouches[touch] = name
        }
        updateInput()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { activeTouches.removeValue(forKey: touch) }
        updateInput()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { activeTouches.removeValue(forKey: touch) }
        updateInput()
    }

    private func hitName(for pos: CGPoint) -> String {
        if leftRect.contains(pos)  { return "left" }
        if rightRect.contains(pos) { return "right" }
        // Check right cluster positions
        let rightClusterPos = childNode(withName: "rightCluster")?.position ?? .zero
        let localR = CGPoint(x: pos.x - rightClusterPos.x, y: pos.y - rightClusterPos.y)
        if jumpRect.contains(localR)     { return "jump" }
        if interactRect.contains(localR) { return "interact" }
        return "none"
    }

    private func updateInput() {
        let names = Set(activeTouches.values)
        currentInput = Input(
            left:     names.contains("left"),
            right:    names.contains("right"),
            jump:     names.contains("jump"),
            crouch:   names.contains("crouch"),
            interact: names.contains("interact")
        )
    }
}
