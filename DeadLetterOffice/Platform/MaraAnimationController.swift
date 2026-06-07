import SpriteKit

/// SpriteKit animation driver for Mara field investigation sprites (Mara.atlas).
final class MaraAnimationController {

    enum State: String, CaseIterable {
        case idlePDAHolstered
        case walkCycle
        case takeOutPDA
        case pdaIdleInHand
        case putAwayPDA
        case scanObserve
        case terminalInteraction
        case hackConnect
        case empActivation

        var prefix: String {
            switch self {
            case .idlePDAHolstered: return "mara_idle_pda_holstered"
            case .walkCycle: return "mara_walk_cycle"
            case .takeOutPDA: return "mara_take_out_pda"
            case .pdaIdleInHand: return "mara_pda_idle_in_hand"
            case .putAwayPDA: return "mara_put_away_pda"
            case .scanObserve: return "mara_scan_observe"
            case .terminalInteraction: return "mara_terminal_interaction"
            case .hackConnect: return "mara_hack_connect"
            case .empActivation: return "mara_emp_activation"
            }
        }

        var frameCount: Int {
            switch self {
            case .idlePDAHolstered: return 6
            case .walkCycle: return 8
            case .takeOutPDA: return 6
            case .pdaIdleInHand: return 4
            case .putAwayPDA: return 4
            case .scanObserve: return 5
            case .terminalInteraction: return 5
            case .hackConnect: return 5
            case .empActivation: return 6
            }
        }

        var isLooping: Bool {
            switch self {
            case .idlePDAHolstered, .walkCycle, .pdaIdleInHand: return true
            default: return false
            }
        }

        var timePerFrame: TimeInterval {
            switch self {
            case .walkCycle: return 0.12
            case .idlePDAHolstered, .pdaIdleInHand: return 0.14
            case .empActivation: return 0.09
            default: return 0.10
            }
        }
    }

    static let displaySize = CGSize(width: 52, height: 78)
    static let feetOffsetY: CGFloat = -31
    /// Idle/PDA-idle art is drawn shorter in the source sheet than walk — scale up to match walk height.
    private static let idleVisualScale: CGFloat = 1.18
    /// Subtle vertical bob per walk frame (contact low, passing high).
    private static let walkBobByFrame: [CGFloat] = [0, 0.5, 2, 1, 0, 0.5, 2, 1]
    private static let animKey = "maraAnim"
    private static var cachedTextures: [State: [SKTexture]] = [:]
    /// Strong refs so atlas textures cannot be collected before render.
    private static var texturePin: [SKTexture] = []
    private static var preloadComplete = false
    private static var missingTextureCount = 0
    private(set) static var usingSilhouetteFallback = false

    static var assetStatusSummary: String {
        if usingSilhouetteFallback { return "silhouette-fallback" }
        let loaded = cachedTextures.values.reduce(0) { $0 + $1.count }
        return "atlas-frames=\(loaded) missing=\(missingTextureCount)"
    }

    private weak var sprite: SKSpriteNode?
    private(set) var pdaVisualOut = false
    private(set) var isWalking = false
    private(set) var isOneShotPlaying = false
    private var currentLoop: State = .idlePDAHolstered

    // MARK: - Preload

