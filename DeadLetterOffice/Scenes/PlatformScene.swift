import SpriteKit
import GameplayKit

final class PlatformScene: SKScene, SKPhysicsContactDelegate {

    var levelID: String = "level_ch1"

    private var levelData: LevelData?
    private var mara: MaraPlayerNode?
    private var virtualPad: VirtualPadNode?
    private var cameraNode: SKCameraNode?
    private var isLevelReady = false
    #if DEBUG
    var debugValidationMode = false
    private var debugValidationElapsed: TimeInterval = 0
    private var debugValidationComplete = false
    #endif
    private var patrols: [DroneEnemyNode] = []
    private var securityCameras: [SecurityCameraNode] = []
    private var collectiblePickups: [SKNode] = []
    private var environmentTextNodes: [SKNode] = []

    // Interactable system
    private var interactableData: [String: Interactable] = [:]
    private var interactableNodes: [String: SKNode] = [:]   // id → scene node
    private var doorBarriers: [String: SKSpriteNode] = [:]  // id → blocker sprite
    private var nearbyInteractableID: String?
    private var activePanel: SKNode?
    private var interactButton: InteractButtonNode?
    private var interactWasPressed = false
    private var empWasPressed = false
    private var hackWasPressed = false
    private var nearbyHackableID: String?
    private var hackAttemptCounts: [String: Int] = [:]

    // Level state
    private var isLevelComplete = false
    private var isRestartingAfterCatch = false
    private var overlayNode: SKNode?
    private var loadingOverlay: SKNode?
    private var isModalInputLocked = false
    private var enforcementBoundaryX: CGFloat?
    private var lastBoundaryWarning: TimeInterval = 0

    private var isGameplayInputFrozen: Bool { isModalInputLocked || activePanel != nil }

    private func requireMara() -> MaraPlayerNode? {
        guard isLevelReady, let mara else { return nil }
        return mara
    }

    // MARK: - Scene Entry

    // NPC system
    private var npcDataMap: [String: NPCData] = [:]
    private var npcNodes:   [String: SKNode]  = [:]
    private var npcTalkedTo: Set<String>      = []
    private var nearbyNPCID: String?

    // Pause system
    private var isGamePaused: Bool = false
    private var pauseMenuNode: SKNode?
    private var pauseButtonRect: CGRect = .zero
    private var notebookButtonRect: CGRect = .zero
    private var interactButtonCamRect: CGRect = .zero
    private var panelScrollState: ScrollableReadablePanel.ScrollState?
    private var panelScrollTouch: UITouch?
    private var panelScrollBodyRect = CGRect.zero
    private var isPDAJournalOpen = false
    private var pdaJournalScreen: PDAJournalPanel.Screen = .boot
    private var pdaJournalRegions = PDAJournalPanel.HitRegions()
    private var isRebuildingPDAJournal = false
    private var isRebuildingHUD = false
    private var levelBuildStarted = false

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        physicsWorld.gravity = CGVector(dx: 0, dy: -700)  // tuned for jumpImpulse=285
        physicsWorld.contactDelegate = self
        isLevelReady = false
        installBootstrapCamera()
        showLoadingOverlay()

