import SpriteKit

/// Animated Worker K. Haas NPC — Chapter 1 field encounter (faces left).
final class WorkerKHaasNode: SKNode {

    enum WorkerKHaasState {
        case idle
        case worried
        case beckon
    }

    private static let atlasName = "K_haas"
    private static let animKey = "kHaasAnim"
    private static var cachedFrames: [WorkerKHaasState: [SKTexture]] = [:]
    private static var texturePin: [SKTexture] = []
    private static var preloadComplete = false
    private static var missingTextureCount = 0

    /// Source art is 128×192 with feet on the canvas bottom; scale to match Mara field height.
    static let displaySize = CGSize(width: 52, height: 78)

    private static let statePrefixes: [WorkerKHaasState: String] = [
        .idle: "k_haas_idle_",
        .worried: "k_haas_worried_",
        .beckon: "k_haas_beckon_",
    ]

    private static let timePerFrame: [WorkerKHaasState: TimeInterval] = [
        .idle: 0.20,
        .worried: 0.165,
        .beckon: 0.135,
    ]

    private let sprite: SKSpriteNode
    private(set) var currentState: WorkerKHaasState = .idle

    init(position worldPosition: CGPoint, displayName: String) {
        sprite = SKSpriteNode()
        super.init()
        self.position = worldPosition
        zPosition = 35
        name = "npc_haas"

        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.position = .zero
        sprite.size = Self.displaySize
        sprite.zPosition = 1
        addChild(sprite)

        Self.ensureTexturesLoaded()
        if let first = Self.cachedFrames[.idle]?.first {
            sprite.texture = first
        }
        playLoop(.idle)

        let indicator = DLOFont.terminalLabel(text: "?", size: 11)
        indicator.fontColor = DLOColor.terminalAmber
        indicator.horizontalAlignmentMode = .center
        indicator.position = CGPoint(x: 0, y: Self.displaySize.height + 8)
        indicator.name = "npc_indicator_haas"
        indicator.zPosition = 2
        addChild(indicator)
        indicator.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.7),
            SKAction.fadeAlpha(to: 1.0, duration: 0.7),
        ])))

        let nameLbl = DLOFont.terminalLabel(text: displayName, size: 7)
        nameLbl.fontColor = DLOColor.dimText
        nameLbl.horizontalAlignmentMode = .center
        nameLbl.position = CGPoint(x: 0, y: Self.displaySize.height + 22)
        nameLbl.zPosition = 2
        addChild(nameLbl)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Texture discovery

    static func preload(completion: (() -> Void)? = nil) {
        ensureTexturesLoaded()
        completion?()
    }

    static var assetStatusSummary: String {
        let loaded = cachedFrames.values.reduce(0) { $0 + $1.count }
        return "k-haas-frames=\(loaded) missing=\(missingTextureCount)"
    }

    private static func ensureTexturesLoaded() {
        guard !preloadComplete else { return }
        missingTextureCount = 0
        cachedFrames.removeAll()

        let atlas = SKTextureAtlas(named: atlasName)
        for (state, prefix) in statePrefixes {
            let frames = discoverFrames(prefix: prefix, atlas: atlas)
            if frames.isEmpty {
                NSLog("[DLO KHaas] WARNING no frames for prefix %@", prefix)
            } else {
                cachedFrames[state] = frames
            }
        }

        texturePin = cachedFrames.values.flatMap { $0 }
        preloadComplete = true
        NSLog("[DLO KHaas] preload done — %@", assetStatusSummary)
    }

    private static func discoverFrames(prefix: String, atlas: SKTextureAtlas) -> [SKTexture] {
        let names = atlas.textureNames
            .filter { $0.hasPrefix(prefix) }
            .sorted { frameIndex($0, prefix: prefix) < frameIndex($1, prefix: prefix) }

        var frames: [SKTexture] = []
        for name in names {
            let tex = atlas.textureNamed(name)
            if tex.size().width > 4 {
                tex.filteringMode = .nearest
                frames.append(tex)
            } else {
                missingTextureCount += 1
                NSLog("[DLO KHaas] WARNING missing texture: %@", name)
            }
        }
        return frames
    }

    private static func frameIndex(_ name: String, prefix: String) -> Int {
        var suffix = String(name.dropFirst(prefix.count))
        if suffix.hasSuffix(".png") { suffix = String(suffix.dropLast(4)) }
        return Int(suffix) ?? Int.max
    }

    // MARK: - Animation

    func setState(_ state: WorkerKHaasState) {
        guard state != currentState else { return }
        currentState = state
        playLoop(state)
    }

    func dimDialogueIndicator() {
        childNode(withName: "npc_indicator_haas")?
            .run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
    }

    private func playLoop(_ state: WorkerKHaasState) {
        guard let frames = Self.cachedFrames[state], !frames.isEmpty else {
            if let fallback = Self.cachedFrames[.idle]?.first {
                sprite.texture = fallback
            }
            return
        }

        sprite.removeAction(forKey: Self.animKey)
        sprite.texture = frames[0]

        guard frames.count > 1 else { return }
        let interval = Self.timePerFrame[state] ?? 0.18
        let anim = SKAction.animate(with: frames, timePerFrame: interval)
        sprite.run(SKAction.repeatForever(anim), withKey: Self.animKey)
    }
}
