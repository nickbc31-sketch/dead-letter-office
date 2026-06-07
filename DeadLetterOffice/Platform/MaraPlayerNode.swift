import SpriteKit

final class MaraPlayerNode: SKNode {

    static let defaultStandCenterY: CGFloat = 71

    // State
    private(set) var isCrouching: Bool = false
    private(set) var isHiding: Bool = false
    private(set) var isGrounded: Bool = false
    private(set) var isOnLadder: Bool = false
    private(set) var facingRight: Bool = true
    var pdaVisualOut: Bool { anim.pdaVisualOut }
    var isActionAnimating: Bool { anim.isOneShotPlaying }

    private var stunCooldown: TimeInterval = 0
    private let stunCooldownMax: TimeInterval = 8.0

    private var bodyNode: SKSpriteNode?
    private let anim = MaraAnimationController()
    private var wasMoving = false
    private var locomotionHold: TimeInterval = 0
    private let locomotionHoldDuration: TimeInterval = 0.12

    // Physics — tuned for gravity=-700 in PlatformScene
    private let moveSpeed: CGFloat   = 180
    private let jumpImpulse: CGFloat = 285
    private let ladderClimbSpeed: CGFloat = 130
    private let worldGravity: CGFloat = 700
    private let crouchScale: CGFloat = 0.6
    private var jumpCount: Int = 0
    private let maxJumps: Int = 1
    private var manualAirborne = false
    private let bodyHalfH: CGFloat = 31
    private let floorTopY: CGFloat = 40
    private let standCenterY: CGFloat = 71
    private var ladderRailX: CGFloat = 0
    private var ladderBottomY: CGFloat = 66
    private var ladderTopY: CGFloat = 120

