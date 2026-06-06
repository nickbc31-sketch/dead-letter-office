import SpriteKit

final class VirtualPadNode: SKNode {

    struct Input {
        var left: Bool = false
        var right: Bool = false
        var hack: Bool = false
        var crouch: Bool = false
        var hide: Bool = false
        var interact: Bool = false
        var emp: Bool = false
        var movementVector: CGVector = .zero
    }

    private(set) var currentInput = Input()
    private(set) var inputLocked = false

    private var activeTouches: [UITouch: String] = [:]
    private var thumbstickTouch: UITouch?

    private let actionBtnSize = CGSize(width: 56, height: 56)
    private let hackBtnSize = CGSize(width: 70, height: 70)

    private var leftZoneRect = CGRect.zero
    private var hackRect = CGRect.zero
    private var interactRect = CGRect.zero
    private var empRect = CGRect.zero

    private let thumbstick = ThumbstickNode()

    private weak var interactBtnBG: SKShapeNode?
    private weak var hackBtnBG: SKShapeNode?
    private weak var hackBtnLbl: SKLabelNode?
    private weak var empBtnBG: SKShapeNode?
    private var empCooldownOverlay: SKShapeNode?

    override init() {
        super.init()
        buildPad()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildPad() {
        addChild(thumbstick)

        let rightCluster = SKNode()
        rightCluster.name = "rightCluster"
        addChild(rightCluster)

        let interactPair = makeButton(
            color: DLOColor.teal.withAlphaComponent(0.22),
            size: actionBtnSize,
            label: "E")
        let interactBtn = interactPair.node
        interactBtnBG = interactPair.bg
        interactBtn.name = "interact"
        interactBtn.position = CGPoint(x: 28, y: 88)
        rightCluster.addChild(interactBtn)
        interactRect = CGRect(x: 0, y: 60, width: actionBtnSize.width, height: actionBtnSize.height)

        let empPair = makeButton(
            color: DLOColor.teal.withAlphaComponent(0.35),
            size: actionBtnSize,
            label: "EMP")
        let empBtn = empPair.node
        empBtnBG = empPair.bg
        empBtn.name = "emp"
        empBtn.position = CGPoint(x: 28, y: 28)
        rightCluster.addChild(empBtn)
        empRect = CGRect(x: 0, y: 0, width: actionBtnSize.width, height: actionBtnSize.height)

        let overlay = SKShapeNode(rectOf: actionBtnSize, cornerRadius: 8)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.6)
        overlay.strokeColor = DLOColor.teal.withAlphaComponent(0.5)
        overlay.lineWidth = 1
        overlay.zPosition = 3
        overlay.isHidden = true
        empBtn.addChild(overlay)
        empCooldownOverlay = overlay

        let hackPair = makeButton(
            color: SKColor(red: 0.22, green: 0.28, blue: 0.32, alpha: 0.45),
            size: hackBtnSize,
            label: "PDA")
        let hackBtn = hackPair.node
        hackBtnBG = hackPair.bg
        hackBtnLbl = hackPair.lbl
        hackBtn.name = "hack"
        hackBtn.position = CGPoint(x: 88, y: 50)
        rightCluster.addChild(hackBtn)
        hackRect = CGRect(x: 53, y: 15, width: hackBtnSize.width, height: hackBtnSize.height)
    }

