import SpriteKit

final class MaraPlayerNode: SKNode {

    // State
    private(set) var isCrouching: Bool = false
    private(set) var isHiding: Bool = false
    private(set) var isGrounded: Bool = false
    private(set) var isOnLadder: Bool = false
    private(set) var facingRight: Bool = true

    private var stunCooldown: TimeInterval = 0
    private let stunCooldownMax: TimeInterval = 8.0
    private var lastInputTime: TimeInterval = 0

    // Visual
    private var bodyNode: SKNode!
    private var walkTimer: TimeInterval = 0

    // Physics — tuned for gravity=-700 in PlatformScene (cinematic, low apex)
    private let moveSpeed: CGFloat   = 180
    private let jumpImpulse: CGFloat = 285
    private let ladderClimbSpeed: CGFloat = 130
    private let worldGravity: CGFloat = 700
    private let crouchScale: CGFloat = 0.6
    private var jumpCount: Int = 0
    private let maxJumps: Int = 1
    private var manualAirborne = false
    private let bodyHalfH: CGFloat = 25
    private let floorTopY: CGFloat = 40
    private let standCenterY: CGFloat = 66
    private var ladderRailX: CGFloat = 0
    private var ladderBottomY: CGFloat = 66
    private var ladderTopY: CGFloat = 120

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
            sprite.texture?.filteringMode = .nearest
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
        body.friction = 0          // ground contact must not zero horizontal velocity
        body.linearDamping = 0
        body.angularDamping = 1.0
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.ground
        body.contactTestBitMask = PhysicsCategory.pickup | PhysicsCategory.interactable
        physicsBody = body
    }

    // MARK: - Ladder

    func attachToLadder(railX: CGFloat, bottomY: CGFloat, topY: CGFloat) {
        isOnLadder = true
        ladderRailX = railX
        ladderBottomY = bottomY
        ladderTopY = topY
        manualAirborne = false
        jumpCount = maxJumps
        position.x = railX
        if let body = physicsBody {
            body.velocity = .zero
            body.affectedByGravity = false
            body.collisionBitMask &= ~PhysicsCategory.ground
        }
    }

    func detachFromLadder(standingY: CGFloat) {
        isOnLadder = false
        position.y = standingY
        if let body = physicsBody {
            body.velocity = .zero
            body.affectedByGravity = true
            body.collisionBitMask |= PhysicsCategory.ground
        }
    }

    func applyLadderInput(_ input: VirtualPadNode.Input, delta: TimeInterval) {
        guard isOnLadder else { return }
        let dt = CGFloat(delta)
        var newY = position.y

        if input.movementVector.dy > 0.25 {
            newY += ladderClimbSpeed * dt
        } else if input.movementVector.dy < -0.25 || input.crouch {
            newY -= ladderClimbSpeed * dt
        }

        if input.left || input.right {
            if newY >= ladderTopY - 4 {
                detachFromLadder(standingY: ladderTopY)
                if input.right { facingRight = true; bodyNode.xScale = abs(bodyNode.xScale) }
                else { facingRight = false; bodyNode.xScale = -abs(bodyNode.xScale) }
                return
            }
            if newY <= ladderBottomY + 4 {
                detachFromLadder(standingY: ladderBottomY)
                if input.right { facingRight = true; bodyNode.xScale = abs(bodyNode.xScale) }
                else { facingRight = false; bodyNode.xScale = -abs(bodyNode.xScale) }
                return
            }
        }

        newY = min(ladderTopY, max(ladderBottomY, newY))
        position = CGPoint(x: ladderRailX, y: newY)
    }

    // MARK: - Input
    func applyInput(_ input: VirtualPadNode.Input, delta: TimeInterval = 1.0 / 60.0) {
        guard let body = physicsBody else { return }
        if isOnLadder { return }

        let feetY = position.y - bodyHalfH
        let onFloor = feetY <= floorTopY + 3
        isGrounded = !manualAirborne && (onFloor || abs(body.velocity.dy) < 30)
        if isGrounded { jumpCount = 0 }

        isCrouching = input.crouch
        isHiding = input.crouch
        let targetScaleY: CGFloat = isCrouching ? crouchScale : 1.0
        if bodyNode.yScale != targetScaleY {
            bodyNode.run(SKAction.scaleY(to: targetScaleY, duration: 0.08))
        }

        let speed: CGFloat = isCrouching ? moveSpeed * 0.4 : moveSpeed

        // Jump before horizontal so held movement + jump share one frame with full diagonal velocity.
        if input.jump && !manualAirborne && onFloor && jumpCount < maxJumps && !isCrouching {
            let hx: CGFloat = input.left ? -speed : (input.right ? speed : body.velocity.dx)
            manualAirborne = true
            body.affectedByGravity = false
            body.collisionBitMask &= ~PhysicsCategory.ground
            body.velocity = CGVector(dx: hx, dy: jumpImpulse)
            jumpCount += 1
        }

        if input.left {
            let dy = manualAirborne ? body.velocity.dy : (isGrounded ? min(body.velocity.dy, 0) : body.velocity.dy)
            body.velocity = CGVector(dx: -speed, dy: dy)
            if facingRight { flipSprite(right: false) }
        } else if input.right {
            let dy = manualAirborne ? body.velocity.dy : (isGrounded ? min(body.velocity.dy, 0) : body.velocity.dy)
            body.velocity = CGVector(dx: speed, dy: dy)
            if !facingRight { flipSprite(right: true) }
        } else {
            let dy = manualAirborne ? body.velocity.dy : (isGrounded ? min(body.velocity.dy, 0) : body.velocity.dy)
            body.velocity = CGVector(dx: body.velocity.dx * 0.8, dy: dy)
        }

        if manualAirborne {
            let dt = CGFloat(delta)
            let vy = body.velocity.dy - worldGravity * dt
            body.velocity = CGVector(dx: body.velocity.dx, dy: vy)
            if vy <= 0 {
                body.collisionBitMask |= PhysicsCategory.ground
                body.affectedByGravity = true
            }
        }

        if input.left || input.right {
            walkTimer += 0.016
            if walkTimer > 0.12 {
                walkTimer = 0
                animateWalk()
            }
        }
    }

    func finishAirbornePhysicsStep() {
        guard manualAirborne, let body = physicsBody else { return }
        let feetY = position.y - bodyHalfH
        if body.velocity.dy <= 0 && feetY <= floorTopY + 1 {
            manualAirborne = false
            body.collisionBitMask |= PhysicsCategory.ground
            body.affectedByGravity = true
            position.y = standCenterY
            body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
        } else if body.velocity.dy <= 0 && abs(body.velocity.dy) < 25 {
            manualAirborne = false
            body.collisionBitMask |= PhysicsCategory.ground
            body.affectedByGravity = true
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
