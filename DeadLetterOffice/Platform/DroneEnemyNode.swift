import SpriteKit

final class DroneEnemyNode: SKNode {

    private let patrolPoints: [CGPoint]
    private let droneSpeed: CGFloat
    private let pauseDuration: TimeInterval
    private let isGuard: Bool

    private var currentPointIndex: Int = 0
    private var isPausing: Bool = false
    private var pauseTimer: TimeInterval = 0
    private var stunTimer: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var facingRight: Bool = true
    private var patrolSegmentVertical = false
    private var lastSideFacing: DroneFacing = .right

    var isStunned: Bool { stunTimer > 0 }

    private var bodySprite: SKNode?
    private var scanLight: SKShapeNode?
    private var alertIndicator: SKShapeNode?
    private(set) var isAlerted: Bool = false

    init(patrolPoints: [CGPoint], speed: CGFloat, pauseDuration: TimeInterval,
         isGuard: Bool = false) {
        self.patrolPoints = patrolPoints
        self.droneSpeed = speed
        self.pauseDuration = pauseDuration
        self.isGuard = isGuard
        super.init()
        if let first = patrolPoints.first {
            position = first
        }
        if isGuard { buildGuardSprite() } else { buildSprite() }
    }
    required init?(coder: NSCoder) { fatalError() }

    private enum DroneFacing {
        case left
        case right
        case down
    }

    private struct DroneArt {
        let texture: SKTexture
        let usesDirectionalArt: Bool
    }

    /// Resolves directional drone art when available; falls back to legacy sprite.
    private static func droneArt(for facing: DroneFacing) -> DroneArt? {
        let assetName: String
        switch facing {
        case .left:  assetName = "drone_side_left"
        case .right: assetName = "drone_side_right"
        case .down:  assetName = "drone_down"
        }
        if UIImage(named: assetName) != nil {
            let tex = SKTexture(imageNamed: assetName)
            tex.filteringMode = .nearest
            return DroneArt(texture: tex, usesDirectionalArt: true)
        }
        switch facing {
        case .down:
            if UIImage(named: "pmca_drone_v1") != nil {
                let tex = SKTexture(imageNamed: "pmca_drone_v1")
                tex.filteringMode = .nearest
                return DroneArt(texture: tex, usesDirectionalArt: false)
            }
        case .left, .right:
            if UIImage(named: "drone_side") != nil {
                let tex = SKTexture(imageNamed: "drone_side")
                tex.filteringMode = .nearest
                return DroneArt(texture: tex, usesDirectionalArt: false)
            }
            if UIImage(named: "pmca_drone_v1") != nil {
                let tex = SKTexture(imageNamed: "pmca_drone_v1")
                tex.filteringMode = .nearest
                return DroneArt(texture: tex, usesDirectionalArt: false)
            }
        }
        return nil
    }

    private static func displaySize(for facing: DroneFacing) -> CGSize {
        switch facing {
        case .down:
            return CGSize(width: 36, height: 28)
        case .left, .right:
            return CGSize(width: 44, height: 29)
        }
    }

    private static func initialFacing(from patrolPoints: [CGPoint]) -> DroneFacing {
        guard patrolPoints.count > 1 else { return .right }
        let diff = CGPoint(
            x: patrolPoints[1].x - patrolPoints[0].x,
            y: patrolPoints[1].y - patrolPoints[0].y)
        if abs(diff.y) > abs(diff.x) * 1.2 { return .down }
        return diff.x < 0 ? .left : .right
    }

