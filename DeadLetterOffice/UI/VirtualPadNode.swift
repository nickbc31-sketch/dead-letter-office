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

    private var leftRect      = CGRect.zero
    private var rightRect     = CGRect.zero
    private var jumpRect      = CGRect.zero   // in rightCluster space (used internally)
    private var jumpRectPad   = CGRect.zero   // in VirtualPad space (used by hitName)
    private var interactRect  = CGRect.zero

    override init() {
        super.init()
        // isUserInteractionEnabled intentionally NOT set — scene dispatches touches
        // directly using notifyTouchBegan/Ended/Cancelled (proven pattern).
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

    // Called by PlatformScene after VirtualPad is added to the camera.
    // Positions the right cluster and locks down jumpRectPad so hitName
    // never needs a dynamic childNode lookup at touch time.
    func layoutRightCluster(x: CGFloat) {
        childNode(withName: "rightCluster")?.position = CGPoint(x: x, y: 0)
        jumpRectPad = CGRect(x: x + jumpRect.minX, y: jumpRect.minY,
                             width: jumpRect.width, height: jumpRect.height)
    }

    // MARK: - Touch Handling (called by PlatformScene, not ISE)

    func notifyTouchBegan(_ touch: UITouch, at pos: CGPoint) {
        activeTouches[touch] = hitName(for: pos)
        updateInput()
    }

    func notifyTouchEnded(_ touch: UITouch) {
        activeTouches.removeValue(forKey: touch)
        updateInput()
    }

    func notifyTouchCancelled(_ touch: UITouch) {
        activeTouches.removeValue(forKey: touch)
        updateInput()
    }

    func resetInput() {
        activeTouches.removeAll()
        currentInput = Input()
    }

    private func hitName(for pos: CGPoint) -> String {
        if leftRect.contains(pos)    { return "left" }
        if rightRect.contains(pos)   { return "right" }
        // Use live rightCluster position — precomputed jumpRectPad can drift from visual button.
        let clusterPos = childNode(withName: "rightCluster")?.position ?? .zero
        let local = CGPoint(x: pos.x - clusterPos.x, y: pos.y - clusterPos.y)
        if jumpRect.insetBy(dx: -12, dy: -12).contains(local) { return "jump" }
        return "none"
    }

    private func updateInput() {
        let names = Set(activeTouches.values)
        let next = Input(
            left:     names.contains("left"),
            right:    names.contains("right"),
            jump:     names.contains("jump"),
            crouch:   names.contains("crouch"),
            interact: names.contains("interact")
        )
        currentInput = next
    }
}
