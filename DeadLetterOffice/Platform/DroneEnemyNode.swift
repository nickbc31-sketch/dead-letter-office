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

    var isStunned: Bool { stunTimer > 0 }

    private var bodySprite: SKNode!
    private var scanLight: SKShapeNode!
    private var alertIndicator: SKShapeNode!
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

    private func buildSprite() {
        let body: SKSpriteNode
        if UIImage(named: "pmca_drone_v1") != nil {
            let sprite = SKSpriteNode(imageNamed: "pmca_drone_v1")
            sprite.texture?.filteringMode = .linear
            sprite.size = CGSize(width: 44, height: 29)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.58)
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

        scanLight = SKShapeNode(path: scanPath)
        scanLight.fillColor = DLOColor.scanLight
        scanLight.strokeColor = .clear
        scanLight.position = CGPoint(x: 0, y: -8)
        scanLight.zPosition = -1
        addChild(scanLight)

        // Alert indicator
        alertIndicator = SKShapeNode(circleOfRadius: 6)
        alertIndicator.fillColor = DLOColor.danger
        alertIndicator.strokeColor = .clear
        alertIndicator.position = CGPoint(x: 0, y: 14)
        alertIndicator.alpha = 0
        addChild(alertIndicator)

        bodySprite = body
    }

    // MARK: - Guard Sprite (human security guard silhouette)

    private func buildGuardSprite() {
        // Humanoid: legs, torso, head
        let coatColor = DLOColor.platformSilhouette
        let accentColor = DLOColor.danger.withAlphaComponent(0.7)

        let legs = SKSpriteNode(color: coatColor, size: CGSize(width: 18, height: 20))
        legs.position = CGPoint(x: 0, y: 10)
        addChild(legs)

        let torso = SKSpriteNode(color: coatColor, size: CGSize(width: 22, height: 22))
        torso.position = CGPoint(x: 0, y: 32)
        addChild(torso)

        // Red armband
        let band = SKSpriteNode(color: accentColor, size: CGSize(width: 22, height: 3))
        band.position = CGPoint(x: 0, y: 35)
        addChild(band)

        let head = SKShapeNode(circleOfRadius: 8)
        head.fillColor = coatColor
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 53)
        addChild(head)

        // Scan cone (points forward / sideways)
        let scanPath = CGMutablePath()
        scanPath.move(to: .zero)
        scanPath.addLine(to: CGPoint(x: 90, y: -30))
        scanPath.addLine(to: CGPoint(x: 90, y: 30))
        scanPath.closeSubpath()

        scanLight = SKShapeNode(path: scanPath)
        scanLight.fillColor = DLOColor.scanLight
        scanLight.strokeColor = .clear
        scanLight.position = CGPoint(x: 10, y: 32)
        scanLight.zPosition = -1
        addChild(scanLight)

        alertIndicator = SKShapeNode(circleOfRadius: 5)
        alertIndicator.fillColor = DLOColor.danger
        alertIndicator.strokeColor = .clear
        alertIndicator.position = CGPoint(x: 0, y: 66)
        alertIndicator.alpha = 0
        addChild(alertIndicator)

        bodySprite = torso
    }

    // MARK: - Patrol Update
    func update(currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        guard patrolPoints.count > 1 else { return }

        if stunTimer > 0 {
            stunTimer -= delta
            if stunTimer <= 0 {
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
            return
        }

        let move = CGPoint(x: diff.x / dist * droneSpeed * CGFloat(delta),
                           y: diff.y / dist * droneSpeed * CGFloat(delta))
        position = CGPoint(x: position.x + move.x, y: position.y + move.y)

        // Orient body and scan cone to direction of travel
        facingRight = diff.x >= 0
        bodySprite.xScale = facingRight ? 1 : -1
        scanLight.xScale = facingRight ? 1 : -1
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
        guard !isAlerted else { return }
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
        alertIndicator.alpha = 0
        alertIndicator.removeAllActions()
        scanLight.fillColor = DLOColor.teal.withAlphaComponent(0.2)
        scanLight.alpha = 0.35
        bodySprite.removeAction(forKey: "stunTint")
        bodySprite.run(SKAction.sequence([
            SKAction.colorize(with: DLOColor.teal.withAlphaComponent(0.45), colorBlendFactor: 0.7, duration: 0.1),
            SKAction.wait(forDuration: duration),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.25)
        ]), withKey: "stunTint")
    }
}