        guard let raw = LevelData.load(id: levelID) else {
            NSLog("[DLO Platform] FAILED level load: %@", levelID)
            SceneManager.shared.transition(to: .desk(chapterID: "ch1"), from: self)
            return
        }
        let data = raw.composed(screenWidth: size.width)
        beginLevelSetup(with: data)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard isLevelReady, levelBuildStarted, levelData != nil, cameraNode != nil else { return }
        guard size.width > 50, size.height > 50 else { return }
        guard abs(size.width - oldSize.width) > 4 || abs(size.height - oldSize.height) > 4 else { return }
        isLevelReady = false
        rebuildCameraChrome()
        validateAndActivateLevel()
    }

    /// Rebuild HUD + virtual pad together — pauses gameplay until validateAndActivateLevel().
    private func rebuildCameraChrome() {
        buildHUD()
        buildVirtualPad()
    }

    private func installBootstrapCamera() {
        guard cameraNode == nil else { return }
        let cam = SKCameraNode()
        cam.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cam)
        camera = cam
        cameraNode = cam
    }

    private func showLoadingOverlay() {
        loadingOverlay?.removeFromParent()
        let overlay = SKNode()
        overlay.zPosition = 2000
        let label = DLOFont.terminalLabel(text: "LOADING FIELD…", size: 11)
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.6)
        overlay.addChild(label)
        addChild(overlay)
        loadingOverlay = overlay
    }

    private func dismissLoadingOverlay() {
        loadingOverlay?.removeFromParent()
        loadingOverlay = nil
    }

    private func beginLevelSetup(with data: LevelData) {
        levelData = data
        levelBuildStarted = false
        isLevelReady = false
        isRebuildingHUD = false

        let finish: () -> Void = { [weak self] in
            guard let self else { return }
            let runOnMain = {
                guard !self.levelBuildStarted else { return }
                self.levelBuildStarted = true
                self.isLevelReady = false
                self.buildLevel(data)
                self.rebuildCameraChrome()
                self.dismissLoadingOverlay()
                self.validateAndActivateLevel()

                if let track = data.ambientMusicTrack {
                    AudioManager.shared.playMusic(named: track)
                } else {
                    AudioManager.shared.playMusic(named: "ambient_platform")
                }
            }
            if Thread.isMainThread {
                runOnMain()
            } else {
                DispatchQueue.main.async(execute: runOnMain)
            }
        }

        MaraPlayerNode.preloadAnimations(completion: finish)

        // Device atlas preload can stall; never leave the field scene blank.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { [weak self] in
            guard let self, !self.levelBuildStarted else { return }
            NSLog("[DLO MaraAnim] preload timeout — building level anyway")
            finish()
        }
    }

    // MARK: - Level Building

    private func buildLevel(_ data: LevelData) {
        backgroundColor = DLOColor.background

        for layer in data.backgroundLayers {
            addChild(buildBackgroundLayer(layer, levelWidth: data.levelWidth,
                                          levelHeight: data.levelHeight))
        }

        buildFloor(width: data.levelWidth, height: data.levelHeight)
        if data.isInterior == true {
            buildInteriorShell(levelID: data.id, width: data.levelWidth, height: data.levelHeight)
        }
        buildPlatforms(data)
        for building in BuildingNode.makeAll(from: data.buildingNodes ?? []) {
            addChild(building)
        }

        let spawnXY: CGPoint
        if let override = GameState.shared.consumePlatformSpawnOverride(for: levelID) {
            spawnXY = override
        } else {
            spawnXY = CGPoint(x: data.spawnPoint[0], y: data.spawnPoint[1])
        }
        let player = MaraPlayerNode()
        player.position = CGPoint(x: spawnXY.x, y: MaraPlayerNode.defaultStandCenterY)
        player.zPosition = 50
        addChild(player)
        mara = player

        let cam = cameraNode ?? SKCameraNode()
        if cam.parent == nil { addChild(cam) }
        cameraNode = cam
        camera = cam
        let halfW = size.width / 2
        let clampedX = max(halfW, min(spawnXY.x, CGFloat(data.levelWidth) - halfW))
        cam.position = CGPoint(x: clampedX, y: spawnXY.y + size.height * 0.25)
        updateParallaxTileWrapping()

        for inter in data.interactables        { buildInteractable(inter) }
        for patrol in data.patrols             { buildPatrol(patrol) }
        for pickup in data.pickups             { buildPickup(pickup) }
        for envText in data.environmentalTextNodes { buildEnvironmentText(envText) }
        for npc in data.npcs ?? []             { buildNPC(npc) }
        for cam in data.securityCameras ?? []  { buildSecurityCamera(cam) }
        if let boundaryX = data.fieldBoundaryX { buildFieldBoundary(at: boundaryX) }
        FieldEnvironmentDecor.addToScene(self, levelID: levelID, width: data.levelWidth)
    }

    private func validateAndActivateLevel() {
        var issues: [String] = []
        if mara == nil { issues.append("mara") }
        if cameraNode == nil { issues.append("camera") }
        if virtualPad == nil { issues.append("virtualPad") }
        if interactButton == nil { issues.append("interactButton") }
        if overlayNode == nil { issues.append("overlay") }
        if levelData == nil { issues.append("levelData") }
        if issues.isEmpty {
            isLevelReady = true
            NSLog("[DLO Platform] level ready — %@ maraAnim=%@",
                  levelID, MaraAnimationController.assetStatusSummary)
        } else {
            isLevelReady = false
            NSLog("[DLO Platform] BLOCKED level start — missing: %@", issues.joined(separator: ", "))
        }
    }

    private func buildSecurityCamera(_ spec: SecurityCameraSpec) {
        let camera = SecurityCameraNode(spec: spec)
        camera.zPosition = 38
        addChild(camera)
        securityCameras.append(camera)
    }

    // MARK: - Modal input lock

    private func engageModalLock() {
        isModalInputLocked = true
        mara?.haltMovement()
        virtualPad?.resetInput()
        virtualPad?.setInputLocked(true)
        interactWasPressed = true
        empWasPressed = true
        hackWasPressed = true
    }

    private func releaseModalLock() {
        isModalInputLocked = false
        virtualPad?.setInputLocked(false)
        interactWasPressed = false
        empWasPressed = false
        hackWasPressed = false
    }

    // MARK: - Field boundary (security enforcer)

    private func buildFieldBoundary(at x: CGFloat) {
        enforcementBoundaryX = x
        let robot = FieldInvestigationVisuals.enforcementRobot()
        robot.position = CGPoint(x: x, y: 128)
        robot.zPosition = 42
        addChild(robot)

        let wall = SKNode()
        wall.position = CGPoint(x: x + 36, y: 120)
        wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 24, height: 260))
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = PhysicsCategory.ground
        wall.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(wall)

        let sign = DLOFont.terminalLabel(text: "UNAUTHORISED ACCESS ZONE", size: 7)
        sign.fontColor = DLOColor.danger.withAlphaComponent(0.75)
        sign.position = CGPoint(x: x, y: 168)
        sign.zPosition = 41
        addChild(sign)
    }

    private func checkFieldBoundary(_ currentTime: TimeInterval) {
        guard let mara, let boundary = enforcementBoundaryX, !isGameplayInputFrozen else { return }
        if mara.position.x > boundary - 16 {
            mara.haltMovement()
            mara.position.x = boundary - 36
            guard currentTime - lastBoundaryWarning > 2.5 else { return }
            lastBoundaryWarning = currentTime
            showContentPanel(
                header: "SECURITY ENFORCEMENT ROBOT",
                body: """
UNAUTHORISED ACCESS ZONE

Detection immediate.
No stealth bypass.
No EMP bypass.

Return to authorised sector immediately.
"""
            ) { }
        }
    }

    private func buildBackgroundLayer(_ layer: BackgroundLayer,
                                      levelWidth: CGFloat, levelHeight: CGFloat) -> SKNode {
        let node = SKNode()
        node.zPosition = layer.zPosition
        node.name = "bgLayer_\(layer.zPosition)"
        node.userData = NSMutableDictionary()
        node.userData?["scrollFactor"] = Double(layer.scrollFactor)

        if let image = UIImage(named: layer.imageName) {
            let tiles = buildTiledParallaxSprites(
                image: image,
                imageName: layer.imageName,
                levelWidth: levelWidth,
                levelHeight: levelHeight,
                yOffset: layer.yOffset)
            let kind = ParallaxLayerKind.from(imageName: layer.imageName)
            tiles.alpha = kind.layerAlpha
            node.addChild(tiles)
        } else {
            node.addChild(buildProceduralBackground(layer: layer,
                                                    width: levelWidth, height: levelHeight))
        }
        return node
    }

    // MARK: - Parallax blend profiles (full-screen atmospheric stack + seam hiding)

    private enum ParallaxLayerKind {
        case far, mid, near

        static func from(imageName: String) -> ParallaxLayerKind {
            switch imageName {
            case "bg_city_far": return .far
            case "bg_facility_mid": return .mid
            case "bg_facility_near": return .near
            default: return .mid
            }
        }

        /// Soft top feather for near only; far/mid render full-frame underneath.
        var verticalStops: [(CGFloat, CGFloat)] {
            switch self {
            case .far, .mid:
                return [(0, 1), (1, 1)]
            case .near:
                return [(0, 1), (0.32, 1), (0.48, 0.9), (0.60, 0.68), (0.72, 0.42),
                        (0.82, 0.2), (0.91, 0.07), (1, 0)]
            }
        }

        /// Whole-layer alpha for atmospheric stacking (no band partitioning).
        var layerAlpha: CGFloat {
            switch self {
            case .far: return 1
            case .mid: return 0.62
            case .near: return 1
            }
        }

        /// Stagger repeat seams so far/mid/near do not align.
        var phaseFraction: CGFloat {
            switch self {
            case .far: return 0
            case .mid: return 0.34
            case .near: return 0.68
            }
        }

        /// How much of each tile width overlaps its neighbour (crossfade zone).
        var overlapFraction: CGFloat {
            switch self {
            case .far:  return 0.58
            case .mid:  return 0.48
            case .near: return 0.30
            }
        }

        /// Minimum mask alpha at tile edges; fog layers fade to 0 so seams dissolve.
        var horizontalFadeFloor: CGFloat {
            switch self {
            case .far, .mid: return 0
            case .near:       return 0.78
            }
        }

        /// Horizontal fade band as a fraction of tile width (≈ half overlap for fog).
        func horizontalFadeWidth(overlapFraction: CGFloat) -> CGFloat {
            switch self {
            case .far, .mid: return overlapFraction * 0.52
            case .near:      return 0.12
            }
        }
    }

    private func interpolateAlpha(stops: [(CGFloat, CGFloat)], _ t: CGFloat) -> CGFloat {
        guard let first = stops.first, let last = stops.last else { return 1 }
        if t <= first.0 { return first.1 }
        if t >= last.0 { return last.1 }
        for i in 0..<(stops.count - 1) {
            let (t0, a0) = stops[i]
            let (t1, a1) = stops[i + 1]
            if t >= t0 && t <= t1 {
                let u = (t - t0) / max(0.001, t1 - t0)
                return a0 + (a1 - a0) * u
            }
        }
        return last.1
    }

    private func smoothstep(_ t: CGFloat) -> CGFloat {
        let x = max(0, min(1, t))
        return x * x * (3 - 2 * x)
    }

    private func horizontalEdgeFade(xFraction: CGFloat, fade: CGFloat, floor: CGFloat = 1) -> CGFloat {
        if fade <= 0 || floor >= 1 { return 1 }
        if xFraction < fade {
            return floor + (1 - floor) * smoothstep(xFraction / fade)
        }
        if xFraction > 1 - fade {
            return floor + (1 - floor) * smoothstep((1 - xFraction) / fade)
        }
        return 1
    }

    /// Vertical layer blend; horizontal fade crossfades overlapping tiles at repeat boundaries.
    private func makeParallaxBlendMask(size: CGSize,
                                       kind: ParallaxLayerKind,
                                       horizontalFade: CGFloat,
                                       horizontalFloor: CGFloat) -> UIImage {
        let w = max(2, Int(size.width.rounded()))
        let h = max(2, Int(size.height.rounded()))
        let hFade = horizontalFade
        let hFloor: CGFloat = horizontalFade > 0 ? horizontalFloor : 1
        var pixels = [UInt8](repeating: 0, count: w * h * 4)
        for y in 0..<h {
            let bottomFrac = 1 - CGFloat(y) / CGFloat(h - 1)
            let vAlpha = interpolateAlpha(stops: kind.verticalStops, bottomFrac)
            for x in 0..<w {
                let xFrac = CGFloat(x) / CGFloat(w - 1)
                let alpha = vAlpha * horizontalEdgeFade(xFraction: xFrac, fade: hFade, floor: hFloor)
                let a = UInt8(min(255, max(0, alpha * 255)))
                let idx = (y * w + x) * 4
                pixels[idx] = 255
                pixels[idx + 1] = 255
                pixels[idx + 2] = 255
                pixels[idx + 3] = a
            }
        }
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: &pixels,
                                  width: w,
                                  height: h,
                                  bitsPerComponent: 8,
                                  bytesPerRow: w * 4,
                                  space: cs,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cgImage = ctx.makeImage() else {
            return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }

    /// Tiled parallax strip with overlap, blend masks, and a small rolling tile pool.
    private func buildTiledParallaxSprites(image: UIImage,
                                           imageName: String,
                                           levelWidth: CGFloat,
                                           levelHeight: CGFloat,
                                           yOffset: CGFloat) -> SKNode {
        let container = SKNode()
        container.name = "parallaxTiles"

        let kind = ParallaxLayerKind.from(imageName: imageName)
        let texture = SKTexture(image: image)
        texture.filteringMode = kind == .far ? .nearest : .linear

        let texSize = texture.size()
        guard texSize.width > 0, texSize.height > 0 else { return container }
        let targetH = levelHeight
        let scale = targetH / texSize.height
        // Snap width to half-points so linear filtering does not drift subpixel seams.
        let tileW = (texSize.width * scale * 2).rounded() / 2
        let overlap = tileW * kind.overlapFraction
        let stride = tileW - overlap
        let centerY = levelHeight / 2 + yOffset
        // Stagger seam position per layer without leaving uncovered gaps on the left.
        let phaseShift = kind.phaseFraction * stride
        let viewPad = max(size.width, levelWidth * 0.35)
        let coverageMin = -viewPad
        let firstCenterX = coverageMin + tileW * 0.5 + phaseShift
        // Horizontal bleed hides texture-edge sampling gaps at tile joins.
        let bleed: CGFloat = kind == .far ? 6 : 4
        let tileSize = CGSize(width: tileW + bleed, height: targetH)
        let hFade = kind.horizontalFadeWidth(overlapFraction: kind.overlapFraction)

        let maskImage = makeParallaxBlendMask(size: tileSize,
                                              kind: kind,
                                              horizontalFade: hFade,
                                              horizontalFloor: kind.horizontalFadeFloor)
        let maskTexture = SKTexture(image: maskImage)
        maskTexture.filteringMode = .linear

        let tileCount = 11
        for i in 0..<tileCount {
            let sprite = SKSpriteNode(texture: texture)
            sprite.size = tileSize
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            sprite.blendMode = .alpha
            if kind == .far && i % 2 == 1 { sprite.xScale = -1 }

            let mask = SKSpriteNode(texture: maskTexture)
            mask.size = tileSize

            let crop = SKCropNode()
            crop.maskNode = mask
            crop.addChild(sprite)
            let tileX = (firstCenterX + stride * CGFloat(i)).rounded(.toNearestOrEven)
            crop.position = CGPoint(x: tileX, y: centerY)
            crop.name = "parallaxTile"
            container.addChild(crop)
        }

        container.userData = NSMutableDictionary()
        container.userData?["tileWidth"] = Double(tileW)
        container.userData?["tileStride"] = Double(stride)
        return container
    }

    /// Repositions edge tiles to hide horizontal repeat seams during camera scroll.
    private func updateParallaxTileWrapping() {
        guard let camera = cameraNode else { return }
        let viewW = size.width
        let margin: CGFloat = viewW * 0.6

        for layer in children where layer.name?.hasPrefix("bgLayer_") == true {
            guard let container = layer.childNode(withName: "parallaxTiles"),
                  let tileW = container.userData?["tileWidth"] as? Double,
                  let stride = container.userData?["tileStride"] as? Double else { continue }

            let w = CGFloat(tileW)
            let s = CGFloat(stride)
            let localMin = camera.position.x - viewW * 0.5 - margin - layer.position.x
            let localMax = camera.position.x + viewW * 0.5 + margin - layer.position.x

            let tiles = container.children
                .filter { $0.name == "parallaxTile" }
                .sorted { $0.position.x < $1.position.x }
            guard tiles.count > 1 else { continue }

            for tile in tiles {
                if tile.position.x + w * 0.5 < localMin {
                    let maxX = container.children
                        .filter { $0.name == "parallaxTile" }
                        .map(\.position.x).max() ?? tile.position.x
                    tile.position.x = ((maxX + s) * 2).rounded() / 2
                }
            }
            for tile in tiles.reversed() {
                if tile.position.x - w * 0.5 > localMax {
                    let minX = container.children
                        .filter { $0.name == "parallaxTile" }
                        .map(\.position.x).min() ?? tile.position.x
                    tile.position.x = ((minX - s) * 2).rounded() / 2
                }
            }
        }
    }

    private func buildProceduralBackground(layer: BackgroundLayer,
                                           width: CGFloat, height: CGFloat) -> SKNode {
        let container = SKNode()
        let sky = SKSpriteNode(color: DLOColor.background,
                               size: CGSize(width: width, height: height))
        sky.position = CGPoint(x: width / 2, y: height / 2)
        container.addChild(sky)

        for i in 0..<30 {
            let bldgH = CGFloat.random(in: 60...200)
            let bldgW = CGFloat.random(in: 20...60)
            let bldg = SKSpriteNode(color: DLOColor.platformSilhouette,
                                    size: CGSize(width: bldgW, height: bldgH))
            bldg.position = CGPoint(x: CGFloat(i) * (width / 30) + CGFloat.random(in: -10...10),
                                    y: bldgH / 2 + 40)
            bldg.alpha = CGFloat.random(in: 0.4...0.9)
            container.addChild(bldg)
            for _ in 0..<Int.random(in: 2...6) {
                let win = SKSpriteNode(
                    color: Bool.random() ? DLOColor.terminalAmber : DLOColor.teal,
                    size: CGSize(width: 3, height: 4))
                win.position = CGPoint(
                    x: bldg.position.x + CGFloat.random(in: -bldgW/2...bldgW/2),
                    y: CGFloat.random(in: 20...bldgH - 10))
                win.alpha = CGFloat.random(in: 0.3...0.8)
                container.addChild(win)
            }
        }

        for _ in 0..<60 {
            let rain = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.08),
                                    size: CGSize(width: 1, height: CGFloat.random(in: 15...40)))
            rain.position = CGPoint(x: CGFloat.random(in: 0...width),
                                    y: CGFloat.random(in: 0...height))
            container.addChild(rain)
            rain.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: -10, y: -height - 50,
                                duration: Double.random(in: 1.5...3.5)),
                SKAction.moveBy(x: 10, y: height + 100, duration: 0)
            ])))
        }
        return container
    }

    private func buildFloor(width: CGFloat, height: CGFloat) {
        let groundH: CGFloat = 40
        let halfW = width / 2
        let topY = groundH / 2

        let floor = SKNode()
        floor.position = CGPoint(x: width / 2, y: groundH / 2)
        floor.zPosition = 20

        if let image = UIImage(named: "ground_industrial_road_v1") {
            let texture = SKTexture(image: image)
            texture.filteringMode = .linear
            let texSize = texture.size()
            let tileW = texSize.width * (groundH / texSize.height)
            let tileCount = max(1, Int(ceil(width / tileW)))
            for i in 0..<tileCount {
                let tile = SKSpriteNode(texture: texture)
                tile.size = CGSize(width: tileW, height: groundH)
                tile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                tile.position = CGPoint(x: -halfW + tileW * (CGFloat(i) + 0.5), y: 0)
                floor.addChild(tile)
            }
        } else {
            let ground = SKSpriteNode(color: DLOColor.platformSilhouette,
                                      size: CGSize(width: width, height: groundH))
            floor.addChild(ground)
        }

        // One-way top edge — solid rectangle floor trapped Mara inside the collider.
        floor.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -halfW, y: topY),
                                          to:   CGPoint(x:  halfW, y: topY))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.restitution = 0
        floor.physicsBody?.friction = 0
        floor.physicsBody?.categoryBitMask = PhysicsCategory.ground
        floor.physicsBody?.collisionBitMask = PhysicsCategory.player
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(floor)
    }

    private func buildPlatforms(_ data: LevelData) {
        guard let nodes = data.platformNodes, !nodes.isEmpty else { return }
        for node in nodes {
            addPlatform(x: node.x, y: node.y, width: node.width,
                        assetName: node.assetName, visualScale: node.visualScale)
        }
    }

    private struct PlatformAssetProfile {
        let walkSurfaceFromTop: CGFloat
        let defaultVisualScale: CGFloat
        let filtering: SKTextureFilteringMode
    }

    /// Walk-surface alignment and default scale for approved platform art.
    private func platformAssetProfile(for assetName: String) -> PlatformAssetProfile? {
        switch assetName {
        case "platform_gantry_v1":
            return PlatformAssetProfile(walkSurfaceFromTop: 0.11, defaultVisualScale: 1.75, filtering: .linear)
        default:
            return nil
        }
    }

    private func addPlatform(x: CGFloat, y: CGFloat, width: CGFloat,
                             assetName: String? = nil, visualScale: CGFloat? = nil) {
        let platH: CGFloat = 20
        let pHalfW = width / 2
        let pTopY = platH / 2

        let plat = SKNode()
        plat.position = CGPoint(x: x, y: y)
        plat.zPosition = 20

        if let assetName,
           let profile = platformAssetProfile(for: assetName),
           UIImage(named: assetName) != nil {
            let texture = SKTexture(imageNamed: assetName)
            texture.filteringMode = profile.filtering
            let texSize = texture.size()
            let scale = visualScale ?? profile.defaultVisualScale
            let displayW = width * scale
            let displayH = displayW * (texSize.height / texSize.width)
            let anchorY = 1.0 - profile.walkSurfaceFromTop

            let sprite = SKSpriteNode(texture: texture)
            sprite.size = CGSize(width: displayW, height: displayH)
            sprite.anchorPoint = CGPoint(x: 0.5, y: anchorY)
            sprite.position = CGPoint(x: 0, y: pTopY)
            plat.addChild(sprite)
        } else {
            let body = SKSpriteNode(color: DLOColor.platformSilhouette.withAlphaComponent(0.9),
                                    size: CGSize(width: width, height: platH))
            plat.addChild(body)
            let edge = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.5),
                                    size: CGSize(width: width, height: 2))
            edge.position = CGPoint(x: 0, y: 11)
            plat.addChild(edge)
        }

        plat.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -pHalfW, y: pTopY),
                                         to:   CGPoint(x:  pHalfW, y: pTopY))
        plat.physicsBody?.isDynamic = false
        plat.physicsBody?.restitution = 0
        plat.physicsBody?.friction = 0
        plat.physicsBody?.categoryBitMask = PhysicsCategory.ground
        plat.physicsBody?.collisionBitMask = PhysicsCategory.player
        plat.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(plat)
    }

    private func buildInteriorShell(levelID: String, width: CGFloat, height: CGFloat) {
        let floorH: CGFloat = 40
        let wallH = max(120, height - floorH - 20)
        let backMetal = SKColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 1)

        let back = SKSpriteNode(color: backMetal,
                                 size: CGSize(width: width, height: wallH))
        back.position = CGPoint(x: width / 2, y: floorH + wallH / 2)
        back.zPosition = 18
        addChild(back)

        let ceiling = SKSpriteNode(color: SKColor(red: 0.06, green: 0.09, blue: 0.13, alpha: 1),
                                   size: CGSize(width: width, height: 14))
        ceiling.position = CGPoint(x: width / 2, y: floorH + wallH + 6)
        ceiling.zPosition = 18
        addChild(ceiling)

        PlatformInteriorVisuals.decorate(levelID: levelID, width: width, height: height, into: self)

        // Low interior ceiling collider — prevents jumping over doors/barriers.
        let ceilingColliderY = floorH + wallH - 8
        let ceilingCollider = SKNode()
        ceilingCollider.position = CGPoint(x: width / 2, y: ceilingColliderY)
        ceilingCollider.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: 10))
        ceilingCollider.physicsBody?.isDynamic = false
        ceilingCollider.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ceilingCollider.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(ceilingCollider)
        buildInteriorWalls(width: width, height: height)
    }

    private func buildInteriorWalls(width: CGFloat, height: CGFloat) {
        let floorH: CGFloat = 40
        let wallH = height - floorH
        let thickness: CGFloat = 14

        for xPos in [thickness / 2, width - thickness / 2] {
            let wall = SKNode()
            wall.position = CGPoint(x: xPos, y: floorH + wallH / 2)
            wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: thickness, height: wallH))
            wall.physicsBody?.isDynamic = false
            wall.physicsBody?.categoryBitMask = PhysicsCategory.ground
            wall.physicsBody?.collisionBitMask = PhysicsCategory.player
            addChild(wall)
        }
    }

    // MARK: - Interactable Building

    private func buildInteractable(_ inter: Interactable) {
        interactableData[inter.id] = inter

        let pos = CGPoint(x: inter.position[0], y: inter.position[1])

        if inter.type == "building_entrance", let visual = inter.buildingVisual {
            addChild(PlatformBuildingVisuals.build(
                preset: visual.preset, spec: visual, at: pos, screenWidth: size.width
            ))
        }

        if levelData?.isInterior == true,
           let backdrop = PlatformInteriorVisuals.backdrop(for: inter, levelID: levelID) {
            backdrop.position = pos
            addChild(backdrop)
        }

        // Door: physical barrier that blocks movement
        if inter.type == "door" {
            let alreadyOpen = inter.setsFlag.map { GameState.shared.hasFlag($0) } ?? false
            if !alreadyOpen {
                let barrier = buildDoorBarrier(at: pos, visible: true,
                                               tall: levelData?.isInterior == true)
                doorBarriers[inter.id] = barrier
                addChild(barrier)
            }
        }

        // Visual icon node (for proximity detection)
        let node = SKNode()
        node.position = pos
        node.name = "interactable_\(inter.id)"
        node.zPosition = 30

        if inter.type == "information_node" || inter.type == "text_sign" {
            let beaconLabel = inter.nodeLabel ?? informationNodeBeaconLabel(for: inter)
            let beacon = FieldInvestigationVisuals.publicNoticeBoard(label: beaconLabel)
            node.addChild(beacon)
        } else if inter.type == "terminal" {
            node.addChild(FieldInvestigationVisuals.pmcaFieldTerminal())
        } else if inter.type == "cartridge" {
            node.addChild(FieldInvestigationVisuals.dataCacheUnit())
        } else if inter.type == "security_override" {
            node.addChild(FieldInvestigationVisuals.networkAccessNode())
        } else if inter.type == "cabinet" {
            node.addChild(FieldInvestigationVisuals.maintenanceCabinet())
        }

        let (icon, color) = iconAndColor(for: inter.type)
        let sprite = SKLabelNode(text: icon)
        sprite.fontName = "Menlo-Bold"
        sprite.fontSize = 16
        sprite.fontColor = color
        sprite.horizontalAlignmentMode = .center
        sprite.verticalAlignmentMode = .center
        if inter.type == "information_node" || inter.type == "text_sign"
            || inter.type == "cartridge" || inter.type == "security_override"
            || inter.type == "terminal" || inter.type == "cabinet" {
            sprite.alpha = 0
        } else if inter.type == "building_entrance" {
            if inter.buildingVisual != nil {
                sprite.text = "▲"
                sprite.fontSize = 9
                sprite.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.75)
                sprite.position = CGPoint(x: 0, y: 18)
            } else {
                let buildingH = inter.buildingVisual?.resolvedSize(screenWidth: size.width).height ?? 74
                sprite.position = CGPoint(x: 0, y: buildingH * 0.42)
                sprite.fontSize = 12
            }
        } else if inter.type == "terminal", levelData?.isInterior == true {
            sprite.text = "▣"
            sprite.fontSize = 10
            sprite.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.8)
            sprite.position = CGPoint(x: 0, y: 42)
        } else if inter.type == "security_override", levelData?.isInterior == true {
            sprite.text = "PDA"
            sprite.fontSize = 8
            sprite.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 0.9)
            sprite.position = CGPoint(x: 0, y: 44)
        } else if inter.type == "cabinet", levelData?.isInterior == true {
            sprite.text = "▤"
            sprite.fontSize = 10
            sprite.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.8)
            sprite.position = CGPoint(x: 0, y: 38)
        } else if inter.type == "building_exit" {
            sprite.position = CGPoint(x: 0, y: 32)
            sprite.fontSize = 11
        } else if inter.type == "cabinet" {
            sprite.position = CGPoint(x: 0, y: 36)
        } else if inter.type == "ladder" {
            sprite.alpha = 0
        }
        node.addChild(sprite)

        if inter.type == "ladder", let extent = inter.ladderExtent, extent.count >= 2 {
            let bottomY = extent[0]
            let topY = extent[1]
            let railH = topY - bottomY
            let rail = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.35),
                                    size: CGSize(width: 6, height: railH))
            rail.position = CGPoint(x: 0, y: (bottomY + topY) / 2 - pos.y)
            node.addChild(rail)
            let rungCount = max(3, Int(railH / 18))
            for i in 0..<rungCount {
                let t = CGFloat(i) / CGFloat(rungCount - 1)
                let rungY = bottomY + t * railH - pos.y
                let rung = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.45),
                                        size: CGSize(width: 14, height: 2))
                rung.position = CGPoint(x: 0, y: rungY)
                node.addChild(rung)
            }
        }

        if inter.type != "text_sign" && inter.type != "information_node"
            && inter.type != "building_exit" && inter.type != "ladder" {
            sprite.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 1.2),
                SKAction.fadeAlpha(to: 1.0, duration: 1.2)
            ])))
        }

        // Physics proximity sensor
        let sensorSize: CGSize
        if inter.type == "ladder", let extent = inter.ladderExtent, extent.count >= 2 {
            let ladderH = max(80, extent[1] - extent[0] + 20)
            sensorSize = CGSize(width: 72, height: ladderH)
        } else if inter.type == "security_override" {
            sensorSize = CGSize(width: 64, height: 80)
        } else if inter.type == "door", inter.requiredCode != nil {
            sensorSize = CGSize(width: 64, height: 80)
        } else {
            sensorSize = CGSize(width: 48, height: 72)
        }
        let body = SKPhysicsBody(rectangleOf: sensorSize)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.interactable
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        node.physicsBody = body
        node.userData = NSMutableDictionary()
        node.userData?["interactableID"] = inter.id

        addChild(node)
        interactableNodes[inter.id] = node

    }

    private func buildDoorBarrier(at pos: CGPoint, visible: Bool = true,
                                  tall: Bool = false) -> SKSpriteNode {
        let barrierH: CGFloat = tall ? 260 : 200
        let barrier = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.8),
                                   size: CGSize(width: 16, height: barrierH))
        // Centre the barrier so it sits on the floor (floor top ≈ y=40)
        barrier.position = CGPoint(x: pos.x, y: 40 + barrierH / 2)
        barrier.zPosition = 22
        barrier.alpha = visible ? 1 : 0

        barrier.physicsBody = SKPhysicsBody(rectangleOf: barrier.size)
        barrier.physicsBody?.isDynamic = false
        barrier.physicsBody?.categoryBitMask = PhysicsCategory.ground
        barrier.physicsBody?.collisionBitMask = PhysicsCategory.player

        if visible {
            let edge = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.45),
                                    size: CGSize(width: 3, height: barrierH))
            edge.position = CGPoint(x: -6.5, y: 0)
            barrier.addChild(edge)
        }

        return barrier
    }

    private func iconAndColor(for type: String) -> (String, SKColor) {
        switch type {
        case "terminal":           return ("▣", DLOColor.teal)
        case "door":               return ("▪", DLOColor.terminalAmber)
        case "cartridge":          return ("◈", DLOColor.terminalGreen)
        case "cabinet":            return ("▤", DLOColor.terminalAmber)
        case "building_entrance":  return ("⌂", DLOColor.teal)
        case "building_exit":      return ("⇐", DLOColor.dimText)
        case "information_node":   return ("▣", DLOColor.teal)
        case "text_sign":          return ("ℹ", DLOColor.dimText)
        case "security_override":  return ("⚡", DLOColor.terminalAmber)
        case "ladder":             return ("║", DLOColor.teal)
        default:                   return ("?", DLOColor.dimText)
        }
    }

    private func buildPatrol(_ patrol: PatrolRoute) {
        let drone = DroneEnemyNode(
            patrolPoints: patrol.points.map { CGPoint(x: $0[0], y: $0[1]) },
            speed: patrol.speed,
            pauseDuration: patrol.pauseDuration,
            isGuard: patrol.enemyType == "security_guard")
        drone.zPosition = 40
        addChild(drone)
        patrols.append(drone)
    }

    private func buildPickup(_ pickup: [String: String]) {
        guard let x = Double(pickup["x"] ?? "0"),
              let y = Double(pickup["y"] ?? "0") else { return }
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        node.zPosition = 30
        node.name = "pickup_\(pickup["id"] ?? "unknown")"

        let pickupVisual = FieldInvestigationVisuals.dataCartridgePedestal()
        node.addChild(pickupVisual)

        let body = SKPhysicsBody(circleOfRadius: 12)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.pickup
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        node.physicsBody = body
        node.userData = NSMutableDictionary()
        if let flag = pickup["setsFlag"] { node.userData?["setsFlag"] = flag }
        addChild(node)
        collectiblePickups.append(node)
    }

    private func buildEnvironmentText(_ data: [String: String]) {
        guard let x = Double(data["x"] ?? "0"), let y = Double(data["y"] ?? "0"),
              let text = data["text"] else { return }
        let label = SKLabelNode(text: text)
        label.fontName = "Menlo"
        label.fontSize = 9
        label.fontColor = DLOColor.uiBorder.withAlphaComponent(0.7)
        label.position = CGPoint(x: x, y: y)
        label.zPosition = 25
        addChild(label)
    }

    // MARK: - NPC Building

    private func buildNPC(_ npc: NPCData) {
        npcDataMap[npc.id] = npc
        let floorTopY: CGFloat = 40

        let node: SKNode
        if npc.id == "haas" {
            WorkerKHaasNode.preload()
            node = WorkerKHaasNode(
                position: CGPoint(x: npc.position[0], y: floorTopY),
                displayName: npc.displayName)
        } else {
            node = buildPlaceholderNPC(npc, floorY: floorTopY)
        }

        addChild(node)
        npcNodes[npc.id] = node
    }

    private func buildPlaceholderNPC(_ npc: NPCData, floorY: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: npc.position[0], y: floorY)
        node.zPosition = 35
        node.name = "npc_\(npc.id)"

        let coatColor = SKColor(red: 0.16, green: 0.18, blue: 0.24, alpha: 1)

        let legs = SKSpriteNode(color: coatColor, size: CGSize(width: 14, height: 18))
        legs.position = CGPoint(x: 0, y: 9)
        node.addChild(legs)

        let torso = SKSpriteNode(color: coatColor, size: CGSize(width: 18, height: 20))
        torso.position = CGPoint(x: 0, y: 29)
        node.addChild(torso)

        let head = SKShapeNode(circleOfRadius: 7)
        head.fillColor = coatColor
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 46)
        node.addChild(head)

        let indicator = DLOFont.terminalLabel(text: "?", size: 11)
        indicator.fontColor = DLOColor.terminalAmber
        indicator.horizontalAlignmentMode = .center
        indicator.position = CGPoint(x: 0, y: 60)
        indicator.name = "npc_indicator_\(npc.id)"
        node.addChild(indicator)
        indicator.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.7),
            SKAction.fadeAlpha(to: 1.0, duration: 0.7)
        ])))

        let nameLbl = DLOFont.terminalLabel(text: npc.displayName, size: 7)
        nameLbl.fontColor = DLOColor.dimText
        nameLbl.horizontalAlignmentMode = .center
        nameLbl.position = CGPoint(x: 0, y: 73)
        node.addChild(nameLbl)

        return node
    }

    private func updateNPCHaasPresentation(nearbyID: String?) {
        guard activePanel == nil else { return }
        for (id, node) in npcNodes {
            guard let haas = node as? WorkerKHaasNode else { continue }
            haas.setState(nearbyID == id ? .beckon : .idle)
        }
    }

    // MARK: - Ladder Proximity (distance-based — more reliable than physics alone)

    private func checkLadderProximity() {
        guard let mara, let interactButton else { return }
        guard !mara.isOnLadder else {
            if nearbyInteractableID != nil {
                interactButton.configure(for: "ladder_active")
            }
            return
        }

        let xRange: CGFloat = 54
        var bestID: String?
        var bestScore: CGFloat = .infinity

        for (id, inter) in interactableData where inter.type == "ladder" {
            guard let extent = inter.ladderExtent, extent.count >= 2 else { continue }
            let railX = inter.position[0]
            let bottomY = extent[0]
            let topY = extent[1]
            let dx = abs(mara.position.x - railX)
            guard dx <= xRange else { continue }
            guard mara.position.y >= bottomY - 14, mara.position.y <= topY + 18 else { continue }
            let score = dx + abs(mara.position.y - bottomY) * 0.35
            if score < bestScore {
                bestScore = score
                bestID = id
            }
        }

        if let bestID {
            if nearbyInteractableID != bestID {
                nearbyInteractableID = bestID
                nearbyNPCID = nil
                interactButton.configure(for: "ladder")
                interactButton.run(SKAction.fadeIn(withDuration: 0.15))
            }
        } else if let current = nearbyInteractableID,
                  interactableData[current]?.type == "ladder" {
            nearbyInteractableID = nil
            if nearbyNPCID == nil && !isGameplayInputFrozen {
                interactButton.run(SKAction.fadeOut(withDuration: 0.15))
            }
        }
    }

    // MARK: - NPC Proximity (distance-based, called every frame)

    private func checkNPCProximity() {
        guard let mara, let interactButton else { return }
        let range: CGFloat = 75
        var closestID: String? = nil
        var closestDist: CGFloat = .infinity

        for (id, node) in npcNodes {
            let d = mara.position.distance(to: node.position)
            if d < range && d < closestDist {
                closestDist = d
                closestID = id
            }
        }

        if closestID != nearbyNPCID {
            nearbyNPCID = closestID

            // Only touch the button if no interactable is already claiming it
            if nearbyInteractableID == nil {
                if nearbyNPCID != nil {
                    interactButton.configure(for: "npc")
                    interactButton.run(SKAction.fadeIn(withDuration: 0.2))
                } else {
                    interactButton.run(SKAction.fadeOut(withDuration: 0.15))
                }
            }
        }
        updateNPCHaasPresentation(nearbyID: closestID)
    }

    // MARK: - NPC Activation

    private func activateNPC(id: String) {
        guard let mara = requireMara(), let npc = npcDataMap[id] else { return }

        let alreadyTalked = npcTalkedTo.contains(id)
        let repeatable = npc.repeatable ?? false

        if alreadyTalked && !repeatable {
            showBriefMessage("...")
            return
        }

        npcTalkedTo.insert(id)
        (npcNodes[id] as? WorkerKHaasNode)?.setState(.worried)

        mara.playScanObserve { [weak self] in
            guard let self else { return }
            if let flag = npc.setsFlag {
                GameState.shared.setFlag(flag)
            }
            if id == "haas" { NotebookManager.onHaasTalked() }
            NotebookManager.onNPCTalked(npcID: id)
            self.notifyPDAIfUpdated()

            let body = npc.dialogue.joined(separator: "\n\n")
            self.showContentPanel(header: npc.displayName.uppercased(), body: body) {
                if let haas = self.npcNodes[id] as? WorkerKHaasNode {
                    haas.dimDialogueIndicator()
                    haas.setState(self.nearbyNPCID == id ? .beckon : .idle)
                } else if let indicator = self.npcNodes[id]?.childNode(withName: "npc_indicator_\(id)") {
                    indicator.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
                }
            }
        }
    }

    // MARK: - HUD

    private func buildHUD() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.buildHUD() }
            return
        }
        guard !isRebuildingHUD else { return }
        guard let camNode = cameraNode, camNode.parent != nil else {
            NSLog("[DLO Platform] buildHUD aborted — cameraNode nil or detached")
            return
        }
        guard size.width > 1, size.height > 1 else {
            NSLog("[DLO Platform] buildHUD aborted — invalid scene size %@", NSCoder.string(for: size))
            return
        }

        isRebuildingHUD = true
        defer { isRebuildingHUD = false }

        interactButton = nil
        overlayNode?.removeFromParent()
        overlayNode = nil

        let overlay = SKNode()
        overlay.zPosition = 1000

        let cam = SceneLayout.makeCamera(scene: self)

        let ib = InteractButtonNode()
        ib.alpha = 0
        ib.zPosition = 1100
        overlay.addChild(ib)
        interactButton = ib

        let textMult = GameState.shared.textSizeMultiplier

        // ── Subtle shift header — detailed guidance lives in PDA journal ──
        if let obj = levelData?.objectiveText {
            let objBacking = SKSpriteNode(
                color: DLOColor.terminalBG.withAlphaComponent(0.55),
                size: CGSize(width: cam.w * 0.38, height: 26))
            objBacking.anchorPoint = CGPoint(x: 0, y: 1)
            objBacking.position   = CGPoint(x: cam.left, y: cam.top)
            objBacking.zPosition  = 1049
            overlay.addChild(objBacking)

            let objLbl = DLOFont.terminalLabel(text: obj, size: 9.5 * textMult)
            objLbl.horizontalAlignmentMode = .left
            objLbl.verticalAlignmentMode   = .top
            objLbl.position = CGPoint(x: cam.left + 8, y: cam.top - 6)
            objLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.75)
            objLbl.zPosition = 1050
            overlay.addChild(objLbl)
        }

        // ── Pause / Menu button — top-right ──────────────────────────────────
        let pauseW: CGFloat = 88
        let pauseH: CGFloat = 36
        let pauseCX = cam.right - pauseW / 2 - 8
        let pauseCY = cam.top - pauseH / 2 - 8

        let pauseBG = SKShapeNode(rectOf: CGSize(width: pauseW, height: pauseH), cornerRadius: 5)
        pauseBG.fillColor  = DLOColor.terminalBG.withAlphaComponent(0.85)
        pauseBG.strokeColor = DLOColor.uiBorder
        pauseBG.lineWidth   = 1.2
        pauseBG.position    = CGPoint(x: pauseCX, y: pauseCY)
        pauseBG.zPosition   = 1050
        overlay.addChild(pauseBG)

        let pauseLbl = DLOFont.terminalLabel(text: "MENU", size: 11)
        pauseLbl.horizontalAlignmentMode = .center
        pauseLbl.position  = CGPoint(x: pauseCX, y: pauseCY - 4)
        pauseLbl.zPosition = 1051
        overlay.addChild(pauseLbl)

        // ── PDA / Notes button — top-right, left of MENU ────────────────────
        let notesW: CGFloat = 72
        let notesH: CGFloat = 36
        let notesCX = cam.right - pauseW - notesW / 2 - 16
        let notesCY = pauseCY

        let notesBG = SKShapeNode(rectOf: CGSize(width: notesW, height: notesH), cornerRadius: 5)
        notesBG.fillColor  = DLOColor.terminalBG.withAlphaComponent(0.85)
        notesBG.strokeColor = SKColor(red: 0.38, green: 0.48, blue: 0.42, alpha: 0.8)
        notesBG.lineWidth   = 1.2
        notesBG.position    = CGPoint(x: notesCX, y: notesCY)
        notesBG.zPosition   = 1050
        overlay.addChild(notesBG)

        let notesLbl = DLOFont.terminalLabel(text: "PDA", size: 10 * textMult)
        notesLbl.horizontalAlignmentMode = .center
        notesLbl.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 1)
        notesLbl.position  = CGPoint(x: notesCX, y: notesCY - 4)
        notesLbl.zPosition = 1051
        overlay.addChild(notesLbl)

        notebookButtonRect = CGRect(
            x: cam.right - pauseW - notesW - 16, y: cam.top - notesH - 8,
            width: notesW, height: notesH)

        pauseButtonRect = CGRect(
            x: cam.right - pauseW - 8, y: cam.top - pauseH - 8,
            width: pauseW, height: pauseH)

        camNode.addChild(overlay)
        overlayNode = overlay
        NSLog("[DLO Platform] buildHUD ok — overlay children=%d", overlay.children.count)
    }

    private func buildVirtualPad() {
        guard let camNode = cameraNode, camNode.parent != nil else {
            NSLog("[DLO Platform] buildVirtualPad skipped — no camera")
            return
        }
        virtualPad?.removeFromParent()
        virtualPad = nil

        let cam = SceneLayout.makeCamera(scene: self)
        let pad = VirtualPadNode()
        pad.position = CGPoint(x: cam.left, y: cam.bottom)
        pad.zPosition = 500
        camNode.addChild(pad)
        pad.configure(screenWidth: cam.w, screenHeight: cam.h)
        pad.layoutRightCluster(x: cam.w - 175)
        virtualPad = pad
    }

    // MARK: - Game Loop

    private var lastUpdateTime: TimeInterval = 0

    override func didSimulatePhysics() {
        guard isLevelReady, let mara else { return }
        mara.finishAirbornePhysicsStep()
    }

    override func update(_ currentTime: TimeInterval) {
        guard isLevelReady, !isRebuildingHUD else { return }
        guard mara != nil, virtualPad != nil, cameraNode != nil, interactButton != nil else { return }
        guard !isGamePaused else { return }
        let delta = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 1.0 / 60.0
        lastUpdateTime = currentTime
        updateMara(delta: delta)
        updateCamera()
        #if DEBUG
        runDebugValidation(delta: delta)
        #endif
        if !isGameplayInputFrozen {
            updateDrones(currentTime)
            updateSecurityCameras(delta: delta)
            checkSecurityCameras()
            checkExits()
            checkFieldBoundary(currentTime)
        }
    }

    #if DEBUG
    private func runDebugValidation(delta: TimeInterval) {
        guard debugValidationMode, let mara else { return }
        debugValidationElapsed += delta
        if debugValidationElapsed >= 1.0, !debugValidationComplete {
            debugValidationComplete = true
            NSLog("[DLO Validate] platform stable @%.1fs — %@", debugValidationElapsed,
                  MaraAnimationController.assetStatusSummary)
        }
        guard debugValidationElapsed < 10.0 else { return }
        let phase = Int(debugValidationElapsed) % 4
        var input = VirtualPadNode.Input()
        input.right = phase == 0 || phase == 1
        input.left = phase == 2 || phase == 3
        mara.applyInput(input, delta: delta)
    }
    #endif

    private func updateSecurityCameras(delta: TimeInterval) {
        for camera in securityCameras { camera.update(delta: delta) }
    }

    private func checkSecurityCameras() {
        guard let mara, !mara.isCrouching, !mara.isHiding else { return }
        for camera in securityCameras where camera.canSee(target: mara.position) {
            maraCaught()
            return
        }
    }

    private func informationNodeBeaconLabel(for inter: Interactable) -> String {
        if let label = inter.nodeLabel { return label }
        switch inter.id {
        case let id where id.contains("sign"), let id where id.contains("notice"): return "NOTICE"
        case let id where id.contains("relay"): return "RELAY"
        default: return "NOTICE"
        }
    }

    private func informationNodePrompt(for inter: Interactable) -> String {
        switch inter.nodeLabel ?? inter.id {
        case "FILE", "cartridge_choir_list", "cartridge_kell_orvin": return "COLLECT FILE"
        case "RELAY", "sign_tier2": return "CHECK UPLINK"
        case "NOTICE", "sign_tier1", "sign_tier3", "sign_housing": return "READ NOTICE"
        case "sign_exit", "sign_pa": return "READ NOTICE"
        default:
            if inter.displayText?.contains("UPLINK") == true { return "CHECK UPLINK" }
            return "READ NOTICE"
        }
    }

    private func promptForInteractable(_ inter: Interactable) -> String? {
        switch inter.type {
        case "information_node", "text_sign": return informationNodePrompt(for: inter)
        case "cartridge": return "COLLECT FILE"
        case "terminal": return "READ TERMINAL"
        case "door": return inter.requiredCode != nil ? "ENTER CODE" : "OPEN DOOR"
        case "security_override": return "CONNECT PDA"
        case "cabinet": return "OPEN LOCKER"
        case "building_entrance": return "ENTER"
        case "building_exit": return "EXIT"
        default: return nil
        }
    }

    private func updateMara(delta: TimeInterval) {
        guard let mara = mara, let pad = virtualPad else { return }

        if !isGameplayInputFrozen {
            if mara.isOnLadder {
                mara.applyLadderInput(pad.currentInput, delta: delta)
            } else {
                mara.applyInput(pad.currentInput, delta: delta)
                tryEnterNearbyLadder(pad: pad)
            }
        } else {
            mara.haltMovement()
        }

        if let data = levelData, data.isInterior == true, !mara.isOnLadder {
            let margin: CGFloat = 24
            mara.position.x = max(margin, min(data.levelWidth - margin, mara.position.x))
        }

        mara.updateStunCooldown(delta: delta)

        // Edge-detect interact button press (right cluster)
        let interactNow = pad.currentInput.interact
        if interactNow && !interactWasPressed && !isGameplayInputFrozen && !mara.isActionAnimating {
            activateNearbyInteractable()
        }
        interactWasPressed = interactNow

        let empNow = pad.currentInput.emp
        if empNow && !empWasPressed && !isGameplayInputFrozen && !mara.isActionAnimating {
            if mara.canFireEMP {
                mara.playEMPActivation(onPulse: { [weak self] in
                    guard let self, let mara = self.mara else { return }
                    mara.spawnEmpPulseVisual(on: self)
                    self.applyEmpPulseToNearbyDrones()
                })
            }
        }
        empWasPressed = empNow

        let hackNow = pad.currentInput.hack
        if hackNow && !hackWasPressed && !isGameplayInputFrozen && !mara.isActionAnimating {
            attemptContextualHack()
        }
        hackWasPressed = hackNow

        let interactAvailable = !isGameplayInputFrozen
            && (nearbyInteractableID != nil || nearbyNPCID != nil || mara.isOnLadder)
        pad.setInteractHighlight(interactAvailable)
        pad.setEmpCooldown(ratio: mara.stunCooldownRatio)

        if !isGameplayInputFrozen {
            checkLadderProximity()
            updateHackableProximity()
            let isLadderNearby = nearbyInteractableID.flatMap { interactableData[$0]?.type } == "ladder"
            if !isLadderNearby { checkNPCProximity() }
        } else {
            pad.setHackHighlight(false)
        }

        guard let camera = cameraNode, let interactButton else { return }
        let ibCenter = CGPoint(
            x: mara.position.x - camera.position.x,
            y: mara.position.y - camera.position.y + 52)
        interactButton.position = ibCenter
        interactButtonCamRect = CGRect(x: ibCenter.x - 65, y: ibCenter.y - 15, width: 130, height: 30)
    }

    private func updateCamera() {
        guard isLevelReady, !isRebuildingHUD else { return }
        guard let mara, let camera = cameraNode, camera.parent != nil, let data = levelData else { return }
        let targetX = max(size.width / 2,
                          min(mara.position.x, data.levelWidth - size.width / 2))
        let targetY = max(size.height / 2,
                          min(mara.position.y + 80, data.levelHeight - size.height / 2))
        let smoothed = CGPoint(
            x: camera.position.x + (targetX - camera.position.x) * 0.08,
            y: camera.position.y + (targetY - camera.position.y) * 0.08)
        camera.position = smoothed

        children
            .compactMap { $0.name?.hasPrefix("bgLayer_") == true ? $0 : nil }
            .forEach { layer in
                let factor = CGFloat(layer.userData?["scrollFactor"] as? Double ?? 0)
                layer.position.x = -camera.position.x * factor
            }
        updateParallaxTileWrapping()
    }

    private func updateDrones(_ currentTime: TimeInterval) {
        guard let mara = requireMara() else { return }
        for drone in patrols {
            drone.update(currentTime: currentTime)
            guard !drone.isStunned else { continue }
            if !mara.isCrouching && !mara.isHiding,
               drone.canSee(target: mara.position) {
                maraCaught()
                return
            }
        }
    }

    private func checkExits() {
        guard let mara = requireMara(), let data = levelData, !isLevelComplete else { return }
        for exit in data.exits {
            guard let xStr = exit["x"], let yStr = exit["y"],
                  let x = Double(xStr), let y = Double(yStr) else { continue }

            if exit["type"] == "platform_end" {
                if let req = exit["requiredFlag"], !GameState.shared.hasFlag(req) { continue }
                if mara.position.distance(to: CGPoint(x: x, y: y)) < 100 {
                    if let dialogueID = exit["dialogueID"] {
                        completePlatformSection(dialogueID: dialogueID)
                    } else {
                        levelComplete()
                    }
                    break
                }
                continue
            }

            // Skip exit if player has a flag that disqualifies it (reserved for flag-holders who use a deeper exit)
            if let absentFlag = exit["requiredFlagAbsent"],
               GameState.shared.hasFlag(absentFlag) { continue }
            if mara.position.distance(to: CGPoint(x: x, y: y)) < 80 {
                levelComplete()
                break
            }
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard isLevelReady, let interactButton else { return }
        // Player + Pickup
        if let (_, b) = contact.bodies(catA: PhysicsCategory.player,
                                        catB: PhysicsCategory.pickup) {
            collectPickup(b.node)
        }
        // Player + Interactable proximity
        if let (_, b) = contact.bodies(catA: PhysicsCategory.player,
                                        catB: PhysicsCategory.interactable) {
            if let node = b.node,
               let id = node.userData?["interactableID"] as? String,
               let inter = interactableData[id] {
                nearbyInteractableID = id
                interactButton.configure(for: inter.type, prompt: promptForInteractable(inter))
                interactButton.run(SKAction.fadeIn(withDuration: 0.2))
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        guard isLevelReady, let interactButton else { return }
        // Player + Interactable
        if let (_, b) = contact.bodies(catA: PhysicsCategory.player,
                                        catB: PhysicsCategory.interactable) {
            if let node = b.node,
               let id = node.userData?["interactableID"] as? String,
               id == nearbyInteractableID,
               activePanel == nil {
                nearbyInteractableID = nil
                interactButton.run(SKAction.fadeOut(withDuration: 0.15))
            }
        }
    }

    private func collectPickup(_ node: SKNode?) {
        guard let node = node else { return }
        if let flag = node.userData?["setsFlag"] as? String {
            GameState.shared.setFlag(flag)
        }
        node.removeFromParent()
        AudioManager.shared.playTerminalBeep(on: self)
    }

    // MARK: - Interactable Activation

    private func isHackableInteractable(_ inter: Interactable, id: String) -> Bool {
        inter.type == "security_override"
            || inter.hackPuzzleID != nil
            || HackingSystem.shared.configForInteractable(id) != nil
    }

    private func securityOverride(linkedToDoorID doorID: String) -> Interactable? {
        interactableData.values.first {
            $0.type == "security_override" && $0.linkedInteractableID == doorID
        }
    }

    /// Distance-based hack targeting — independent of which interactable E-button claims.
    private func findNearbyHackTarget() -> Interactable? {
        guard let mara = requireMara() else { return nil }
        let overrideRange: CGFloat = 100
        let doorHackZoneRange: CGFloat = 130
        var best: (CGFloat, Interactable)?

        for (id, node) in interactableNodes {
            guard let inter = interactableData[id],
                  isHackableInteractable(inter, id: id) else { continue }
            let dist = mara.position.distance(to: node.position)
            if dist < overrideRange, best == nil || dist < best!.0 {
                best = (dist, inter)
            }
        }

        // Coded doors share a hack zone with their linked PDA override port.
        for (doorID, doorNode) in interactableNodes {
            guard let door = interactableData[doorID],
                  door.type == "door",
                  door.requiredCode != nil,
                  let override = securityOverride(linkedToDoorID: doorID) else { continue }
            let doorDist = mara.position.distance(to: doorNode.position)
            guard doorDist < doorHackZoneRange else { continue }
            if let overrideNode = interactableNodes[override.id] {
                let score = min(doorDist, mara.position.distance(to: overrideNode.position))
                if best == nil || score < best!.0 {
                    best = (score, override)
                }
            } else if best == nil || doorDist < best!.0 {
                best = (doorDist, override)
            }
        }

        return best?.1
    }

    private func updateHackableProximity() {
        guard let virtualPad else { return }
        if let target = findNearbyHackTarget() {
            nearbyHackableID = target.id
            virtualPad.setHackHighlight(true)
            virtualPad.setHackLabel("HACK")
        } else {
            nearbyHackableID = nil
            virtualPad.setHackHighlight(false)
            virtualPad.setHackLabel("PDA")
        }
    }

    private func attemptContextualHack() {
        guard let mara = requireMara() else { return }
        guard let inter = findNearbyHackTarget() else {
            showBriefMessage("PDA — NO SYSTEM IN RANGE")
            return
        }

        let requiredFlag = inter.requiredFlag
            ?? inter.hackPuzzleID.flatMap { HackingSystem.shared.config(for: $0)?.requiredFlag }
            ?? HackingSystem.shared.configForInteractable(inter.id)?.requiredFlag

        if let req = requiredFlag, !GameState.shared.hasFlag(req) {
            if req == "ch1_relay_credential" {
                showBriefMessage("PDA DENIED — RELAY CREDENTIAL NOT LOGGED")
            } else {
                showBriefMessage(accessDeniedText(for: inter, requiredFlag: req))
            }
            return
        }

        mara.playHackConnect { [weak self] in
            self?.launchPDAHack(for: inter)
        }
    }

    private func launchPDAHack(for inter: Interactable) {
        let config = inter.hackPuzzleID.flatMap { HackingSystem.shared.config(for: $0) }
            ?? HackingSystem.shared.configForInteractable(inter.id)

        guard let config else {
            if inter.type == "security_override" {
                activateSecurityOverride(inter)
            } else {
                showBriefMessage("PDA — NO EXPLOIT REGISTERED")
            }
            return
        }
        if let req = config.requiredFlag, !GameState.shared.hasFlag(req) {
            showBriefMessage("PDA DENIED — RELAY CREDENTIAL NOT LOGGED")
            return
        }
        if let flag = config.setsFlagOnSuccess, GameState.shared.hasFlag(flag) {
            showBriefMessage("PDA — OVERRIDE ALREADY LOGGED")
            return
        }
        guard activePanel == nil else { return }
        engageModalLock()

        let cam = SceneLayout.makeCamera(scene: self)
        let panelH = config.puzzleType == .credentialInjection ? cam.h * 0.74 : cam.h * 0.62
        let panelSize = CGSize(width: cam.w * 0.78, height: panelH)
        let panel = PDAHackPanel.present(
            config: config,
            panelSize: panelSize,
            textMultiplier: GameState.shared.textSizeMultiplier,
            unlockedPDATags: PDAJournalManager.unlockedPDATags(),
            onResult: { [weak self] result in
                self?.handleHackPuzzleResult(result, config: config, interactable: inter)
            })
        panel.zPosition = 2500
        activePanel = panel
        cameraNode?.addChild(panel)
    }

    private func handleHackPuzzleResult(_ result: HackPuzzleResult,
                                        config: HackPuzzleConfig,
                                        interactable: Interactable) {
        switch result {
        case .success:
            hackAttemptCounts[config.id] = 0
            completePDAHack(config: config, interactable: interactable)
        case .cancelled:
            dismissActivePanel()
        case .failed(let reason):
            let attempts = (hackAttemptCounts[config.id] ?? 0) + 1
            hackAttemptCounts[config.id] = attempts
            dismissActivePanel()
            if attempts >= config.maxAttempts ?? 3 {
                GameState.shared.suspicionScore += 1
                GameState.shared.save()
                showBriefMessage("PMCA intrusion monitor pinged.")
            } else {
                let msg = config.failureMessage ?? reason
                showBriefMessage(msg)
            }
        }
    }

    private func completePDAHack(config: HackPuzzleConfig, interactable: Interactable) {
        dismissActivePanel()
        if let flag = config.setsFlagOnSuccess { GameState.shared.setFlag(flag) }
        if let flag = interactable.setsFlag { GameState.shared.setFlag(flag) }
        if let linkedID = interactable.linkedInteractableID,
           let door = interactableData[linkedID] {
            if let doorFlag = door.setsFlag { GameState.shared.setFlag(doorFlag) }
            openDoor(door)
        }
        interactableNodes[interactable.id]?.alpha = 0.35
        PDAJournalManager.onHackSuccess(puzzleID: config.id)
        GameState.shared.save()
        AudioManager.shared.playTerminalBeep(on: self)
        showBriefMessage(config.successMessage ?? "PDA — ACCESS GRANTED")
        notifyPDAIfUpdated()
    }

    private func applyEmpPulseToNearbyDrones() {
        guard let mara = requireMara() else { return }
        let range: CGFloat = 300
        for drone in patrols where mara.position.distance(to: drone.position) < range {
            drone.stun(duration: 8.0)
        }
    }

    private func activateNearbyInteractable() {
        guard let mara = requireMara(), let interactButton else { return }
        if mara.isOnLadder {
            mara.detachFromLadder(standingY: mara.position.y)
            interactButton.configure(for: "ladder")
            return
        }

        // NPC takes priority over environment interactables when both are in range
        if let npcID = nearbyNPCID {
            activateNPC(id: npcID)
            return
        }

        guard let id = nearbyInteractableID,
              let inter = interactableData[id] else { return }

        if !satisfiesFlagGate(inter) {
            let hint = inter.requiredFlagsAny?.first ?? inter.requiredFlag ?? ""
            showBriefMessage(accessDeniedText(for: inter, requiredFlag: hint))
            return
        }

        switch inter.type {
        case "terminal":
            activateTerminal(inter)
        case "door":
            activateDoor(inter)
        case "cartridge":
            activateCartridge(inter)
        case "cabinet":
            activateCabinet(inter)
        case "security_override":
            activateSecurityOverride(inter)
        case "building_entrance":
            activateBuildingEntrance(inter)
        case "building_exit":
            activateBuildingExit(inter)
        case "ladder":
            enterLadder(inter)
        case "information_node", "text_sign":
            mara.playScanObserve { [weak self] in
                guard let self else { return }
                if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
                NotebookManager.onInformationNodeRead(nodeID: inter.id)
                self.notifyPDAIfUpdated()
                let header = inter.nodeLabel == "RELAY" ? "CIVIC DATA UPLINK"
                    : "PUBLIC INFORMATION NODE"
                let body = inter.displayText ?? "No data available."
                self.showContentPanel(header: header, body: body) { }
            }
        default:
            break
        }
    }

    private func accessDeniedText(for inter: Interactable, requiredFlag: String) -> String {
        switch inter.type {
        case "door" where requiredFlag == "terminal01_read":
            return "ACCESS DENIED — READ TERMINAL FIRST"
        case "door" where requiredFlag == "ch1_relay_credential":
            return "ACCESS DENIED — RELAY CREDENTIAL REQUIRED"
        case "building_entrance" where requiredFlag == "ch1_relay_credential":
            return "ACCESS DENIED — RELAY CREDENTIAL REQUIRED"
        case "building_exit" where requiredFlag == "ch1_relay_credential":
            return "EXIT BLOCKED — COLLECT MAINTENANCE CREDENTIAL"
        case "cabinet" where requiredFlag == "relay_console_read":
            return "LOCKED — READ RELAY CONSOLE FIRST"
        case "door" where requiredFlag == "marr_apt_accessed" || requiredFlag == "ch2_maintenance_credential":
            return "ACCESS DENIED — CLEARANCE NOT MET"
        case "security_override" where requiredFlag == "ch1_relay_credential":
            return "PDA DENIED — RELAY CREDENTIAL NOT LOGGED"
        case "security_override":
            return "PDA DENIED — REQUIRED CLEARANCE NOT MET"
        default:
            return "ACCESS DENIED — REQUIRED CLEARANCE NOT MET"
        }
    }

    private func activateTerminal(_ inter: Interactable) {
        guard let mara = requireMara() else { return }
        mara.playTerminalInteraction { [weak self] in
            guard let self else { return }
            if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
            NotebookManager.onTerminalRead(terminalID: inter.id)
            if self.levelID == "level_ch3" { NotebookManager.checkCh3FieldCompletion() }

            let body = self.terminalContent(for: inter.id, displayText: inter.displayText)
            self.notifyPDAIfUpdated()
            self.showContentPanel(header: "TERMINAL — \(inter.id.uppercased())", body: body) { }
        }
    }

    private func activateDoor(_ inter: Interactable) {
        if inter.requiredCode != nil {
            showCodePad(for: inter)
        } else {
            if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
            openDoor(inter)
        }
    }

    private func activateCartridge(_ inter: Interactable) {
        guard let mara = requireMara() else { return }
        mara.playScanObserve { [weak self] in
            guard let self else { return }
            if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
            NotebookManager.onCartridgeCollected(cartridgeID: inter.id)
            if self.levelID == "level_ch3" { NotebookManager.checkCh3FieldCompletion() }
            self.notifyPDAIfUpdated()
            let body = inter.cartridgeData ?? "CARTRIDGE DATA CORRUPTED."
            let node = self.interactableNodes[inter.id]
            node?.alpha = 0.25
            self.showContentPanel(header: "DATA CARTRIDGE", body: body) { [weak node] in
                node?.removeFromParent()
            }
        }
    }

    private func activateCabinet(_ inter: Interactable) {
        if let flag = inter.setsFlag, GameState.shared.hasFlag(flag) {
            showBriefMessage("LOCKER EMPTY — CREDENTIAL ISSUED")
            return
        }

        let body = inter.displayText ?? """
MAINTENANCE CREDENTIAL LOCKER
Locker ID: MNT-RELAY-07

Relay Node 7 transit credential
issued to authorised maintenance
personnel.

— — —
CREDENTIAL: CH1-RELAY-MAINT-07
Status: ACTIVE
— — —

Sign out before exterior transit.
"""
        showContentPanel(header: "CREDENTIAL LOCKER", body: body) { [weak self] in
            guard let self = self else { return }
            if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
            if self.levelID.hasPrefix("level_ch2") {
                NotebookManager.onCh2CredentialIssued()
            } else {
                NotebookManager.onCredentialCollected()
            }
            GameState.shared.save()
            self.interactableNodes[inter.id]?.alpha = 0.35
            AudioManager.shared.playTerminalBeep(on: self)
        }
    }

    private func activateSecurityOverride(_ inter: Interactable) {
        if let flag = inter.setsFlag, GameState.shared.hasFlag(flag) {
            showBriefMessage("PDA — OVERRIDE ALREADY LOGGED")
            return
        }

        let body = inter.displayText ?? """
Connect PDA to maintenance override port.

Apply temporary access?
"""
        showPDAPanel(
            header: "MARA PDA — SYSTEM OVERRIDE",
            body: body,
            primaryLabel: "[ CONNECT PDA ]",
            onPrimary: { [weak self] in
                guard let self = self else { return }
                if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
                if let linkedID = inter.linkedInteractableID,
                   let door = self.interactableData[linkedID] {
                    if let doorFlag = door.setsFlag { GameState.shared.setFlag(doorFlag) }
                    self.openDoor(door)
                }
                GameState.shared.save()
                self.interactableNodes[inter.id]?.alpha = 0.35
                AudioManager.shared.playTerminalBeep(on: self)
                self.showBriefMessage("Credential accepted. Archive door override authorised.")
            },
            secondaryLabel: "[ CANCEL ]"
        )
    }

    private func activateBuildingEntrance(_ inter: Interactable) {
        guard let linked = inter.linkedLevelID else { return }
        SceneManager.shared.transition(to: .platform(levelID: linked), from: self)
    }

    private func activateBuildingExit(_ inter: Interactable) {
        guard let data = levelData,
              let parentID = data.parentLevelID,
              let spawn = data.returnSpawnPoint, spawn.count >= 2 else {
            showBriefMessage("EXIT BLOCKED")
            return
        }
        if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
        GameState.shared.save()
        GameState.shared.setPlatformSpawnOverride(
            levelID: parentID,
            point: CGPoint(x: spawn[0], y: spawn[1])
        )
        SceneManager.shared.transition(to: .platform(levelID: parentID), from: self)
    }

    private func openDoor(_ inter: Interactable) {
        guard let barrier = doorBarriers[inter.id] else { return }
        barrier.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.scaleX(to: 0, duration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
        doorBarriers.removeValue(forKey: inter.id)
        interactableNodes[inter.id]?.alpha = 0.3
        AudioManager.shared.playTerminalBeep(on: self)
    }

    // MARK: - Terminal Content

    private func terminalContent(for id: String, displayText: String?) -> String {
        if let text = displayText { return text }
        switch id {
        case "terminal_01":
            return """
PMCA SORTING FACILITY — SECTOR 12
Access Log: 2147.03.17 — Override Active

Director's Audit Order applied.
Standard log entries: SUSPENDED.

Routing anomaly at Relay Node 7.
Message ID DL-2147-009941 flagged
for secondary routing.
Origin: unlogged by standard system.

Interior clearance codes rotated.
Derived from active case victim IDs.
Format: VC-[XXXX]-M (enter XXXX).

Case 1 on your desk lists the ID.
"""
        case "terminal_02":
            return """
PMCA RELAY NODE 7 — INTERNAL LOG

Secondary routing tag: EVN-ROUTING-0442
Destination: QUIET CHOIR RELAY BUFFER

47 messages in transit buffer.
Scheduled deletion: 2147.03.19.

— — —
INNER CHECKPOINT CODE:
Derived from Case 1 victim ID.
Format: 4 digits.
Citizen VC-[XXXX]-M.
— — —

This terminal will be wiped
upon Director's audit completion.
"""
        case "relay_console_01":
            return """
PMCA RELAY NODE 7 — UTILITY CONSOLE

Maintenance credential issuance:
AUTHORISED LOCKER — EAST WALL
Locker ID: MNT-RELAY-07

Credential must be signed out
before exterior transit resumes.

— — —
Note: Locker access requires
console login acknowledgement.
— — —
"""
        default:
            return "TERMINAL ACCESS GRANTED.\nNo additional data available."
        }
    }

    // MARK: - Content Panel

    private func dismissActivePanel(onClose: (() -> Void)? = nil) {
        activePanel?.removeFromParent()
        clearPDAJournalState()
        panelScrollBodyRect = .zero
        releaseModalLock()
        onClose?()
    }

    private func clearPDAJournalState() {
        activePanel = nil
        panelScrollState = nil
        panelScrollTouch = nil
        isPDAJournalOpen = false
        pdaJournalRegions = PDAJournalPanel.HitRegions()
    }

    private func reconcileStalePDAJournal() {
        guard !isRebuildingPDAJournal else { return }
        guard isPDAJournalOpen, let panel = activePanel, panel.parent == nil else { return }
        NSLog("[DLO PDA] clearing stale field journal ref (node detached)")
        clearPDAJournalState()
        releaseModalLock()
    }

    private func configurePanelScrollRects(panelSize: CGSize, hasSecondaryButton: Bool) {
        let footerH: CGFloat = hasSecondaryButton ? 80 : 52
        let headerH: CGFloat = panelSize.height > 300 ? 72 : 52
        panelScrollBodyRect = CGRect(
            x: -panelSize.width / 2 + 8,
            y: -panelSize.height / 2 + footerH,
            width: panelSize.width - 16,
            height: panelSize.height - headerH - footerH)
    }

    private func showContentPanel(header: String, body: String,
                                  onClose: @escaping () -> Void) {
        showReadablePanel(style: .terminal, header: header, body: body,
                          primaryLabel: "[ CLOSE ]", onPrimary: onClose)
    }

    private func showPDAPanel(header: String, body: String,
                              primaryLabel: String,
                              onPrimary: @escaping () -> Void,
                              secondaryLabel: String? = nil) {
        guard activePanel == nil else { return }
        engageModalLock()

        let cam = SceneLayout.makeCamera(scene: self)
        let panelSize = CGSize(width: cam.w * 0.78, height: cam.h * 0.76)
        let entries = NotebookManager.unlockedEntries(forChapter: levelData?.chapter)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let meta = ScrollableReadablePanel.PDAMetadata(
            deviceID: "MARA-UNIT-7",
            caseRef: levelData?.chapter.uppercased() ?? "FIELD",
            noteCount: entries.count,
            syncStatus: "LOCAL ONLY",
            timestamp: formatter.string(from: Date())
        )
        let built = ScrollableReadablePanel.build(
            style: .pda,
            header: header,
            body: body,
            panelSize: panelSize,
            textMultiplier: GameState.shared.textSizeMultiplier,
            primaryButton: .init(label: primaryLabel, action: { [weak self] in
                self?.dismissActivePanel(onClose: onPrimary)
            }),
            secondaryButton: secondaryLabel.map { label in
                .init(label: label, action: { [weak self] in self?.dismissActivePanel() })
            },
            pdaMetadata: meta
        )
        built.panel.zPosition = 2500
        activePanel = built.panel
        panelScrollState = built.scrollState
        configurePanelScrollRects(panelSize: panelSize, hasSecondaryButton: secondaryLabel != nil)
        cameraNode?.addChild(built.panel)
    }

    private func showReadablePanel(style: ScrollableReadablePanel.Style,
                                   header: String, body: String,
                                   primaryLabel: String,
                                   onPrimary: @escaping () -> Void,
                                   secondaryLabel: String? = nil) {
        guard activePanel == nil else { return }
        engageModalLock()

        let cam = SceneLayout.makeCamera(scene: self)
        let panelSize = CGSize(width: cam.w * 0.78, height: cam.h * 0.76)
        let built = ScrollableReadablePanel.build(
            style: style,
            header: header,
            body: body,
            panelSize: panelSize,
            textMultiplier: GameState.shared.textSizeMultiplier,
            primaryButton: .init(label: primaryLabel, action: { [weak self] in
                self?.dismissActivePanel(onClose: onPrimary)
            }),
            secondaryButton: secondaryLabel.map { label in
                .init(label: label, action: { [weak self] in self?.dismissActivePanel() })
            }
        )
        built.panel.zPosition = 2500
        activePanel = built.panel
        panelScrollState = built.scrollState
        configurePanelScrollRects(panelSize: panelSize, hasSecondaryButton: secondaryLabel != nil)
        cameraNode?.addChild(built.panel)
    }

    // MARK: - Code Entry Panel

    private func showCodePad(for inter: Interactable) {
        guard activePanel == nil else { return }
        engageModalLock()

        let panel = SKNode()
        panel.zPosition = 2500
        var enteredCode = ""

        let panelW: CGFloat = 230
        let panelH: CGFloat = 280

        let bg = SKSpriteNode(color: DLOColor.terminalBG,
                              size: CGSize(width: panelW, height: panelH))
        bg.alpha = 0.97
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: panelH - 2),
                                 cornerRadius: 4)
        border.strokeColor = DLOColor.terminalAmber
        border.lineWidth = 1.5
        border.fillColor = .clear
        panel.addChild(border)

        let textMult = GameState.shared.textSizeMultiplier
        let headerLbl = DLOFont.terminalLabel(text: "ACCESS CODE REQUIRED", size: 11 * textMult)
        headerLbl.horizontalAlignmentMode = .center
        headerLbl.position = CGPoint(x: 0, y: panelH / 2 - 22)
        panel.addChild(headerLbl)

        let codeDisplay = SKLabelNode(text: "_ _ _ _")
        codeDisplay.fontName = "Menlo-Bold"
        codeDisplay.fontSize = 24 * textMult
        codeDisplay.fontColor = DLOColor.terminalAmber
        codeDisplay.horizontalAlignmentMode = .center
        codeDisplay.position = CGPoint(x: 0, y: panelH / 2 - 52)
        panel.addChild(codeDisplay)

        let updateDisplay: () -> Void = {
            let chars = Array(enteredCode)
                + Array(repeating: Character("_"), count: 4 - enteredCode.count)
            codeDisplay.text = chars.map(String.init).joined(separator: " ")
        }

        // 3×4 keypad grid
        let keys: [(label: String, value: String)] = [
            ("1","1"),("2","2"),("3","3"),
            ("4","4"),("5","5"),("6","6"),
            ("7","7"),("8","8"),("9","9"),
            ("✕","del"),("0","0"),("↵","enter")
        ]

        let btnW: CGFloat = 56, btnH: CGFloat = 40
        let gapX: CGFloat = 8, gapY: CGFloat = 8
        let totalW = 3 * btnW + 2 * gapX
        let startX = -totalW / 2 + btnW / 2
        let startY: CGFloat = panelH / 2 - 90

        for (i, key) in keys.enumerated() {
            let col = CGFloat(i % 3)
            let row = CGFloat(i / 3)
            let x = startX + col * (btnW + gapX)
            let y = startY - row * (btnH + gapY)

            let btn = CodeKeyNode(label: key.label,
                                  size: CGSize(width: btnW, height: btnH)) {
                switch key.value {
                case "del":
                    if !enteredCode.isEmpty { enteredCode.removeLast() }
                    updateDisplay()
                case "enter":
                    if enteredCode == inter.requiredCode {
                        if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
                        self.openDoor(inter)
                        self.dismissActivePanel()
                    } else {
                        enteredCode = ""
                        updateDisplay()
                        codeDisplay.run(SKAction.sequence([
                            SKAction.moveBy(x: -6, y: 0, duration: 0.04),
                            SKAction.moveBy(x: 12, y: 0, duration: 0.04),
                            SKAction.moveBy(x: -6, y: 0, duration: 0.04)
                        ]))
                        codeDisplay.fontColor = DLOColor.danger
                        codeDisplay.run(SKAction.sequence([
                            SKAction.wait(forDuration: 0.5),
                            SKAction.run { codeDisplay.fontColor = DLOColor.terminalAmber }
                        ]))
                    }
                default:
                    if enteredCode.count < 4 {
                        enteredCode += key.value
                        updateDisplay()
                    }
                }
            }
            btn.position = CGPoint(x: x, y: y)
            panel.addChild(btn)
        }

        let cancelBtn = PanelButtonNode(label: "[ CANCEL ]") { [weak self] in
            self?.dismissActivePanel()
        }
        cancelBtn.position = CGPoint(x: 0, y: -panelH / 2 + 20)
        panel.addChild(cancelBtn)

        activePanel = panel
        cameraNode?.addChild(panel)
    }

    // MARK: - Brief Message Toast

    // MARK: - Ladder

    private func enterLadder(_ inter: Interactable) {
        guard let mara = requireMara(), let interactButton,
              let extent = inter.ladderExtent, extent.count >= 2, !mara.isOnLadder else { return }
        let bottomY = extent[0]
        let topY = extent[1]
        guard mara.position.y <= bottomY + 16 else { return }
        mara.position.x = inter.position[0]
        if mara.position.y < bottomY { mara.position.y = bottomY }
        mara.attachToLadder(railX: inter.position[0], bottomY: bottomY, topY: topY)
        interactButton.configure(for: "ladder_active")
        nearbyInteractableID = inter.id
    }

    private func tryEnterNearbyLadder(pad: VirtualPadNode) {
        guard let mara = requireMara() else { return }
        guard let id = nearbyInteractableID,
              let inter = interactableData[id],
              inter.type == "ladder",
              let extent = inter.ladderExtent, extent.count >= 2 else { return }
        let bottomY = extent[0]
        let wantsClimb = pad.currentInput.movementVector.dy > 0.28
        guard mara.position.y <= bottomY + 14, wantsClimb else { return }
        enterLadder(inter)
    }

    // MARK: - PDA Journal

    private func handlePDAButtonTap() {
        guard let mara = requireMara(), activePanel == nil, !mara.isActionAnimating else { return }
        if mara.pdaVisualOut {
            mara.putAwayPDA { }
        } else {
            mara.ensurePDAOut { [weak self] in
                self?.showPDAJournal()
            }
        }
    }

    private func showPDAJournal() {
        guard activePanel == nil else { return }
        engageModalLock()
        isGamePaused = true
        isPDAJournalOpen = true
        let shift = PDAJournalManager.shiftNumber(from: levelData?.chapter ?? "ch1")
        let skipBoot = PDAJournalManager.state.bootScreenSeen
        NSLog("[DLO PDA] field open requested shift=%d skipBoot=%d", shift, skipBoot)
        pdaJournalScreen = PDAJournalPanel.initialScreen(currentShift: shift, skipBoot: skipBoot)
        rebuildFieldPDAJournal(screen: pdaJournalScreen)
    }

    private func rebuildFieldPDAJournal(screen: PDAJournalPanel.Screen) {
        isRebuildingPDAJournal = true
        defer { isRebuildingPDAJournal = false }

        let priorScreen = pdaJournalScreen
        let wasVisible = activePanel?.parent != nil
        activePanel?.removeFromParent()
        panelScrollState = nil
        panelScrollTouch = nil

        let cam = SceneLayout.makeCamera(scene: self)
        let panelW = cam.w * 0.78
        let panelH = cam.h * 0.84
        let center = CGPoint(x: cam.midX, y: cam.midY)
        let shift = PDAJournalManager.shiftNumber(from: levelData?.chapter ?? "ch1")
        let built = PDAJournalPanel.build(
            screen: screen,
            panelSize: CGSize(width: panelW, height: panelH),
            center: center,
            textMultiplier: GameState.shared.textSizeMultiplier,
            currentShift: shift,
            chapterID: levelData?.chapter,
            fieldObjective: levelData?.objectiveText,
            onRebuild: { [weak self] newScreen in self?.rebuildFieldPDAJournal(screen: newScreen) },
            onClose: { [weak self] in
                self?.isGamePaused = false
                self?.dismissActivePanel()
            })

        built.panel.zPosition = 2500
        if wasVisible && Self.shouldFadePDATransition(from: priorScreen, to: screen) {
            built.panel.alpha = 0
            built.panel.run(SKAction.fadeIn(withDuration: 0.12))
        } else {
            built.panel.alpha = 1
        }
        activePanel = built.panel
        pdaJournalScreen = built.screen
        pdaJournalRegions = built.regions
        panelScrollState = built.scrollState
        cameraNode?.addChild(built.panel)
    }

    private static func shouldFadePDATransition(
        from oldScreen: PDAJournalPanel.Screen,
        to newScreen: PDAJournalPanel.Screen
    ) -> Bool {
        if case .section = oldScreen, case .section = newScreen { return false }
        return true
    }

    private func notifyPDAIfUpdated() {
        if PDAJournalManager.consumeUpdateNotice() {
            showPDAToast()
        }
    }

    private func showPDAToast() {
        let cam = SceneLayout.makeCamera(scene: self)
        let lbl = DLOFont.terminalLabel(text: "PDA UPDATED", size: 10 * GameState.shared.textSizeMultiplier)
        lbl.horizontalAlignmentMode = .center
        lbl.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 1)
        lbl.position = CGPoint(x: cam.midX, y: cam.bottom + 36)
        lbl.zPosition = 2000
        overlayNode?.addChild(lbl)
        lbl.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.12),
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func showBriefMessage(_ text: String) {
        let cam = SceneLayout.makeCamera(scene: self)
        let lbl = DLOFont.terminalLabel(text: text, size: 11 * GameState.shared.textSizeMultiplier)
        lbl.horizontalAlignmentMode = .center
        lbl.fontColor = DLOColor.danger
        lbl.position = CGPoint(x: cam.midX, y: cam.midY + 30)
        lbl.zPosition = 2000
        overlayNode?.addChild(lbl)
        lbl.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.8),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Death / Skip / Complete

    private func maraCaught() {
        guard !isLevelComplete, !isRestartingAfterCatch else { return }
        isRestartingAfterCatch = true

        if !GameState.shared.reducedFlashingEnabled {
            let flash = SKSpriteNode(color: DLOColor.danger.withAlphaComponent(0.5), size: size)
            flash.position = .zero
            flash.zPosition = 900
            cameraNode?.addChild(flash)
            flash.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.removeFromParent()
            ]))
        }

        AudioManager.shared.playDroneAlert(on: self)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                SceneManager.shared.transition(to: .platform(levelID: self.levelID), from: self)
            }
        ]))
    }

    private func satisfiesFlagGate(_ inter: Interactable) -> Bool {
        if let any = inter.requiredFlagsAny, !any.isEmpty {
            return any.contains { GameState.shared.hasFlag($0) }
        }
        if let required = inter.requiredFlag {
            return GameState.shared.hasFlag(required)
        }
        return true
    }

    private func completePlatformSection(dialogueID: String) {
        guard !isLevelComplete else { return }
        isLevelComplete = true
        let chapterID = levelData?.chapter ?? "ch1"
        GameState.shared.recordLevelComplete(levelID)
        if let nextID = nextChapterID(from: chapterID) {
            GameState.shared.setFlag("\(nextID)_unlocked")
        }
        GameState.shared.save()

        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.position = .zero
        overlay.zPosition = 999
        overlay.alpha = 0
        cameraNode?.addChild(overlay)

        overlay.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.8),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let nextChapter = self.nextChapterID(from: chapterID) ?? chapterID
                GameState.shared.currentChapterID = nextChapter
                GameState.shared.save()
                SceneManager.shared.transition(
                    to: .dialogue(dialogueID: dialogueID,
                                  returnScene: .desk(chapterID: nextChapter),
                                  startNodeID: nil),
                    from: self
                )
            }
        ]))
    }

    private func levelComplete() {
        guard !isLevelComplete else { return }
        isLevelComplete = true
        GameState.shared.recordLevelComplete(levelID)

        // Set the unlock flag for the next chapter so it appears unlocked in Chapter Select.
        let chapterID = levelData?.chapter ?? "ch1"
        if let nextID = nextChapterID(from: chapterID) {
            GameState.shared.setFlag("\(nextID)_unlocked")
        }
        GameState.shared.save()

        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.position = .zero
        overlay.zPosition = 999
        overlay.alpha = 0
        cameraNode?.addChild(overlay)

        overlay.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.8),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let chapterID = self.levelData?.chapter ?? "ch1"
                let nextChapterID = self.nextChapterID(from: chapterID) ?? "ch1"
                GameState.shared.currentChapterID = nextChapterID
                GameState.shared.save()
                SceneManager.shared.transition(to: .desk(chapterID: nextChapterID), from: self)
            }
        ]))
    }

    private func nextChapterID(from current: String) -> String? {
        let chapters = ["ch1","ch2","ch3","ch4","ch5","ch6","ch7","ch8"]
        guard let idx = chapters.firstIndex(of: current), idx + 1 < chapters.count else { return nil }
        return chapters[idx + 1]
    }

    // MARK: - Scene-Level Touch Dispatch (proven DeskScene pattern)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reconcileStalePDAJournal()
        for touch in touches {
            let camPos = camSpacePoint(from: touch)

            // Pause button works regardless of game state
            if pauseButtonRect.contains(camPos) {
                AudioManager.shared.playUIClick()
                if isGamePaused && pauseMenuNode != nil { hidePauseMenu() }
                else if !isGamePaused { showPauseMenu() }
                return
            }

            if notebookButtonRect.contains(camPos) && activePanel == nil {
                handlePDAButtonTap()
                return
            }

            if activePanel != nil {
                if isPDAJournalOpen {
                    if !pdaJournalRegions.shiftBar.contains(camPos),
                       pdaJournalRegions.scrollBody.contains(camPos),
                       panelScrollState?.maxScroll ?? 0 > 0 {
                        panelScrollTouch = touch
                    }
                } else if let scrollState = panelScrollState, scrollState.maxScroll > 0,
                          let cameraNode {
                    let local = touch.location(in: cameraNode)
                    if panelScrollBodyRect.contains(local) {
                        panelScrollTouch = touch
                    }
                }
                return
            }

            if isGamePaused || isGameplayInputFrozen { continue }

            // All touches forwarded to VirtualPad (interact is on the right cluster)
            guard let virtualPad else { continue }
            virtualPad.notifyTouchBegan(touch, at: touch.location(in: virtualPad))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let scrollTouch = panelScrollTouch,
           let state = panelScrollState,
           touches.contains(scrollTouch) {
            let pos = scrollTouch.location(in: self)
            let prev = scrollTouch.previousLocation(in: self)
            state.applyDrag(deltaY: pos.y - prev.y)
            return
        }
        guard !isGamePaused, !isGameplayInputFrozen, let virtualPad else { return }
        for touch in touches {
            virtualPad.notifyTouchMoved(touch, at: touch.location(in: virtualPad))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === panelScrollTouch { panelScrollTouch = nil }
            if isPDAJournalOpen, activePanel != nil, !isRebuildingPDAJournal {
                let camPos = camSpacePoint(from: touch)
                let shift = PDAJournalManager.shiftNumber(from: levelData?.chapter ?? "ch1")
                guard let panel = activePanel else { continue }
                _ = PDAJournalPanel.handleTap(
                    at: camPos,
                    build: PDAJournalPanel.BuildResult(
                        panel: panel, scrollState: panelScrollState,
                        regions: pdaJournalRegions, screen: pdaJournalScreen),
                    currentShift: shift,
                    onRebuild: { [weak self] screen in self?.rebuildFieldPDAJournal(screen: screen) },
                    onClose: { [weak self] in
                        self?.isGamePaused = false
                        self?.dismissActivePanel()
                    })
            }
            virtualPad?.notifyTouchEnded(touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === panelScrollTouch { panelScrollTouch = nil }
            virtualPad?.notifyTouchCancelled(touch)
        }
    }

    private func camSpacePoint(from touch: UITouch) -> CGPoint {
        let s = touch.location(in: self)
        let cx = cameraNode?.position.x ?? 0
        let cy = cameraNode?.position.y ?? 0
        return CGPoint(x: s.x - cx, y: s.y - cy)
    }

    // MARK: - Pause Menu

    private func showPauseMenu() {
        guard pauseMenuNode == nil else { return }
        engageModalLock()
        isGamePaused = true

        let cam = SceneLayout.makeCamera(scene: self)
        let mult = GameState.shared.textSizeMultiplier
        let panelW = min(cam.w * 0.78, 520)
        let panelH = min(cam.h * 0.88, 420)

        let panel = SKNode()
        panel.zPosition = 3000

        let bg = SKSpriteNode(color: DLOColor.terminalBG,
                              size: CGSize(width: panelW, height: panelH))
        bg.alpha = 0.96
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: panelH - 2),
                                 cornerRadius: 4)
        border.strokeColor = DLOColor.uiBorder
        border.lineWidth   = 1.5
        border.fillColor   = .clear
        panel.addChild(border)

        let hdr = DLOFont.titleLabel(text: "SHIFT PAUSED", size: 14 * mult)
        hdr.horizontalAlignmentMode = .center
        hdr.position = CGPoint(x: 0, y: panelH / 2 - 28 * mult)
        panel.addChild(hdr)

        let div = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                               size: CGSize(width: panelW - 32, height: 1))
        div.position = CGPoint(x: 0, y: panelH / 2 - 44 * mult)
        panel.addChild(div)

        let btnLabels: [(String, () -> Void)] = [
            ("[ RESUME ]",                  { [weak self] in self?.hidePauseMenu() }),
            ("[ SAVE + RETURN TO MENU ]",   { [weak self] in
                guard let self else { return }
                GameState.shared.save()
                self.hidePauseMenu()
                SceneManager.shared.transition(to: .mainMenu, from: self) }),
            ("[ RETURN WITHOUT SAVING ]",   { [weak self] in
                guard let self else { return }
                self.hidePauseMenu()
                SceneManager.shared.transition(to: .mainMenu, from: self) }),
            ("[ SETTINGS ]",                { [weak self] in
                guard let self else { return }
                let spawn = self.mara?.position ?? CGPoint(x: 0, y: MaraPlayerNode.defaultStandCenterY)
                GameState.shared.setSettingsReturn(
                    .platform(levelID: self.levelID, spawn: spawn))
                SceneManager.shared.transition(to: .settings, from: self) }),
            ("[ PDA JOURNAL ]",             { [weak self] in
                self?.hidePauseMenu()
                self?.showPDAJournal() })
        ]

        let btnWidth = panelW - 48
        let btnSpacing: CGFloat = 10 * mult
        var nextBtnY = panelH / 2 - 72 * mult
        for (label, action) in btnLabels {
            let btn = PanelButtonNode(label: label, width: btnWidth, fontSize: 11,
                                      playsUIClick: true, action: action)
            btn.position = CGPoint(x: 0, y: nextBtnY)
            panel.addChild(btn)
            nextBtnY -= btn.height + btnSpacing
        }

        pauseMenuNode = panel
        cameraNode?.addChild(panel)
    }

    private func hidePauseMenu() {
        isGamePaused = false
        pauseMenuNode?.removeFromParent()
        pauseMenuNode = nil
        releaseModalLock()
    }
}

