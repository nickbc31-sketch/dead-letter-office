import SpriteKit

/// Dynamic disappearing thumbstick — hidden until touched, fades out on release.
final class ThumbstickNode: SKNode {

    private let baseRadius: CGFloat = 50
    private let knobRadius: CGFloat = 20
    private let deadZone: CGFloat = 0.18

    private let baseRing: SKShapeNode
    private let knob: SKShapeNode

    private(set) var normalizedVector = CGVector.zero
    private(set) var snappedVector = CGVector.zero
    private(set) var crouchIntent = false
    private(set) var hideIntent = false

    var isActive: Bool { alpha > 0.01 }

    override init() {
        baseRing = SKShapeNode(circleOfRadius: 50)
        baseRing.fillColor = DLOColor.uiBorder.withAlphaComponent(0.12)
        baseRing.strokeColor = DLOColor.uiBorder.withAlphaComponent(0.45)
        baseRing.lineWidth = 1.5

        knob = SKShapeNode(circleOfRadius: 20)
        knob.fillColor = DLOColor.terminalAmber.withAlphaComponent(0.35)
        knob.strokeColor = DLOColor.uiBorder.withAlphaComponent(0.65)
        knob.lineWidth = 1.5

        super.init()
        alpha = 0
        isHidden = true
        zPosition = 10
        addChild(baseRing)
        addChild(knob)
    }

    required init?(coder: NSCoder) { fatalError() }

    func activate(at center: CGPoint) {
        removeAllActions()
        position = center
        knob.position = .zero
        clearVectors()
        isHidden = false
        alpha = 0
        run(SKAction.fadeAlpha(to: 0.85, duration: 0.1))
    }

    func updateKnob(finger: CGPoint) {
        let offset = CGPoint(x: finger.x - position.x, y: finger.y - position.y)
        let dist = hypot(offset.x, offset.y)
        let clamped: CGPoint
        if dist > baseRadius {
            clamped = CGPoint(x: offset.x / dist * baseRadius, y: offset.y / dist * baseRadius)
        } else {
            clamped = offset
        }
        knob.position = clamped

        let nx = clamped.x / baseRadius
        let ny = clamped.y / baseRadius
        let mag = hypot(nx, ny)
        guard mag >= deadZone else {
            clearVectors()
            return
        }

        normalizedVector = CGVector(dx: nx, dy: ny)

        let angle = atan2(ny, nx)
        let sector = round(angle / (.pi / 4))
        let snappedAngle = sector * (.pi / 4)
        let sx = cos(snappedAngle)
        let sy = sin(snappedAngle)
        snappedVector = CGVector(dx: sx, dy: sy)

        crouchIntent = sy < -0.4
        hideIntent = sy > 0.4
    }

    func deactivate() {
        removeAllActions()
        clearVectors()
        knob.position = .zero
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.12),
            SKAction.run { [weak self] in
                self?.isHidden = true
            }
        ]))
    }

    func resetImmediate() {
        removeAllActions()
        clearVectors()
        knob.position = .zero
        alpha = 0
        isHidden = true
    }

    private func clearVectors() {
        normalizedVector = .zero
        snappedVector = .zero
        crouchIntent = false
        hideIntent = false
    }
}