    override init() {
        super.init()
        buildSprite()
        setupPhysics()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Preload

    static func preloadAnimations(completion: @escaping () -> Void) {
        MaraAnimationController.preload(completion: completion)
    }

    // MARK: - Visual

    private func buildSprite() {
        let sprite = SKSpriteNode()
        sprite.zPosition = 1
        addChild(sprite)
        bodyNode = sprite
        anim.attach(to: sprite)
    }

    private func setupPhysics() {
        let bodySize = CGSize(width: 26, height: 62)
        let body = SKPhysicsBody(rectangleOf: bodySize)
        body.mass = 1.0
        body.allowsRotation = false
        body.restitution = 0
        body.friction = 0
        body.linearDamping = 0
        body.angularDamping = 1.0
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.ground
        body.contactTestBitMask = PhysicsCategory.pickup | PhysicsCategory.interactable
        physicsBody = body
    }

    // MARK: - Animation API (PlatformScene)

    func ensurePDAOut(completion: @escaping () -> Void) {
        anim.ensurePDAOut(completion: completion)
    }

    func putAwayPDA(completion: @escaping () -> Void) {
        anim.putAwayPDA(completion: completion)
    }

    func playScanObserve(completion: @escaping () -> Void) {
        ensurePDAOut { [weak self] in
            self?.anim.playScanObserve(completion: completion)
        }
    }

    func playTerminalInteraction(completion: @escaping () -> Void) {
        ensurePDAOut { [weak self] in
            self?.anim.playTerminalInteraction(completion: completion)
        }
    }

    func playHackConnect(completion: @escaping () -> Void) {
        ensurePDAOut { [weak self] in
            self?.anim.playHackConnect(completion: completion)
        }
    }

    func playEMPActivation(onPulse: @escaping () -> Void, completion: @escaping () -> Void = {}) {
        guard canFireEMP else { return }
        ensurePDAOut { [weak self] in
            guard let self else { return }
            self.anim.playEMPActivation(onPulseFrame: { [weak self] in
                guard let self else { return }
                self.stunCooldown = self.stunCooldownMax
                onPulse()
            }, completion: completion)
        }
    }

    var canFireEMP: Bool { stunCooldown <= 0 && !anim.isOneShotPlaying }

    // MARK: - Movement halt

    func haltMovement() {
        manualAirborne = false
        wasMoving = false
        locomotionHold = 0
        anim.updateLocomotion(isMoving: false)
        if isOnLadder {
            detachFromLadder(standingY: position.y)
        }
        if let body = physicsBody {
            body.velocity = .zero
            body.affectedByGravity = true
            body.collisionBitMask |= PhysicsCategory.ground
        }
    }

    // MARK: - Ladder

    func attachToLadder(railX: CGFloat, bottomY: CGFloat, topY: CGFloat) {
        isOnLadder = true
        ladderRailX = railX
        ladderBottomY = bottomY
        ladderTopY = topY
        manualAirborne = false
        jumpCount = maxJumps
        wasMoving = false
        locomotionHold = 0
        anim.updateLocomotion(isMoving: false)
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

        if input.movementVector.dy > 0.22 {
            newY += ladderClimbSpeed * dt
        } else if input.movementVector.dy < -0.22 || input.crouch {
            newY -= ladderClimbSpeed * dt
        }

        if newY >= ladderTopY - 3 {
            detachFromLadder(standingY: ladderTopY)
            if input.right {
                position.x += 28
                flipSprite(right: true)
            } else if input.left {
                position.x -= 28
                flipSprite(right: false)
            }
            return
        }

        if newY <= ladderBottomY + 3 {
            detachFromLadder(standingY: ladderBottomY)
            if input.right {
                position.x += 20
                flipSprite(right: true)
            } else if input.left {
                position.x -= 20
                flipSprite(right: false)
            }
            return
        }

        if input.left || input.right {
            if newY >= ladderTopY - 8 {
                detachFromLadder(standingY: ladderTopY)
                position.x += input.right ? 28 : -28
                flipSprite(right: input.right)
                return
            }
            if newY <= ladderBottomY + 8 {
                detachFromLadder(standingY: ladderBottomY)
                position.x += input.right ? 20 : -20
                flipSprite(right: input.right)
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
        anim.applyCrouchScale(targetScaleY)

        let speed: CGFloat = isCrouching ? moveSpeed * 0.4 : moveSpeed
        let moving = input.left || input.right

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

        let wantsWalk = moving && !manualAirborne && (isGrounded || abs(body.velocity.dx) > 15)
        if wantsWalk {
            locomotionHold = locomotionHoldDuration
        } else {
            locomotionHold = max(0, locomotionHold - delta)
        }
        let locomoting = wantsWalk || locomotionHold > 0
        if locomoting != wasMoving {
            wasMoving = locomoting
            anim.updateLocomotion(isMoving: locomoting)
        }

        maintainGroundContact()
    }

    func maintainGroundContact() {
        guard !isOnLadder, !manualAirborne, let body = physicsBody else { return }
        let feetY = position.y - bodyHalfH
        guard feetY <= floorTopY + 10 else { return }
        if abs(position.y - standCenterY) > 0.25 {
            position.y = standCenterY
        }
        if isGrounded || abs(body.velocity.dy) < 60 {
            body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
            isGrounded = true
            jumpCount = 0
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
            anim.updateLocomotion(isMoving: abs(body.velocity.dx) > 20)
        } else if body.velocity.dy <= 0 && abs(body.velocity.dy) < 25 {
            manualAirborne = false
            body.collisionBitMask |= PhysicsCategory.ground
            body.affectedByGravity = true
        }
    }

    private func flipSprite(right: Bool) {
        facingRight = right
        anim.setFacingRight(right)
    }

    // MARK: - EMP pulse visual

    func spawnEmpPulseVisual(on scene: SKScene? = nil) {
        let target = scene ?? self.scene
        guard let target else { return }

        let origin = position
        let coreFlash = SKShapeNode(circleOfRadius: 8)
        coreFlash.fillColor = SKColor(white: 0.95, alpha: 0.9)
        coreFlash.strokeColor = SKColor(red: 0.55, green: 0.82, blue: 1.0, alpha: 1)
        coreFlash.lineWidth = 2
        coreFlash.position = origin
        coreFlash.zPosition = 46
        target.addChild(coreFlash)
        coreFlash.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.2, duration: 0.12),
                SKAction.fadeOut(withDuration: 0.12)
            ]),
            SKAction.removeFromParent()
        ]))

        let ringSpecs: [(radius: CGFloat, delay: TimeInterval, lineWidth: CGFloat)] = [
            (28, 0.00, 3.5),
            (56, 0.05, 2.8),
            (92, 0.10, 2.0),
        ]
        for spec in ringSpecs {
            let ring = SKShapeNode(circleOfRadius: spec.radius)
            ring.fillColor = .clear
            ring.strokeColor = SKColor(red: 0.45, green: 0.78, blue: 1.0, alpha: 0.95)
            ring.lineWidth = spec.lineWidth
            ring.glowWidth = 4
            ring.position = origin
            ring.zPosition = 45
            ring.alpha = 0.95
            target.addChild(ring)
            ring.run(SKAction.sequence([
                SKAction.wait(forDuration: spec.delay),
                SKAction.group([
                    SKAction.scale(to: 2.8, duration: 0.28),
                    SKAction.fadeOut(withDuration: 0.28)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }


    func updateStunCooldown(delta: TimeInterval) {
        if stunCooldown > 0 { stunCooldown -= delta }
    }

    var stunCooldownRatio: CGFloat {
        CGFloat(max(0, stunCooldown) / stunCooldownMax)
    }
}