// MARK: - CGPoint distance

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat { hypot(x - other.x, y - other.y) }
}

// MARK: - Physics contact helper

private extension SKPhysicsContact {
    func bodies(catA: UInt32, catB: UInt32) -> (SKPhysicsBody, SKPhysicsBody)? {
        if bodyA.categoryBitMask == catA && bodyB.categoryBitMask == catB {
            return (bodyA, bodyB)
        }
        if bodyA.categoryBitMask == catB && bodyB.categoryBitMask == catA {
            return (bodyB, bodyA)
        }
        return nil
    }
}

// MARK: - Interact Button (camera-space, follows Mara — purely visual, tapped via scene)

private final class InteractButtonNode: SKNode {
    private let lbl: SKLabelNode

    override init() {
        lbl = SKLabelNode(text: "▲  INTERACT")
        lbl.fontName = "Menlo-Bold"
        lbl.fontSize = 10
        lbl.fontColor = DLOColor.terminalAmber
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode = .center
        super.init()

        let size = CGSize(width: 130, height: 30)
        let bg = SKSpriteNode(color: DLOColor.terminalBG.withAlphaComponent(0.88), size: size)
        let border = SKShapeNode(rectOf: size, cornerRadius: 4)
        border.strokeColor = DLOColor.teal
        border.lineWidth = 1.2
        border.fillColor = .clear
        addChild(bg)
        addChild(border)
        addChild(lbl)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(for type: String, prompt: String? = nil) {
        if let prompt {
            lbl.text = "▲  \(prompt)"
            return
        }
        switch type {
        case "terminal":           lbl.text = "▲  READ TERMINAL"
        case "door":               lbl.text = "▲  OPEN DOOR"
        case "cartridge":          lbl.text = "▲  COLLECT FILE"
        case "cabinet":            lbl.text = "▲  OPEN LOCKER"
        case "building_entrance":  lbl.text = "▲  ENTER"
        case "building_exit":      lbl.text = "▲  EXIT"
        case "security_override":  lbl.text = "▲  CONNECT PDA"
        case "ladder":             lbl.text = "▲  CLIMB"
        case "ladder_active":      lbl.text = "▲  ON LADDER"
        case "npc":                lbl.text = "▲  TALK"
        case "information_node", "text_sign": lbl.text = "▲  READ NOTICE"
        default:                   lbl.text = "▲  INTERACT"
        }
    }
}

// MARK: - Code Key (number pad key)

private final class CodeKeyNode: SKNode {
    private let action: () -> Void
    private let nodeSize: CGSize

    init(label: String, size: CGSize, action: @escaping () -> Void) {
        self.action = action
        self.nodeSize = size
        super.init()
        isUserInteractionEnabled = true

        let bg = SKShapeNode(rectOf: size, cornerRadius: 4)
        bg.fillColor = DLOColor.uiBorder.withAlphaComponent(0.22)
        bg.strokeColor = DLOColor.uiBorder
        bg.lineWidth = 1
        addChild(bg)

        let lbl = SKLabelNode(text: label)
        lbl.fontName = "Menlo-Bold"
        lbl.fontSize = 14
        lbl.fontColor = DLOColor.terminalAmber
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode = .center
        addChild(lbl)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func calculateAccumulatedFrame() -> CGRect {
        CGRect(x: position.x - nodeSize.width / 2, y: position.y - nodeSize.height / 2,
               width: nodeSize.width, height: nodeSize.height)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 0.6 }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1.0; action()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 1.0 }
}

