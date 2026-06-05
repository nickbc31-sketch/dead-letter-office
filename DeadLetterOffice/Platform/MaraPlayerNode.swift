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
    private var bodyNode: SKNode!
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
        if UIImage(named: "mara_silhouette") != nil {
            let sprite = SKSpriteNode(imageNamed: "mara_silhouette")
            sprite.size = CGSize(width: 28, height: 60)
            bodyNode = sprite
        } else {
            bodyNode = buildProceduralMara()
        }
        bodyNode.zPosition = 1
        addChild(bodyNode)
    }

    private func buildProceduralMara() -> SKNode {
        let container = SKNode()
        let coat = DLOColor.platformSilhouette
        let teal = DLOColor.teal

        let legL = SKSpriteNode(color: coat, size: CGSize(width: 7, height: 20))
        legL.position = CGPoint(x: -4, y: -15)
        container.addChild(legL)

        let legR = SKSpriteNode(color: coat, size: CGSize(width: 7, height: 20))
        legR.position = CGPoint(x: 4, y: -15)
        container.addChild(legR)

        let torso = SKSpriteNode(color: coat, size: CGSize(width: 20, height: 18))
        torso.position = CGPoint(x: 0, y: 4)
        container.addChild(torso)

        let trim = SKSpriteNode(color: teal, size: CGSize(width: 22, height: 2))
        trim.position = CGPoint(x: 0, y: 14)
        container.addChild(trim)

        let head = SKShapeNode(circleOfRadius: 6)
        head.fillColor = coat
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 23)
        container.addChild(head)

        return container
    }

    private func setupPhysics() {
        let bodySize = CGSize(width: 20, height: 50)
        let body = SKPhysicsBody(rectangleOf: bodySize)
        body.mass = 1.0
        body.allowsRotation = false
        body.restitution = 0
        body.friction = 0.8
        body.linearDamping = 0.08
        body.angularDamping = 1.0
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.ground
        body.contactTestBitMask = PhysicsCategory.pickup | PhysicsCategory.interactable
        physicsBody = body
    }

    // MARK: - Input
    func applyInput(_ input: VirtualPadNode.Input) {
        guard let body = physicsBody else { return }

        isGrounded = abs(body.velocity.dy) < 30
        if isGrounded { jumpCount = 0 }

        isCrouching = input.crouch
        isHiding = input.crouch
        let targetScaleY: CGFloat = isCrouching ? crouchScale : 1.0
        if bodyNode.yScale != targetScaleY {
            bodyNode.run(SKAction.scaleY(to: targetScaleY, duration: 0.08))
        }

        let speed: CGFloat = isCrouching ? moveSpeed * 0.4 : moveSpeed
        if input.left {
            body.velocity.dx = -speed
            if facingRight { flipSprite(right: false) }
        } else if input.right {
            body.velocity.dx = speed
            if !facingRight { flipSprite(right: true) }
        } else {
            body.velocity.dx *= 0.8
        }

        if input.jump && isGrounded && jumpCount < maxJumps && !isCrouching {
            body.velocity.dy = jumpImpulse
            jumpCount += 1
        }

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
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.06),
            SKAction.moveBy(x: 0, y: -2, duration: 0.06)
        ])
        bodyNode.run(bob, withKey: "walkBob")
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
