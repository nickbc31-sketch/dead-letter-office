import SpriteKit
import GameplayKit

final class PlatformScene: SKScene, SKPhysicsContactDelegate {

    var levelID: String = "level_ch1"

    private var levelData: LevelData?
    private var mara: MaraPlayerNode!
    private var virtualPad: VirtualPadNode!
    private var cameraNode: SKCameraNode!
    private var patrols: [DroneEnemyNode] = []
    private var collectiblePickups: [SKNode] = []
    private var environmentTextNodes: [SKNode] = []

    // Interactable system
    private var interactableData: [String: Interactable] = [:]
    private var interactableNodes: [String: SKNode] = [:]   // id → scene node
    private var doorBarriers: [String: SKSpriteNode] = [:]  // id → blocker sprite
    private var nearbyInteractableID: String?
    private var activePanel: SKNode?
    private var interactButton: InteractButtonNode!
    private var interactWasPressed = false
    private var empWasPressed = false

    // Level state
    private var isLevelComplete = false
    private var isRestartingAfterCatch = false
    private var overlayNode: SKNode!

    private var isInteractionPaused: Bool { activePanel != nil }

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
    private var interactButtonCamRect: CGRect = .zero

    override func didMove(to view: SKView) {
        SceneManager.shared.view = view
        physicsWorld.gravity = CGVector(dx: 0, dy: -700)  // tuned for jumpImpulse=500
        physicsWorld.contactDelegate = self

        guard let data = LevelData.load(id: levelID) else {
            SceneManager.shared.transition(to: .desk(chapterID: "ch1"), from: self)
            return
        }
        levelData = data
        buildLevel(data)
        buildHUD()
        buildVirtualPad()

        if let track = data.ambientMusicTrack {
            AudioManager.shared.playMusic(named: track)
        } else {
            AudioManager.shared.playMusic(named: "ambient_platform")
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

        let spawn = CGPoint(x: data.spawnPoint[0], y: data.spawnPoint[1])
        mara = MaraPlayerNode()
        // Feet rest on floor top (y=40); physics body is 50pt tall centred on node.
        mara.position = CGPoint(x: spawn.x, y: max(spawn.y, 66))
        mara.zPosition = 50
        addChild(mara)

        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
        // Start camera at the steady-state target so there is no initial rush that
        // makes Mara appear to slide backwards while the camera catches up.
        let halfW = size.width / 2
        let clampedX = max(halfW, min(spawn.x, CGFloat(data.levelWidth) - halfW))
        cameraNode.position = CGPoint(x: clampedX, y: spawn.y + size.height * 0.25)

        for inter in data.interactables        { buildInteractable(inter) }
        for patrol in data.patrols             { buildPatrol(patrol) }
        for pickup in data.pickups             { buildPickup(pickup) }
        for envText in data.environmentalTextNodes { buildEnvironmentText(envText) }
        for npc in data.npcs ?? []             { buildNPC(npc) }
    }

    private func buildBackgroundLayer(_ layer: BackgroundLayer,
                                      levelWidth: CGFloat, levelHeight: CGFloat) -> SKNode {
        let node = SKNode()
        node.zPosition = layer.zPosition
        node.name = "bgLayer_\(layer.zPosition)"

        if UIImage(named: layer.imageName) != nil {
            let sprite = SKSpriteNode(imageNamed: layer.imageName)
            sprite.size = CGSize(width: levelWidth, height: levelHeight)
            sprite.position = CGPoint(x: levelWidth / 2,
                                      y: levelHeight / 2 + layer.yOffset)
            node.addChild(sprite)
        } else {
            node.addChild(buildProceduralBackground(layer: layer,
                                                    width: levelWidth, height: levelHeight))
        }
        return node
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

        // Floor with teal top-edge glow so player can see the ground clearly
        let ground = SKSpriteNode(color: DLOColor.platformSilhouette,
                                  size: CGSize(width: width, height: groundH))
        ground.position = CGPoint(x: width / 2, y: groundH / 2)
        ground.zPosition = 20
        // One-way top edge — solid rectangle floor trapped Mara inside the collider.
        let halfW = width / 2
        let topY  = groundH / 2
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -halfW, y: topY),
                                           to:   CGPoint(x:  halfW, y: topY))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.restitution = 0
        ground.physicsBody?.friction = 0
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.player
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(ground)

