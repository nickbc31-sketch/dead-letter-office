import SpriteKit

struct SecurityCameraSpec: Codable {
    var id: String
    var position: [CGFloat]
    var coneLength: CGFloat?
    var coneAngle: CGFloat?       // degrees
    var scanAmplitude: CGFloat?   // degrees of sweep; nil = fixed
    var scanSpeed: CGFloat?
    var disabledFlag: String?
    var hackableRelayID: String?
}

/// Fixed or slow-scanning security camera — distinct from patrol drones.
final class SecurityCameraNode: SKNode {

    private let coneLength: CGFloat
    private let halfAngle: CGFloat
    private let scanAmplitude: CGFloat
    private let scanSpeed: CGFloat
    private let disabledFlag: String?
    private var scanPhase: CGFloat = 0
    private var coneNode: SKShapeNode!
    private(set) var isDisabled = false

    init(spec: SecurityCameraSpec) {
        coneLength = spec.coneLength ?? 140
        halfAngle = (spec.coneAngle ?? 42) * .pi / 180 / 2
        scanAmplitude = (spec.scanAmplitude ?? 0) * .pi / 180
        scanSpeed = spec.scanSpeed ?? 0.8
        disabledFlag = spec.disabledFlag
        super.init()
        name = "camera_\(spec.id)"
        position = CGPoint(x: spec.position[0], y: spec.position[1])
        buildVisual()
        if let flag = disabledFlag, GameState.shared.hasFlag(flag) {
            setDisabled(true)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildVisual() {
        let mountTop: CGFloat
        if let sprite = FieldSpriteAssets.groundedSprite(named: "security_camera", targetHeight: 44) {
            addChild(sprite)
            mountTop = 44
        } else {
            let housing = SKSpriteNode(
                color: SKColor(red: 0.10, green: 0.12, blue: 0.14, alpha: 1),
                size: CGSize(width: 18, height: 14))
            housing.position = CGPoint(x: 0, y: 52)
            addChild(housing)

            let lens = SKShapeNode(circleOfRadius: 4)
            lens.fillColor = SKColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1)
            lens.strokeColor = DLOColor.danger.withAlphaComponent(0.5)
            lens.lineWidth = 1
            lens.position = CGPoint(x: 0, y: 52)
            addChild(lens)

            let mount = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.5),
                                     size: CGSize(width: 4, height: 20))
            mount.position = CGPoint(x: 0, y: 40)
            addChild(mount)
            mountTop = 64
        }

        coneNode = SKShapeNode()
        coneNode.fillColor = DLOColor.danger.withAlphaComponent(0.12)
        coneNode.strokeColor = DLOColor.danger.withAlphaComponent(0.35)
        coneNode.lineWidth = 1
        coneNode.zPosition = -1
        addChild(coneNode)
        redrawCone(facing: 0)

        let lbl = DLOFont.terminalLabel(text: "CAM", size: 5)
        lbl.fontColor = DLOColor.danger.withAlphaComponent(0.7)
        lbl.position = CGPoint(x: 0, y: mountTop + 8)
        addChild(lbl)
    }

    private func redrawCone(facing angle: CGFloat) {
        let path = CGMutablePath()
        path.move(to: .zero)
        let a1 = angle - halfAngle
        let a2 = angle + halfAngle
        path.addLine(to: CGPoint(x: cos(a1) * coneLength, y: sin(a1) * coneLength))
        path.addLine(to: CGPoint(x: cos(a2) * coneLength, y: sin(a2) * coneLength))
        path.closeSubpath()
        coneNode.path = path
    }

    func update(delta: TimeInterval) {
        guard !isDisabled else { return }
        if scanAmplitude > 0 {
            scanPhase += CGFloat(delta) * scanSpeed
            let facing = sin(scanPhase) * scanAmplitude - .pi / 2
            redrawCone(facing: facing)
        } else {
            redrawCone(facing: -.pi / 2)
        }
    }

    func setDisabled(_ disabled: Bool) {
        isDisabled = disabled
        coneNode.alpha = disabled ? 0.15 : 1
        isHidden = disabled
    }

    func canSee(target: CGPoint) -> Bool {
        guard !isDisabled else { return false }
        let local = CGPoint(x: target.x - position.x, y: target.y - position.y)
        guard local.y < 20 else { return false }
        let dist = hypot(local.x, local.y)
        guard dist > 8, dist < coneLength else { return false }
        let angle = atan2(local.y, local.x)
        let facing: CGFloat
        if scanAmplitude > 0 {
            facing = sin(scanPhase) * scanAmplitude - .pi / 2
        } else {
            facing = -.pi / 2
        }
        var diff = angle - facing
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return abs(diff) <= halfAngle + 0.08
    }
}