    private func makeButton(color: SKColor, size: CGSize, label: String)
        -> (node: SKNode, bg: SKShapeNode, lbl: SKLabelNode) {
        let node = SKNode()
        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = color
        bg.strokeColor = DLOColor.uiBorder.withAlphaComponent(0.6)
        bg.lineWidth = 1.5
        node.addChild(bg)
        let lbl = SKLabelNode(text: label)
        lbl.fontName = "Menlo-Bold"
        lbl.fontSize = label.count > 2 ? 10 : 18
        lbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.8)
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        node.addChild(lbl)
        return (node, bg, lbl)
    }

    func configure(screenWidth: CGFloat, screenHeight: CGFloat) {
        leftZoneRect = CGRect(x: 0, y: 0,
                              width: screenWidth * 0.4,
                              height: screenHeight * 0.4)
    }

    func layoutRightCluster(x: CGFloat) {
        childNode(withName: "rightCluster")?.position = CGPoint(x: x, y: 0)
    }

    func setInputLocked(_ locked: Bool) {
        inputLocked = locked
        if locked { resetInput() }
    }

    func setInteractHighlight(_ available: Bool) {
        let fill = available
            ? DLOColor.teal.withAlphaComponent(0.45)
            : DLOColor.uiBorder.withAlphaComponent(0.2)
        interactBtnBG?.fillColor = fill
    }

    func setHackHighlight(_ available: Bool) {
        let fill = available
            ? SKColor(red: 0.32, green: 0.48, blue: 0.42, alpha: 0.55)
            : SKColor(red: 0.22, green: 0.28, blue: 0.32, alpha: 0.35)
        hackBtnBG?.fillColor = fill
        hackBtnLbl?.fontColor = available
            ? SKColor(red: 0.62, green: 0.82, blue: 0.68, alpha: 1)
            : DLOColor.terminalAmber.withAlphaComponent(0.55)
    }

    func setHackLabel(_ label: String) {
        hackBtnLbl?.text = label
        hackBtnLbl?.fontSize = label.count > 3 ? 9 : 10
    }

    func setEmpCooldown(ratio: CGFloat) {
        let clamped = max(0, min(1, ratio))
        empCooldownOverlay?.isHidden = clamped <= 0.01
        empBtnBG?.fillColor = clamped > 0.01
            ? DLOColor.uiBorder.withAlphaComponent(0.2)
            : DLOColor.teal.withAlphaComponent(0.35)
        empCooldownOverlay?.alpha = 0.35 + clamped * 0.55
    }

    func notifyTouchBegan(_ touch: UITouch, at pos: CGPoint) {
        guard !inputLocked else { return }
        if let action = rightClusterHit(for: pos) {
            activeTouches[touch] = action
        } else if thumbstickTouch == nil, leftZoneRect.contains(pos) {
            thumbstickTouch = touch
            thumbstick.activate(at: pos)
        }
        updateInput()
    }

    func notifyTouchMoved(_ touch: UITouch, at pos: CGPoint) {
        guard !inputLocked else { return }
        guard touch === thumbstickTouch else { return }
        thumbstick.updateKnob(finger: pos)
        updateInput()
    }

    func notifyTouchEnded(_ touch: UITouch) {
        if touch === thumbstickTouch {
            thumbstickTouch = nil
            thumbstick.deactivate()
        }
        activeTouches.removeValue(forKey: touch)
        updateInput()
    }

    func notifyTouchCancelled(_ touch: UITouch) {
        if touch === thumbstickTouch {
            thumbstickTouch = nil
            thumbstick.deactivate()
        }
        activeTouches.removeValue(forKey: touch)
        updateInput()
    }

    func resetInput() {
        activeTouches.removeAll()
        thumbstickTouch = nil
        thumbstick.resetImmediate()
        currentInput = Input()
    }

    private func rightClusterHit(for pos: CGPoint) -> String? {
        let clusterPos = childNode(withName: "rightCluster")?.position ?? .zero
        let local = CGPoint(x: pos.x - clusterPos.x, y: pos.y - clusterPos.y)
        if interactRect.insetBy(dx: -10, dy: -10).contains(local) { return "interact" }
        if empRect.insetBy(dx: -10, dy: -10).contains(local)       { return "emp" }
        if hackRect.insetBy(dx: -12, dy: -12).contains(local)        { return "hack" }
        return nil
    }

    private func updateInput() {
        guard !inputLocked else {
            currentInput = Input()
            return
        }
        let names = Set(activeTouches.values)
        let stick = thumbstick.snappedVector
        let moveLeft = stick.dx < -0.3
        let moveRight = stick.dx > 0.3

        currentInput = Input(
            left: moveLeft,
            right: moveRight,
            hack: names.contains("hack"),
            crouch: false,
            hide: false,
            interact: names.contains("interact"),
            emp: names.contains("emp"),
            movementVector: thumbstick.normalizedVector
        )
    }
}