        let floorEdge = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.6),
                                      size: CGSize(width: width, height: 2))
        floorEdge.position = CGPoint(x: width / 2, y: groundH)
        floorEdge.zPosition = 21
        addChild(floorEdge)

        // Default floating platforms only used if level JSON has none defined.
        // Real platforms come from level_chN.json platformNodes field.
        // This fallback ensures old levels still work.
        let platforms: [(x: CGFloat, y: CGFloat, w: CGFloat)] = [
            (400, 120, 180), (700, 170, 140), (1000, 130, 160),
            (1300, 200, 150), (1600, 150, 180), (1900, 190, 130),
            (2200, 130, 180), (2500, 170, 160)
        ]
        for p in platforms { addPlatform(x: p.x, y: p.y, width: p.w) }
    }

    private func addPlatform(x: CGFloat, y: CGFloat, width: CGFloat) {
        let plat = SKSpriteNode(color: DLOColor.platformSilhouette.withAlphaComponent(0.9),
                                size: CGSize(width: width, height: 20))
        plat.position = CGPoint(x: x, y: y)
        plat.zPosition = 20
        let pHalfW = plat.size.width / 2
        let pTopY  = plat.size.height / 2
        plat.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -pHalfW, y: pTopY),
                                         to:   CGPoint(x:  pHalfW, y: pTopY))
        plat.physicsBody?.isDynamic = false
        plat.physicsBody?.restitution = 0
        plat.physicsBody?.friction = 0
        plat.physicsBody?.categoryBitMask = PhysicsCategory.ground
        plat.physicsBody?.collisionBitMask = PhysicsCategory.player
        plat.physicsBody?.contactTestBitMask = PhysicsCategory.player
        let edge = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.5),
                                size: CGSize(width: width, height: 2))
        edge.position = CGPoint(x: 0, y: 11)
        plat.addChild(edge)
        addChild(plat)
    }

    // MARK: - Interactable Building

    private func buildInteractable(_ inter: Interactable) {
        interactableData[inter.id] = inter

        let pos = CGPoint(x: inter.position[0], y: inter.position[1])

        // Door: physical barrier that blocks movement
        if inter.type == "door" {
            let alreadyOpen = inter.setsFlag.map { GameState.shared.hasFlag($0) } ?? false
            if !alreadyOpen {
                let barrier = buildDoorBarrier(at: pos)
                doorBarriers[inter.id] = barrier
                addChild(barrier)
            }
        }

        // Visual icon node (for proximity detection)
        let node = SKNode()
        node.position = pos
        node.name = "interactable_\(inter.id)"
        node.zPosition = 30

        let (icon, color) = iconAndColor(for: inter.type)
        let sprite = SKLabelNode(text: icon)
        sprite.fontName = "Menlo-Bold"
        sprite.fontSize = 16
        sprite.fontColor = color
        sprite.horizontalAlignmentMode = .center
        sprite.verticalAlignmentMode = .center
        node.addChild(sprite)

        if inter.type != "text_sign" {
            sprite.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 1.2),
                SKAction.fadeAlpha(to: 1.0, duration: 1.2)
            ])))
        }

        // Physics proximity sensor
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 48, height: 72))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.interactable
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        node.physicsBody = body
        node.userData = NSMutableDictionary()
        node.userData?["interactableID"] = inter.id

        addChild(node)
        interactableNodes[inter.id] = node

        // Text signs show their text passively (no interaction needed)
        if inter.type == "text_sign", let text = inter.displayText {
            let lbl = SKLabelNode(text: text)
            lbl.fontName = "Menlo"
            lbl.fontSize = 8
            lbl.fontColor = DLOColor.uiBorder.withAlphaComponent(0.6)
            lbl.horizontalAlignmentMode = .center
            lbl.position = CGPoint(x: 0, y: 28)
            node.addChild(lbl)
        }
    }

    private func buildDoorBarrier(at pos: CGPoint) -> SKSpriteNode {
        let barrier = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.8),
                                   size: CGSize(width: 16, height: 200))
        // Centre the barrier so it sits on the floor (floor top ≈ y=40)
        barrier.position = CGPoint(x: pos.x, y: 140)
        barrier.zPosition = 22

        barrier.physicsBody = SKPhysicsBody(rectangleOf: barrier.size)
        barrier.physicsBody?.isDynamic = false
        barrier.physicsBody?.categoryBitMask = PhysicsCategory.ground
        barrier.physicsBody?.collisionBitMask = PhysicsCategory.player

        // Teal edge strip
        let edge = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.9),
                                size: CGSize(width: 3, height: 200))
        edge.position = CGPoint(x: -6.5, y: 0)
        barrier.addChild(edge)

        return barrier
    }

    private func iconAndColor(for type: String) -> (String, SKColor) {
        switch type {
        case "terminal":    return ("▣", DLOColor.teal)
        case "door":        return ("▪", DLOColor.terminalAmber)
        case "cartridge":   return ("◈", DLOColor.terminalGreen)
        case "text_sign":   return ("ℹ", DLOColor.dimText)
        default:            return ("?", DLOColor.dimText)
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

        let icon = SKLabelNode(text: "◆")
        icon.fontName = "Menlo"
        icon.fontSize = 14
        icon.fontColor = DLOColor.terminalGreen
        icon.horizontalAlignmentMode = .center
        icon.verticalAlignmentMode = .center
        node.addChild(icon)
        icon.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 4, duration: 0.8),
            SKAction.moveBy(x: 0, y: -4, duration: 0.8)
        ])))

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

        let node = SKNode()
        node.position = CGPoint(x: npc.position[0], y: npc.position[1])
        node.zPosition = 35
        node.name = "npc_\(npc.id)"

        // Civilian silhouette — slightly lighter than guard/drone
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

        // Pulsing dialogue indicator above head
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

        // Name tag
        let nameLbl = DLOFont.terminalLabel(text: npc.displayName, size: 7)
        nameLbl.fontColor = DLOColor.dimText
        nameLbl.horizontalAlignmentMode = .center
        nameLbl.position = CGPoint(x: 0, y: 73)
        node.addChild(nameLbl)

        addChild(node)
        npcNodes[npc.id] = node
    }

    // MARK: - NPC Proximity (distance-based, called every frame)

    private func checkNPCProximity() {
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

        guard closestID != nearbyNPCID else { return }
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

    // MARK: - NPC Activation

    private func activateNPC(id: String) {
        guard let npc = npcDataMap[id] else { return }

        let alreadyTalked = npcTalkedTo.contains(id)
        let repeatable = npc.repeatable ?? false

        if alreadyTalked && !repeatable {
            showBriefMessage("...")
            return
        }

        npcTalkedTo.insert(id)

        if let flag = npc.setsFlag {
            GameState.shared.setFlag(flag)
        }

        // Build dialogue lines into one body string
        let body = npc.dialogue.joined(separator: "\n\n")
        showContentPanel(header: npc.displayName.uppercased(), body: body) {
            // Swap indicator to dim "." after first conversation
            if let indicator = self.npcNodes[id]?.childNode(withName: "npc_indicator_\(id)") {
                indicator.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
            }
        }
    }

    // MARK: - HUD

    private func buildHUD() {
        overlayNode = SKNode()
        overlayNode.zPosition = 1000

        let cam = SceneLayout.makeCamera(scene: self)

        // Interact button — purely visual, tapped via scene-level rect check
        interactButton = InteractButtonNode()
        interactButton.alpha = 0
        interactButton.zPosition = 1100
        overlayNode.addChild(interactButton)

        // ── Objective text — top-left, large and readable on physical iPhone ──
        if let obj = levelData?.objectiveText {
            // Dark backing strip for legibility over any background
            let objBacking = SKSpriteNode(
                color: DLOColor.terminalBG.withAlphaComponent(0.72),
                size: CGSize(width: cam.w * 0.55, height: 44))
            objBacking.anchorPoint = CGPoint(x: 0, y: 1)
            objBacking.position   = CGPoint(x: cam.left, y: cam.top)
            objBacking.zPosition  = 1049
            overlayNode.addChild(objBacking)

            let objLbl = DLOFont.terminalLabel(text: obj, size: 14)
            objLbl.horizontalAlignmentMode = .left
            objLbl.verticalAlignmentMode   = .top
            objLbl.position = CGPoint(x: cam.left + 10, y: cam.top - 8)
            objLbl.fontColor = DLOColor.terminalAmber
            objLbl.preferredMaxLayoutWidth = cam.w * 0.52
            objLbl.numberOfLines = 2
            objLbl.zPosition = 1050
            overlayNode.addChild(objLbl)
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
        overlayNode.addChild(pauseBG)

        let pauseLbl = DLOFont.terminalLabel(text: "MENU", size: 11)
        pauseLbl.horizontalAlignmentMode = .center
        pauseLbl.position  = CGPoint(x: pauseCX, y: pauseCY - 4)
        pauseLbl.zPosition = 1051
        overlayNode.addChild(pauseLbl)

        pauseButtonRect = CGRect(
            x: cam.right - pauseW - 8, y: cam.top - pauseH - 8,
            width: pauseW, height: pauseH)

        cameraNode.addChild(overlayNode)
    }

    private func buildVirtualPad() {
        let cam = SceneLayout.makeCamera(scene: self)
        virtualPad = VirtualPadNode()
        virtualPad.position = CGPoint(x: cam.left, y: cam.bottom)
        virtualPad.zPosition = 500
        cameraNode.addChild(virtualPad)
        // Must be called after addChild so layoutRightCluster can lock down jumpRectPad.
        virtualPad.configure(screenWidth: cam.w, screenHeight: cam.h)
        virtualPad.layoutRightCluster(x: cam.w - 175)
    }

    // MARK: - Game Loop

    private var lastUpdateTime: TimeInterval = 0

    override func didSimulatePhysics() {
        mara?.finishAirbornePhysicsStep()
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused else { return }
        let delta = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 1.0 / 60.0
        lastUpdateTime = currentTime
        updateMara(delta: delta)
        updateCamera()
        if !isInteractionPaused { updateDrones(currentTime) }
        if !isInteractionPaused { checkExits() }
    }

    private func updateMara(delta: TimeInterval) {
        guard let mara = mara, let pad = virtualPad else { return }

        if !isInteractionPaused {
            mara.applyInput(pad.currentInput, delta: delta)
        }

        mara.updateStunCooldown(delta: delta)

        // Edge-detect interact button press (right cluster)
        let interactNow = pad.currentInput.interact
        if interactNow && !interactWasPressed && !isInteractionPaused {
            activateNearbyInteractable()
        }
        interactWasPressed = interactNow

        // Edge-detect EMP button press
        let empNow = pad.currentInput.emp
        if empNow && !empWasPressed && !isInteractionPaused {
            if mara.fireStunPulse(scene: self) {
                applyEmpPulseToNearbyDrones()
            }
        }
        empWasPressed = empNow

        let interactAvailable = nearbyInteractableID != nil || nearbyNPCID != nil
        pad.setInteractHighlight(interactAvailable)
        pad.setEmpCooldown(ratio: mara.stunCooldownRatio)

        // NPC proximity check (distance-based, no physics sensor needed)
        if !isInteractionPaused { checkNPCProximity() }

        // Position the interact button above Mara in camera space and track rect for scene touch
        let ibCenter = CGPoint(
            x: mara.position.x - cameraNode.position.x,
            y: mara.position.y - cameraNode.position.y + 52)
        interactButton.position = ibCenter
        interactButtonCamRect = CGRect(x: ibCenter.x - 65, y: ibCenter.y - 15, width: 130, height: 30)
    }

    private func updateCamera() {
        guard let data = levelData else { return }
        let targetX = max(size.width / 2,
                          min(mara.position.x, data.levelWidth - size.width / 2))
        let targetY = max(size.height / 2,
                          min(mara.position.y + 80, data.levelHeight - size.height / 2))
        let smoothed = CGPoint(
            x: cameraNode.position.x + (targetX - cameraNode.position.x) * 0.08,
            y: cameraNode.position.y + (targetY - cameraNode.position.y) * 0.08)
        cameraNode.position = smoothed

        children
            .compactMap { $0.name?.hasPrefix("bgLayer_") == true ? $0 : nil }
            .forEach { layer in
                let z = CGFloat(Double(
                    layer.name?.replacingOccurrences(of: "bgLayer_", with: "") ?? "0") ?? 0)
                let factor = max(0, (-z) / 50) * 0.3
                layer.position.x = -cameraNode.position.x * factor
            }
    }

    private func updateDrones(_ currentTime: TimeInterval) {
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
        guard let data = levelData, !isLevelComplete else { return }
        for exit in data.exits {
            guard let xStr = exit["x"], let yStr = exit["y"],
                  let x = Double(xStr), let y = Double(yStr) else { continue }
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
                interactButton.configure(for: inter.type)
                interactButton.run(SKAction.fadeIn(withDuration: 0.2))
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
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

    private func applyEmpPulseToNearbyDrones() {
        // Match expanded pulse radius (120 × 2.5 scale in fireStunPulse)
        let range: CGFloat = 300
        for drone in patrols where mara.position.distance(to: drone.position) < range {
            drone.stun(duration: 8.0)
        }
    }

    private func activateNearbyInteractable() {
        // NPC takes priority over environment interactables when both are in range
        if let npcID = nearbyNPCID {
            activateNPC(id: npcID)
            return
        }

        guard let id = nearbyInteractableID,
              let inter = interactableData[id] else { return }

        // Check required flag gate
        if let required = inter.requiredFlag, !GameState.shared.hasFlag(required) {
            showBriefMessage(accessDeniedText(for: inter, requiredFlag: required))
            return
        }

        switch inter.type {
        case "terminal":
            activateTerminal(inter)
        case "door":
            activateDoor(inter)
        case "cartridge":
            activateCartridge(inter)
        case "text_sign":
            if let text = inter.displayText {
                showBriefMessage(text)
            }
        default:
            break
        }
    }

    private func accessDeniedText(for inter: Interactable, requiredFlag: String) -> String {
        switch inter.type {
        case "door" where requiredFlag == "terminal01_read":
            return "ACCESS DENIED — READ TERMINAL FIRST"
        case "door" where requiredFlag == "door01_open":
            return "ACCESS DENIED — CLEAR INNER CHECKPOINT FIRST"
        default:
            return "ACCESS DENIED — REQUIRED CLEARANCE NOT MET"
        }
    }

    private func activateTerminal(_ inter: Interactable) {
        if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }

        let body = terminalContent(for: inter.id, displayText: inter.displayText)
        showContentPanel(header: "TERMINAL — \(inter.id.uppercased())", body: body) { }
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
        if let flag = inter.setsFlag { GameState.shared.setFlag(flag) }
        let body = inter.cartridgeData ?? "CARTRIDGE DATA CORRUPTED."
        let node = interactableNodes[inter.id]
        node?.alpha = 0.25
        showContentPanel(header: "DATA CARTRIDGE", body: body) { [weak node] in
            node?.removeFromParent()
        }
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
Codes derived from active case
reference numbers. Consult your
desk files for the sequence.
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
        default:
            return "TERMINAL ACCESS GRANTED.\nNo additional data available."
        }
    }

    // MARK: - Content Panel

    private func showContentPanel(header: String, body: String,
                                  onClose: @escaping () -> Void) {
        guard activePanel == nil else { return }

        let cam = SceneLayout.makeCamera(scene: self)
        let panelW = cam.w * 0.72
        let panelH = cam.h * 0.72

        let panel = SKNode()
        panel.zPosition = 2500

        let bg = SKSpriteNode(color: DLOColor.terminalBG,
                              size: CGSize(width: panelW, height: panelH))
        bg.alpha = 0.97
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: panelH - 2),
                                 cornerRadius: 4)
        border.strokeColor = DLOColor.teal
        border.lineWidth = 1.5
        border.fillColor = .clear
        panel.addChild(border)

        let headerLbl = DLOFont.terminalLabel(text: "[ \(header) ]", size: 11)
        headerLbl.horizontalAlignmentMode = .center
        headerLbl.position = CGPoint(x: 0, y: panelH / 2 - 22)
        panel.addChild(headerLbl)

        let divider = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.4),
                                   size: CGSize(width: panelW - 24, height: 1))
        divider.position = CGPoint(x: 0, y: panelH / 2 - 36)
        panel.addChild(divider)

        let bodyLbl = SKLabelNode(text: body)
        bodyLbl.fontName = "Menlo"
        bodyLbl.fontSize = 9
        bodyLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.9)
        bodyLbl.horizontalAlignmentMode = .center
        bodyLbl.verticalAlignmentMode = .top
        bodyLbl.numberOfLines = 0
        bodyLbl.preferredMaxLayoutWidth = panelW - 40
        bodyLbl.position = CGPoint(x: 0, y: panelH / 2 - 46)
        panel.addChild(bodyLbl)

        let closeBtn = PanelButtonNode(label: "[ CLOSE ]") { [weak self] in
            panel.removeFromParent()
            self?.activePanel = nil
            onClose()
        }
        closeBtn.position = CGPoint(x: 0, y: -panelH / 2 + 24)
        panel.addChild(closeBtn)

        activePanel = panel
        cameraNode.addChild(panel)
    }

    // MARK: - Code Entry Panel

    private func showCodePad(for inter: Interactable) {
        guard activePanel == nil else { return }

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

        let headerLbl = DLOFont.terminalLabel(text: "ACCESS CODE REQUIRED", size: 10)
        headerLbl.horizontalAlignmentMode = .center
        headerLbl.position = CGPoint(x: 0, y: panelH / 2 - 22)
        panel.addChild(headerLbl)

        let codeDisplay = SKLabelNode(text: "_ _ _ _")
        codeDisplay.fontName = "Menlo-Bold"
        codeDisplay.fontSize = 22
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
                        panel.removeFromParent()
                        self.activePanel = nil
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
            panel.removeFromParent()
            self?.activePanel = nil
        }
        cancelBtn.position = CGPoint(x: 0, y: -panelH / 2 + 20)
        panel.addChild(cancelBtn)

        activePanel = panel
        cameraNode.addChild(panel)
    }

    // MARK: - Brief Message Toast

    private func showBriefMessage(_ text: String) {
        let cam = SceneLayout.makeCamera(scene: self)
        let lbl = DLOFont.terminalLabel(text: text, size: 10)
        lbl.horizontalAlignmentMode = .center
        lbl.fontColor = DLOColor.danger
        lbl.position = CGPoint(x: cam.midX, y: cam.midY + 30)
        lbl.zPosition = 2000
        overlayNode.addChild(lbl)
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
            cameraNode.addChild(flash)
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
        cameraNode.addChild(overlay)

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
        for touch in touches {
            let camPos = camSpacePoint(from: touch)

            // Pause button works regardless of game state
            if pauseButtonRect.contains(camPos) {
                if isGamePaused { hidePauseMenu() } else { showPauseMenu() }
                return
            }

            if isGamePaused || isInteractionPaused { continue }

            // All touches forwarded to VirtualPad (interact is on the right cluster)
            virtualPad.notifyTouchBegan(touch, at: touch.location(in: virtualPad))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused, !isInteractionPaused else { return }
        for touch in touches {
            virtualPad.notifyTouchMoved(touch, at: touch.location(in: virtualPad))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { virtualPad.notifyTouchEnded(touch) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { virtualPad.notifyTouchCancelled(touch) }
    }

    private func camSpacePoint(from touch: UITouch) -> CGPoint {
        let s = touch.location(in: self)
        return CGPoint(x: s.x - cameraNode.position.x, y: s.y - cameraNode.position.y)
    }

    // MARK: - Pause Menu

    private func showPauseMenu() {
        guard pauseMenuNode == nil else { return }
        isGamePaused = true

        let cam = SceneLayout.makeCamera(scene: self)
        let panelW = min(cam.w * 0.68, 380)
        let panelH = min(cam.h * 0.72, 320)

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

        let hdr = DLOFont.titleLabel(text: "SHIFT PAUSED", size: 14)
        hdr.horizontalAlignmentMode = .center
        hdr.position = CGPoint(x: 0, y: panelH / 2 - 28)
        panel.addChild(hdr)

        let div = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                               size: CGSize(width: panelW - 32, height: 1))
        div.position = CGPoint(x: 0, y: panelH / 2 - 44)
        panel.addChild(div)

        let btnLabels: [(String, () -> Void)] = [
            ("[ RESUME ]",                  { [weak self] in self?.hidePauseMenu() }),
            ("[ SAVE + RETURN TO MENU ]",   { [weak self] in
                GameState.shared.save()
                self?.hidePauseMenu()
                SceneManager.shared.transition(to: .mainMenu, from: self!) }),
            ("[ RETURN WITHOUT SAVING ]",   { [weak self] in
                self?.hidePauseMenu()
                SceneManager.shared.transition(to: .mainMenu, from: self!) }),
            ("[ SETTINGS ]",                { [weak self] in
                SceneManager.shared.transition(to: .settings, from: self!) })
        ]

        let btnStep: CGFloat = 52
        let topBtnY: CGFloat = panelH / 2 - 80
        for (i, (label, action)) in btnLabels.enumerated() {
            let btn = PanelButtonNode(label: label, action: action)
            btn.position = CGPoint(x: 0, y: topBtnY - CGFloat(i) * btnStep)
            panel.addChild(btn)
        }

        pauseMenuNode = panel
        cameraNode.addChild(panel)
    }

    private func hidePauseMenu() {
        isGamePaused = false
        pauseMenuNode?.removeFromParent()
        pauseMenuNode = nil
        virtualPad?.resetInput()
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

    func configure(for type: String) {
        switch type {
        case "terminal":  lbl.text = "▲  READ TERMINAL"
        case "door":      lbl.text = "▲  OPEN DOOR"
        case "cartridge": lbl.text = "▲  RETRIEVE"
        case "npc":       lbl.text = "▲  TALK"
        default:          lbl.text = "▲  INTERACT"
        }
    }
}

// MARK: - Panel Button (CLOSE / CANCEL)

private final class PanelButtonNode: SKNode {
    private let action: () -> Void
    private static let btnSize = CGSize(width: 140, height: 32)

    init(label: String, action: @escaping () -> Void) {
        self.action = action
        super.init()
        isUserInteractionEnabled = true

        let bg = SKShapeNode(rectOf: PanelButtonNode.btnSize, cornerRadius: 4)
        bg.fillColor = DLOColor.uiBorder.withAlphaComponent(0.25)
        bg.strokeColor = DLOColor.uiBorder
        bg.lineWidth = 1.2
        addChild(bg)

        let lbl = DLOFont.terminalLabel(text: label, size: 11)
        lbl.horizontalAlignmentMode = .center
        lbl.fontColor = DLOColor.terminalAmber
        lbl.position = CGPoint(x: 0, y: -4)
        addChild(lbl)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func calculateAccumulatedFrame() -> CGRect {
        let s = PanelButtonNode.btnSize
        return CGRect(x: position.x - s.width / 2, y: position.y - s.height / 2,
                      width: s.width, height: s.height)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 0.7 }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1.0; action()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { alpha = 1.0 }
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

