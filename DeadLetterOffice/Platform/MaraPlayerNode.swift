import SpriteKit

final class MaraPlayerNode: SKNode {

    // State
    private(set) var isCrouching: Bool = false
    private(set) var isHiding: Bool = false
    private(set) var isGrounded: Bool = false
    private(set) var facingRight: Bool = true

    private var stunCooldown: TimeInterval = 0
    private let stunCooldownMax: TimeInterval = 8.0
    private var lastInputTime: TimeInterval = 0

    // Visual
    private var bodyNode: SKSpriteNode!
    private var headNode: SKSpriteNode!
    private var walkAnimFrames: [SKTexture] = []
    private var currentWalkFrame: Int = 0
    private var walkTimer: TimeInterval = 0

    // Physics — tuned for gravity=-700 in PlatformScene
    private let moveSpeed: CGFloat   = 180
    private let jumpImpulse: CGFloat = 500
    private let crouchScale: CGFloat = 0.6
    private var jumpCount: Int = 0
    private let maxJumps: Int = 1

    override init() {
        super.init()
        buildSprite()
        setupPhysics()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Visual
    private func buildSprite() {
        // Try to load art asset; fall back to procedural shape
        if UIImage(named: "mara_silhouette") != nil {
            bodyNode = SKSpriteNode(imageNamed: "mara_silhouette")
            bodyNode.size = CGSize(width: 28, height: 60)
        } else {
            bodyNode = buildProceduralMara()
        }
        bodyNode.zPosition = 1
        addChild(bodyNode)
    }

    private func buildProceduralMara() -> SKSpriteNode {
        let size = CGSize(width: 24, height: 52)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKSpriteNode(color: DLOColor.terminalAmber, size: size)
        }

        // Body silhouette in Mara's distinct dark coat
        let coatColor = UIColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1)
        let accentColor = UIColor(red: 0.00, green: 0.71, blue: 0.79, alpha: 1) // teal trim

        // Legs
        ctx.setFillColor(coatColor.cgColor)
        ctx.fill(CGRect(x: 4, y: 0, width: 7, height: 20))
        ctx.fill(CGRect(x: 13, y: 0, width: 7, height: 20))

        // Coat body
        ctx.fill(CGRect(x: 2, y: 18, width: 20, height: 22))

        // Shoulder trim
        ctx.setFillColor(accentColor.cgColor)
        ctx.fill(CGRect(x: 1, y: 37, width: 22, height: 2))

        // Head
        ctx.setFillColor(coatColor.cgColor)
        ctx.addEllipse(in: CGRect(x: 6, y: 40, width: 12, height: 12))
        ctx.fillPath()

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let img = img {
            return SKSpriteNode(texture: SKTexture(image: img), size: size)
        }
        return SKSpriteNode(color: DLOColor.platformSilhouette, size: size)
    }

    private func setupPhysics() {
        let bodySize = CGSize(width: 20, height: 50)
        let body = SKPhysicsBody(rectangleOf: bodySize)
        body.mass = 1.0
        body.allowsRotation = false
        body.restitution = 0
        body.friction = 0.8
        body.linearDamping = 0.08   // reduced from 0.5 — better airborne control
        body.angularDamping = 1.0
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.ground
        body.contactTestBitMask = PhysicsCategory.pickup | PhysicsCategory.interactable
        physicsBody = body
    }

    // MARK: - Input
    func applyInput(_ input: VirtualPadNode.Input) {
        guard let body = physicsBody else { return }

        isGrounded = abs(body.velocity.dy) < 30   // threshold raised for gravity=-700

        if isGrounded { jumpCount = 0 }

        // Crouch / hide
        isCrouching = input.crouch
        isHiding = input.crouch
        let targetScaleY: CGFloat = isCrouching ? crouchScale : 1.0
        if bodyNode.yScale != targetScaleY {
            bodyNode.run(SKAction.scaleY(to: targetScaleY, duration: 0.08))
        }

        // Horizontal movement
        let speed: CGFloat = isCrouching ? moveSpeed * 0.4 : moveSpeed
        if input.left {
            body.velocity.dx = -speed
            if facingRight { flipSprite(right: false) }
        } else if input.right {
            body.velocity.dx = speed
            if !facingRight { flipSprite(right: true) }
        } else {
            body.velocity.dx *= 0.8   // friction deceleration
        }

        // Jump
        if input.jump && isGrounded && jumpCount < maxJumps && !isCrouching {
            body.velocity.dy = jumpImpulse
            jumpCount += 1
        }

        // Walk animation tick
        if input.left || input.right {
            walkTimer += 0.016
            if walkTimer > 0.12 {
                walkTimer = 0
                animateWalk()
            }
        }
    }

    private func flipSprite(right: Bool) {
        facingRight = right
        bodyNode.xScale = right ? 1 : -1
    }

    private func animateWalk() {
        // Simple bob animation since we don't have a walk cycle yet
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.06),
            SKAction.moveBy(x: 0, y: -2, duration: 0.06)
        ])
        bodyNode.run(bob)
    }

    // MARK: - Stun Pulse
    func fireStunPulse(scene: SKScene) -> Bool {
        guard stunCooldown <= 0 else { return false }
        stunCooldown = stunCooldownMax

        let pulse = SKShapeNode(circleOfRadius: 120)
        pulse.fillColor = DLOColor.teal.withAlphaComponent(0.3)
        pulse.strokeColor = DLOColor.teal
        pulse.lineWidth = 2
        pulse.position = position
        pulse.zPosition = 45
        scene.addChild(pulse)

        pulse.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.5, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.removeFromParent()
        ]))
        return true
    }

    func updateStunCooldown(delta: TimeInterval) {
        if stunCooldown > 0 { stunCooldown -= delta }
    }

    var stunCooldownRatio: CGFloat {
        return CGFloat(max(0, stunCooldown) / stunCooldownMax)
    }
}