    static func preload(completion: @escaping () -> Void) {
        if preloadComplete {
            DispatchQueue.main.async { completion() }
            return
        }

        missingTextureCount = 0
        let atlas = SKTextureAtlas(named: "Mara")
        var finished = false
        var atlasReady = false

        let finalizeOnMain: () -> Void = {
            DispatchQueue.main.async {
                guard !finished else { return }
                finished = true
                texturePin = cachedTextures.values.flatMap { $0 }
                let totalFrames = texturePin.count
                usingSilhouetteFallback = totalFrames == 0
                if usingSilhouetteFallback {
                    NSLog("[DLO MaraAnim] atlas empty — silhouette fallback active")
                    preloadComplete = true
                    NSLog("[DLO MaraAnim] preload done — %@", assetStatusSummary)
                    DispatchQueue.main.async { completion() }
                    return
                }
                SKTexture.preload(texturePin) {
                    DispatchQueue.main.async {
                        preloadComplete = true
                        let walkFrames = cachedTextures[.walkCycle]?.count ?? 0
                        NSLog("[DLO MaraAnim] preload done — %@ walkFrames=%d", assetStatusSummary, walkFrames)
                        completion()
                    }
                }
            }
        }

        let loadFramesOnMain: () -> Void = {
            DispatchQueue.main.async {
                guard !finished else { return }
                for state in State.allCases {
                    cachedTextures[state] = loadFrames(for: state, atlas: atlas)
                }
                finalizeOnMain()
            }
        }

        atlas.preload {
            atlasReady = true
            loadFramesOnMain()
        }

        // Never load frames before atlas.preload completes — avoids background-thread races.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            guard !finished else { return }
            guard !atlasReady else { return }
            NSLog("[DLO MaraAnim] preload timeout — silhouette fallback")
            usingSilhouetteFallback = true
            finished = true
            preloadComplete = true
            completion()
        }
    }

    private static func loadFrames(for state: State, atlas: SKTextureAtlas) -> [SKTexture] {
        var frames: [SKTexture] = []
        for i in 1...state.frameCount {
            let name = String(format: "%@_%02d", state.prefix, i)
            let tex = atlas.textureNamed(name)
            if tex.size().width > 4 {
                tex.filteringMode = .nearest
                frames.append(tex)
            } else {
                missingTextureCount += 1
                NSLog("[DLO MaraAnim] WARNING missing texture: %@", name)
            }
        }
        if frames.isEmpty {
            if let idle = cachedTextures[.idlePDAHolstered]?.first {
                NSLog("[DLO MaraAnim] partial fallback for %@", state.prefix)
                frames = [idle]
            } else {
                let fallbackTex = atlas.textureNamed("mara_idle_pda_holstered_01")
                if fallbackTex.size().width > 4 {
                    fallbackTex.filteringMode = .nearest
                    NSLog("[DLO MaraAnim] idle-frame fallback for %@", state.prefix)
                    frames = [fallbackTex]
                }
            }
        }
        return frames
    }

    // MARK: - Setup

    private static func visualScale(for state: State) -> CGFloat {
        switch state {
        case .idlePDAHolstered, .pdaIdleInHand:
            return idleVisualScale
        default:
            return 1.0
        }
    }

    private static func spriteSize(for state: State) -> CGSize {
        let scale = visualScale(for: state)
        return CGSize(width: displaySize.width * scale, height: displaySize.height * scale)
    }

    func attach(to sprite: SKSpriteNode) {
        self.sprite = sprite
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.position = CGPoint(x: 0, y: Self.feetOffsetY)
        sprite.size = Self.spriteSize(for: .idlePDAHolstered)

        if Self.usingSilhouetteFallback {
            attachSilhouette(to: sprite)
            return
        }
        if let first = Self.cachedTextures[.idlePDAHolstered]?.first {
            sprite.texture = first
        }
        playLoop(.idlePDAHolstered)
    }

    private func attachSilhouette(to sprite: SKSpriteNode) {
        if UIImage(named: "mara_silhouette") != nil {
            sprite.texture = SKTexture(imageNamed: "mara_silhouette")
            sprite.texture?.filteringMode = .nearest
        } else {
            sprite.color = DLOColor.platformSilhouette
            sprite.colorBlendFactor = 1.0
        }
        startSilhouetteBob(on: sprite)
    }

    private func startSilhouetteBob(on sprite: SKSpriteNode) {
        sprite.removeAction(forKey: Self.animKey)
        let bob = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 1.5, duration: 0.12),
            SKAction.moveBy(x: 0, y: -1.5, duration: 0.12)
        ]))
        sprite.run(bob, withKey: Self.animKey)
    }

    func setFacingRight(_ right: Bool) {
        guard let sprite else { return }
        sprite.xScale = right ? 1 : -1
    }

    func applyCrouchScale(_ scaleY: CGFloat) {
        sprite?.yScale = scaleY
    }

    // MARK: - Locomotion

    func updateLocomotion(isMoving: Bool) {
        guard !isOneShotPlaying else { return }
        isWalking = isMoving
        if Self.usingSilhouetteFallback {
            guard let sprite else { return }
            if isMoving {
                startSilhouetteBob(on: sprite)
            } else {
                sprite.removeAction(forKey: Self.animKey)
            }
            return
        }
        if isMoving {
            if currentLoop != .walkCycle { playLoop(.walkCycle) }
        } else {
            let idle: State = pdaVisualOut ? .pdaIdleInHand : .idlePDAHolstered
            if currentLoop != idle { playLoop(idle) }
        }
    }

    // MARK: - PDA carry

    func ensurePDAOut(completion: @escaping () -> Void) {
        if pdaVisualOut {
            completion()
            return
        }
        playOneShot(.takeOutPDA) { [weak self] in
            self?.pdaVisualOut = true
            self?.playLoop(.pdaIdleInHand)
            completion()
        }
    }

    func putAwayPDA(completion: @escaping () -> Void) {
        guard pdaVisualOut else {
            completion()
            return
        }
        playOneShot(.putAwayPDA) { [weak self] in
            self?.pdaVisualOut = false
            self?.playLoop(.idlePDAHolstered)
            completion()
        }
    }

    // MARK: - Action one-shots

    func playScanObserve(completion: @escaping () -> Void) {
        playActionOneShot(.scanObserve, completion: completion)
    }

    func playTerminalInteraction(completion: @escaping () -> Void) {
        playActionOneShot(.terminalInteraction, completion: completion)
    }

    func playHackConnect(completion: @escaping () -> Void) {
        playActionOneShot(.hackConnect, completion: completion)
    }

    func playEMPActivation(onPulseFrame: @escaping () -> Void, completion: @escaping () -> Void) {
        playOneShot(.empActivation, triggerFrameIndex: 3, onTrigger: onPulseFrame) { [weak self] in
            self?.resumeAfterAction()
            completion()
        }
    }

    private func playActionOneShot(_ state: State, completion: @escaping () -> Void) {
        playOneShot(state) { [weak self] in
            self?.resumeAfterAction()
            completion()
        }
    }

    private func resumeAfterAction() {
        let idle: State = pdaVisualOut ? .pdaIdleInHand : .idlePDAHolstered
        playLoop(idle)
    }

    // MARK: - Core playback

    private func playLoop(_ state: State) {
        guard let sprite else { return }
        if Self.usingSilhouetteFallback {
            if isWalking { startSilhouetteBob(on: sprite) }
            return
        }
        guard let frames = Self.cachedTextures[state], !frames.isEmpty else { return }
        isOneShotPlaying = false
        currentLoop = state
        sprite.removeAction(forKey: Self.animKey)
        sprite.size = Self.spriteSize(for: state)
        if state != .walkCycle {
            sprite.position.y = Self.feetOffsetY
        }

        var steps: [SKAction] = []
        for (index, tex) in frames.enumerated() {
            let bob = state == .walkCycle
                ? Self.walkBobByFrame[min(index, Self.walkBobByFrame.count - 1)]
                : 0
            let y = Self.feetOffsetY + bob
            steps.append(SKAction.run { [weak sprite] in
                sprite?.texture = tex
                sprite?.position.y = y
            })
            steps.append(SKAction.wait(forDuration: state.timePerFrame))
        }
        sprite.run(SKAction.repeatForever(SKAction.sequence(steps)), withKey: Self.animKey)
    }

    private func playOneShot(
        _ state: State,
        triggerFrameIndex: Int? = nil,
        onTrigger: (() -> Void)? = nil,
        completion: @escaping () -> Void
    ) {
        guard let sprite else {
            completion()
            return
        }
        if Self.usingSilhouetteFallback {
            completion()
            return
        }
        guard let frames = Self.cachedTextures[state], !frames.isEmpty else {
            NSLog("[DLO MaraAnim] one-shot fallback: %@", state.rawValue)
            completion()
            return
        }
        isOneShotPlaying = true
        isWalking = false
        currentLoop = state
        sprite.removeAction(forKey: Self.animKey)
        sprite.size = Self.spriteSize(for: state)

        var steps: [SKAction] = []
        for (index, tex) in frames.enumerated() {
            steps.append(SKAction.setTexture(tex))
            if index == triggerFrameIndex {
                steps.append(SKAction.run { onTrigger?() })
            }
            steps.append(SKAction.wait(forDuration: state.timePerFrame))
        }
        steps.append(SKAction.run { [weak self] in
            self?.isOneShotPlaying = false
            completion()
        })
        sprite.run(SKAction.sequence(steps), withKey: Self.animKey)
    }
}