    private func buildSprite() {
        let startFacing = Self.initialFacing(from: patrolPoints)
        lastSideFacing = startFacing == .left ? .left : .right
        facingRight = lastSideFacing == .right
        patrolSegmentVertical = startFacing == .down

        let body: SKSpriteNode
        if let art = Self.droneArt(for: startFacing) {
            let sprite = SKSpriteNode(texture: art.texture)
            sprite.size = Self.displaySize(for: startFacing)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.58)
            applyDirectionalFlip(to: sprite, facing: startFacing, usesDirectionalArt: art.usesDirectionalArt)
            body = sprite
        } else {
            let bodySize = CGSize(width: 36, height: 18)
            let placeholder = SKSpriteNode(color: DLOColor.platformSilhouette, size: bodySize)
            for xOff: CGFloat in [-12, 12] {
                let light = SKShapeNode(circleOfRadius: 3)
                light.fillColor = DLOColor.teal
                light.strokeColor = .clear
                light.position = CGPoint(x: xOff, y: 0)
                placeholder.addChild(light)
                light.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.4),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.4)
                ])))
            }
            body = placeholder
        }
        addChild(body)

        // Scan cone (points downward)
        let scanPath = CGMutablePath()
        scanPath.move(to: .zero)
        scanPath.addLine(to: CGPoint(x: -60, y: -120))
        scanPath.addLine(to: CGPoint(x: 60, y: -120))
        scanPath.closeSubpath()

        let cone = SKShapeNode(path: scanPath)
        cone.fillColor = DLOColor.scanLight
        cone.strokeColor = .clear
        cone.position = CGPoint(x: 0, y: -8)
        cone.zPosition = -1
        addChild(cone)
        scanLight = cone

        let alert = SKShapeNode(circleOfRadius: 6)
        alert.fillColor = DLOColor.danger
        alert.strokeColor = .clear
        alert.position = CGPoint(x: 0, y: 14)
        alert.alpha = 0
        addChild(alert)
        alertIndicator = alert

        bodySprite = body
    }

    // MARK: - Guard Sprite (human PMCA security guard)

    private static let guardDisplayHeight: CGFloat = 72

    private func buildGuardSprite() {
        let torsoY: CGFloat
        let alertY: CGFloat

        if let tex = FieldSpriteAssets.texture(named: "pmca_guard") {
            let sprite = SKSpriteNode(texture: tex)
            let aspect = tex.size().width / max(tex.size().height, 1)
            sprite.size = CGSize(width: Self.guardDisplayHeight * aspect,
                                 height: Self.guardDisplayHeight)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
            addChild(sprite)
            bodySprite = sprite
            torsoY = Self.guardDisplayHeight * 0.45
            alertY = Self.guardDisplayHeight + 6
        } else {
            let coatColor = DLOColor.platformSilhouette
            let accentColor = DLOColor.danger.withAlphaComponent(0.7)

            let legs = SKSpriteNode(color: coatColor, size: CGSize(width: 18, height: 20))
            legs.position = CGPoint(x: 0, y: 10)
            addChild(legs)

            let torso = SKSpriteNode(color: coatColor, size: CGSize(width: 22, height: 22))
            torso.position = CGPoint(x: 0, y: 32)
            addChild(torso)

            let band = SKSpriteNode(color: accentColor, size: CGSize(width: 22, height: 3))
            band.position = CGPoint(x: 0, y: 35)
            addChild(band)

            let head = SKShapeNode(circleOfRadius: 8)
            head.fillColor = coatColor
            head.strokeColor = .clear
            head.position = CGPoint(x: 0, y: 53)
            addChild(head)

            bodySprite = torso
            torsoY = 32
            alertY = 66
        }

        let scanPath = CGMutablePath()
        scanPath.move(to: .zero)
        scanPath.addLine(to: CGPoint(x: 90, y: -30))
        scanPath.addLine(to: CGPoint(x: 90, y: 30))
        scanPath.closeSubpath()

        let cone = SKShapeNode(path: scanPath)
        cone.fillColor = DLOColor.scanLight
        cone.strokeColor = .clear
        cone.position = CGPoint(x: 10, y: torsoY)
        cone.zPosition = -1
        addChild(cone)
        scanLight = cone

        let alert = SKShapeNode(circleOfRadius: 5)
        alert.fillColor = DLOColor.danger
        alert.strokeColor = .clear
        alert.position = CGPoint(x: 0, y: alertY)
        alert.alpha = 0
        addChild(alert)
        alertIndicator = alert

        applyGuardVisualFacing()
    }

    private func applyGuardVisualFacing() {
        guard isGuard else { return }
        if let sprite = bodySprite as? SKSpriteNode {
            sprite.xScale = facingRight ? 1 : -1
        }
        scanLight?.position = CGPoint(x: facingRight ? 10 : -10,
                                      y: scanLight?.position.y ?? Self.guardDisplayHeight * 0.45)
    }

    // MARK: - Patrol Update
    func update(currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        guard patrolPoints.count > 1 else { return }

        if stunTimer > 0 {
            stunTimer -= delta
            if stunTimer <= 0, let scanLight {
                scanLight.fillColor = DLOColor.scanLight
                scanLight.alpha = 1.0
            }
            return
        }

        if isPausing {
            pauseTimer -= delta
            if pauseTimer <= 0 {
                isPausing = false
                currentPointIndex = (currentPointIndex + 1) % patrolPoints.count
            }
            return
        }

        let target = patrolPoints[currentPointIndex]
        let diff = CGPoint(x: target.x - position.x, y: target.y - position.y)
        let dist = hypot(diff.x, diff.y)

        if dist < 4 {
            isPausing = true
            pauseTimer = pauseDuration
            let pauseFacing: DroneFacing = patrolSegmentVertical ? .down : lastSideFacing
            applyDroneVisual(facing: pauseFacing, horizontalVelocityX: 0)
            return
        }

        let move = CGPoint(x: diff.x / dist * droneSpeed * CGFloat(delta),
                           y: diff.y / dist * droneSpeed * CGFloat(delta))
        position = CGPoint(x: position.x + move.x, y: position.y + move.y)

        let verticalPatrol = abs(diff.y) > abs(diff.x) * 1.2
        patrolSegmentVertical = verticalPatrol

        let facing: DroneFacing
        if verticalPatrol {
            facing = .down
        } else if diff.x < 0 {
            facing = .left
            lastSideFacing = .left
            facingRight = false
        } else if diff.x > 0 {
            facing = .right
            lastSideFacing = .right
            facingRight = true
        } else {
            facing = lastSideFacing
        }

        if isGuard {
            applyGuardVisualFacing()
        } else {
            applyDroneVisual(facing: facing, horizontalVelocityX: diff.x)
        }
    }

    private func applyDirectionalFlip(
        to sprite: SKSpriteNode, facing: DroneFacing, usesDirectionalArt: Bool
    ) {
        if usesDirectionalArt || facing == .down {
            sprite.xScale = 1
            return
        }
        sprite.xScale = facing == .left ? -1 : 1
    }

    private func applyDroneVisual(facing: DroneFacing, horizontalVelocityX: CGFloat) {
        guard let sprite = bodySprite as? SKSpriteNode else { return }
        guard let art = Self.droneArt(for: facing) else { return }
        art.texture.filteringMode = .nearest
        sprite.texture = art.texture
        sprite.size = Self.displaySize(for: facing)
        applyDirectionalFlip(to: sprite, facing: facing, usesDirectionalArt: art.usesDirectionalArt)

        if facing == .down || patrolSegmentVertical {
            scanLight?.xScale = 1
        } else {
            let faceRight = horizontalVelocityX > 0
                || (horizontalVelocityX == 0 && lastSideFacing == .right)
            scanLight?.xScale = faceRight ? 1 : -1
        }
    }

    // Cone-based line-of-sight check matching the visual scan cone geometry.
    // Drone: downward triangle 120 deep × ±60 wide (half-angle ≈27°).
    // Guard: forward triangle 90 wide × ±30 tall from torso (half-angle ≈18°).
    func canSee(target: CGPoint) -> Bool {
        guard stunTimer <= 0 else { return false }
        if isGuard {
            // Apex is at torso height (y+32), offset 10pt forward
            let apexX = position.x + (facingRight ? 10 : -10)
            let apexY = position.y + 32
            let forward = facingRight ? (target.x - apexX) : (apexX - target.x)
            guard forward > 0 && forward <= 90 else { return false }
            let allowedDY = forward / 3.0   // ±30 at range 90
            return abs(target.y - apexY) <= allowedDY
        } else {
            // Apex matches scanLight origin (y offset -8), scans straight down
            let apexY = position.y - 8
            let below = apexY - target.y
            guard below > 0 && below <= 120 else { return false }
            let allowedDX = below * 0.5     // ±60 at depth 120
            return abs(target.x - position.x) <= allowedDX
        }
    }

    func alert() {
        guard !isAlerted, let alertIndicator, let scanLight else { return }
        isAlerted = true
        alertIndicator.alpha = 1
        alertIndicator.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.fadeIn(withDuration: 0.15)
        ])))
        scanLight.run(SKAction.colorize(with: DLOColor.danger, colorBlendFactor: 1.0, duration: 0.2))
    }

    func stun(duration: TimeInterval = 8.0) {
        stunTimer = duration
        isAlerted = false
        alertIndicator?.alpha = 0
        alertIndicator?.removeAllActions()
        scanLight?.fillColor = DLOColor.teal.withAlphaComponent(0.2)
        scanLight?.alpha = 0.35
        bodySprite?.removeAction(forKey: "stunTint")
        bodySprite?.run(SKAction.sequence([
            SKAction.colorize(with: DLOColor.teal.withAlphaComponent(0.45), colorBlendFactor: 0.7, duration: 0.1),
            SKAction.wait(forDuration: duration),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.25)
        ]), withKey: "stunTint")
    }
}
