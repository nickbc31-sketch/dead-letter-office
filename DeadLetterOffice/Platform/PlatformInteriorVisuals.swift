import SpriteKit

/// Procedural interior dressing for platform investigation rooms (visual only).
enum PlatformInteriorVisuals {

    static func decorate(levelID: String, width: CGFloat, height: CGFloat, into scene: SKNode) {
        switch levelID {
        case "level_ch1_relay_interior":
            decorateRelayInterior(width: width, height: height, into: scene)
        case "level_ch1_checkpoint_interior":
            decorateCheckpointInterior(width: width, height: height, into: scene)
        default:
            break
        }
    }

    // MARK: - Relay utility interior

    private static func decorateRelayInterior(width: CGFloat, height: CGFloat, into scene: SKNode) {
        let floorH: CGFloat = 40
        let wallH = max(120, height - floorH - 20)
        let panel = SKColor(red: 0.06, green: 0.09, blue: 0.13, alpha: 1)

        // Wall panel grid — breaks up flat rectangle
        let cols = max(4, Int(width / 110))
        let colW = width / CGFloat(cols)
        for c in 0..<cols {
            let px = colW * CGFloat(c) + colW / 2
            let inset = SKSpriteNode(color: panel,
                                     size: CGSize(width: colW - 10, height: wallH - 24))
            inset.position = CGPoint(x: px, y: floorH + wallH / 2)
            inset.zPosition = 18.2
            scene.addChild(inset)
        }

        // Ceiling cable tray
        let tray = SKSpriteNode(color: SKColor(white: 0.14, alpha: 0.85),
                                size: CGSize(width: width - 40, height: 6))
        tray.position = CGPoint(x: width / 2, y: floorH + wallH - 8)
        tray.zPosition = 19
        scene.addChild(tray)
        for i in 0..<5 {
            let drop = SKSpriteNode(color: SKColor(white: 0.18, alpha: 0.6),
                                    size: CGSize(width: 3, height: CGFloat(18 + i * 6)))
            drop.anchorPoint = CGPoint(x: 0.5, y: 1)
            drop.position = CGPoint(x: 80 + CGFloat(i) * 95, y: floorH + wallH - 8)
            drop.zPosition = 19
            scene.addChild(drop)
        }

        // Relay equipment rack — centre-back
        addEquipmentRack(at: CGPoint(x: 160, y: floorH), into: scene, z: 19.5)
        addEquipmentRack(at: CGPoint(x: 230, y: floorH), into: scene, z: 19.5, compact: true)

        // Maintenance locker bank — right wall
        for i in 0..<3 {
            addLocker(at: CGPoint(x: width - 70 - CGFloat(i) * 34, y: floorH + 4),
                      into: scene, number: i + 1)
        }

        // Floor hazard marking
        let stripe = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.35),
                                  size: CGSize(width: width - 60, height: 3))
        stripe.position = CGPoint(x: width / 2, y: floorH + 2)
        stripe.zPosition = 19
        scene.addChild(stripe)

        // PMCA notices
        addWallNotice(text: "PMCA — RELAY NODE 7\nMAINTENANCE ACCESS ONLY",
                      at: CGPoint(x: 55, y: floorH + wallH - 36), into: scene)
        addWallNotice(text: "WARNING — LIVE ROUTING BUFFER\nAUTHORISED PERSONNEL ONLY",
                      at: CGPoint(x: width - 55, y: floorH + wallH - 36), into: scene,
                      accent: DLOColor.danger.withAlphaComponent(0.9))

        // Quiet Choir breadcrumb — scratched routing tag on locker
        let choirTag = DLOFont.terminalLabel(text: "7 → ?", size: 7)
        choirTag.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.45)
        choirTag.position = CGPoint(x: width - 88, y: floorH + 52)
        choirTag.zPosition = 20
        choirTag.zRotation = -0.08
        scene.addChild(choirTag)
    }

    // MARK: - Checkpoint interior

    private static func decorateCheckpointInterior(width: CGFloat, height: CGFloat, into scene: SKNode) {
        let floorH: CGFloat = 40
        let wallH = max(120, height - floorH - 20)

        // Reinforced wall ribs
        for x in stride(from: CGFloat(40), through: width - 40, by: 90) {
            let rib = SKSpriteNode(color: SKColor(red: 0.05, green: 0.07, blue: 0.11, alpha: 1),
                                   size: CGSize(width: 8, height: wallH - 16))
            rib.position = CGPoint(x: x, y: floorH + wallH / 2)
            rib.zPosition = 18.3
            scene.addChild(rib)
        }

        // Security camera domes
        for x: CGFloat in [100, width - 100] {
            if let cam = FieldSpriteAssets.groundedSprite(named: "security_camera", targetHeight: 28) {
                cam.position = CGPoint(x: x, y: floorH + wallH - 46)
                cam.zPosition = 20
                scene.addChild(cam)
            } else {
                let fallback = SKShapeNode(circleOfRadius: 6)
                fallback.fillColor = SKColor(white: 0.12, alpha: 1)
                fallback.strokeColor = DLOColor.terminalAmber.withAlphaComponent(0.5)
                fallback.lineWidth = 1
                fallback.position = CGPoint(x: x, y: floorH + wallH - 18)
                fallback.zPosition = 20
                scene.addChild(fallback)
            }
        }

        // Archive hardware cabinets — left
        for i in 0..<2 {
            addArchiveCabinet(at: CGPoint(x: 70 + CGFloat(i) * 48, y: floorH),
                              into: scene)
        }

        // Buffer routing panel — right (Choir infrastructure hint)
        addBufferPanel(at: CGPoint(x: width - 95, y: floorH + 20), into: scene)

        // Restricted floor path
        let path = SKSpriteNode(color: DLOColor.danger.withAlphaComponent(0.25),
                                size: CGSize(width: 80, height: width * 0.55))
        path.zRotation = .pi / 2
        path.position = CGPoint(x: width / 2, y: floorH + 8)
        path.zPosition = 18.5
        scene.addChild(path)

        addWallNotice(text: "RESTRICTED — CLEARANCE LEVEL 3\nARCHIVE RELAY ACCESS",
                      at: CGPoint(x: width / 2, y: floorH + wallH - 30), into: scene,
                      accent: DLOColor.terminalAmber, wide: true)
        addWallNotice(text: "UNREGISTERED ROUTING TAGS\nREPORT TO SUPERVISOR",
                      at: CGPoint(x: width - 60, y: floorH + 70), into: scene,
                      accent: DLOColor.dimText)
    }

    // MARK: - Interactable backdrops (interior props behind gameplay nodes)

    static func backdrop(for inter: Interactable, levelID: String) -> SKNode? {
        let floorH: CGFloat = 40
        switch (levelID, inter.type, inter.id) {
        case ("level_ch1_relay_interior", "terminal", "relay_console_01"):
            return consoleDesk(width: 72, height: 58, at: floorH)
        case ("level_ch1_relay_interior", "cabinet", "relay_cabinet_01"):
            return lockerUnit(width: 40, height: 64, at: floorH, label: "MNT-07")
        case ("level_ch1_relay_interior", "building_exit", "relay_building_exit"):
            return exitFrame(width: 36, height: 70, at: floorH)
        case ("level_ch1_checkpoint_interior", "door", "checkpoint_code_door"):
            return fortifiedDoor(width: 44, height: 76, at: floorH)
        case ("level_ch1_checkpoint_interior", "security_override", "checkpoint_security_override"):
            return overridePort(width: 52, height: 62, at: floorH)
        case ("level_ch1_checkpoint_interior", "building_exit", "checkpoint_building_exit"):
            return exitFrame(width: 36, height: 70, at: floorH)
        default:
            return nil
        }
    }

    // MARK: - Primitives

    private static func addEquipmentRack(at pos: CGPoint, into scene: SKNode,
                                         z: CGFloat, compact: Bool = false) {
        let w: CGFloat = compact ? 48 : 58
        let h: CGFloat = compact ? 72 : 88
        let rack = SKNode()
        rack.position = pos
        rack.zPosition = z

        let frame = SKSpriteNode(color: SKColor(red: 0.07, green: 0.10, blue: 0.14, alpha: 1),
                                 size: CGSize(width: w, height: h))
        frame.anchorPoint = CGPoint(x: 0.5, y: 0)
        rack.addChild(frame)

        let bays = compact ? 3 : 4
        for i in 0..<bays {
            let bay = SKSpriteNode(color: SKColor(white: 0.12, alpha: 0.9),
                                   size: CGSize(width: w - 10, height: 12))
            bay.anchorPoint = CGPoint(x: 0.5, y: 0)
            bay.position = CGPoint(x: 0, y: 10 + CGFloat(i) * 18)
            rack.addChild(bay)
            if i % 2 == 0 {
                let led = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.55),
                                       size: CGSize(width: 4, height: 4))
                led.position = CGPoint(x: w / 2 - 8, y: 16 + CGFloat(i) * 18)
                rack.addChild(led)
                led.run(blinkAction(min: 0.3, max: 0.85, duration: 1.4 + Double(i) * 0.2))
            }
        }
        scene.addChild(rack)
    }

    private static func addLocker(at pos: CGPoint, into scene: SKNode, number: Int) {
        if let locker = FieldSpriteAssets.groundedSprite(named: "maintenance_locker", targetHeight: 58) {
            locker.position = pos
            locker.zPosition = 19.5
            scene.addChild(locker)
            let num = DLOFont.terminalLabel(text: String(format: "%02d", number), size: 7)
            num.fontColor = DLOColor.dimText
            num.position = CGPoint(x: pos.x, y: pos.y + 28)
            num.zPosition = 19.6
            scene.addChild(num)
            return
        }

        let locker = SKSpriteNode(color: SKColor(red: 0.08, green: 0.11, blue: 0.15, alpha: 1),
                                  size: CGSize(width: 28, height: 58))
        locker.anchorPoint = CGPoint(x: 0.5, y: 0)
        locker.position = pos
        locker.zPosition = 19.5
        scene.addChild(locker)

        let vent = SKSpriteNode(color: SKColor(white: 0.2, alpha: 0.5),
                                size: CGSize(width: 18, height: 3))
        vent.position = CGPoint(x: 0, y: 48)
        locker.addChild(vent)

        let num = DLOFont.terminalLabel(text: String(format: "%02d", number), size: 7)
        num.fontColor = DLOColor.dimText
        num.position = CGPoint(x: 0, y: 28)
        locker.addChild(num)
    }

    private static func addWallNotice(text: String, at pos: CGPoint, into scene: SKNode,
                                      accent: SKColor = DLOColor.terminalAmber,
                                      wide: Bool = false) {
        let panelW: CGFloat = wide ? 200 : 130
        let bg = SKSpriteNode(color: SKColor(red: 0.05, green: 0.07, blue: 0.10, alpha: 0.92),
                              size: CGSize(width: panelW, height: 36))
        bg.position = pos
        bg.zPosition = 19.8
        scene.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: 34), cornerRadius: 2)
        border.strokeColor = accent.withAlphaComponent(0.6)
        border.lineWidth = 1
        border.fillColor = .clear
        border.position = pos
        border.zPosition = 19.9
        scene.addChild(border)

        let lines = text.split(separator: "\n")
        for (i, line) in lines.enumerated() {
            let lbl = DLOFont.terminalLabel(text: String(line), size: 6)
            lbl.fontColor = accent.withAlphaComponent(0.85)
            lbl.horizontalAlignmentMode = .center
            lbl.position = CGPoint(x: pos.x, y: pos.y + 6 - CGFloat(i) * 10)
            lbl.zPosition = 20
            scene.addChild(lbl)
        }
    }

    private static func addArchiveCabinet(at pos: CGPoint, into scene: SKNode) {
        let cab = SKSpriteNode(color: SKColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 1),
                               size: CGSize(width: 38, height: 70))
        cab.anchorPoint = CGPoint(x: 0.5, y: 0)
        cab.position = pos
        cab.zPosition = 19.5
        scene.addChild(cab)
        let lbl = DLOFont.terminalLabel(text: "ARCH", size: 6)
        lbl.fontColor = DLOColor.dimText
        lbl.position = CGPoint(x: 0, y: 40)
        cab.addChild(lbl)
    }

    private static func addBufferPanel(at pos: CGPoint, into scene: SKNode) {
        let panel = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.11, alpha: 1),
                                 size: CGSize(width: 64, height: 48))
        panel.position = pos
        panel.zPosition = 19.5
        scene.addChild(panel)
        let tag = DLOFont.terminalLabel(text: "BUFFER\nNODE 7", size: 6)
        tag.fontColor = DLOColor.teal.withAlphaComponent(0.7)
        tag.numberOfLines = 2
        tag.horizontalAlignmentMode = .center
        tag.verticalAlignmentMode = .center
        panel.addChild(tag)
    }

    private static func consoleDesk(width w: CGFloat, height h: CGFloat, at floor: CGFloat) -> SKNode {
        let desk = SKNode()
        desk.zPosition = 17
        let base = SKSpriteNode(color: SKColor(red: 0.07, green: 0.10, blue: 0.14, alpha: 1),
                                size: CGSize(width: w, height: h))
        base.anchorPoint = CGPoint(x: 0.5, y: 0)
        base.position = CGPoint(x: 0, y: floor)
        desk.addChild(base)
        let screen = SKSpriteNode(color: SKColor(white: 0.08, alpha: 1),
                                  size: CGSize(width: w - 16, height: 22))
        screen.position = CGPoint(x: 0, y: floor + h - 18)
        desk.addChild(screen)
        let glow = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.25),
                                size: CGSize(width: w - 20, height: 2))
        glow.position = CGPoint(x: 0, y: floor + h - 28)
        desk.addChild(glow)
        return desk
    }

    private static func lockerUnit(width w: CGFloat, height h: CGFloat,
                                   at floor: CGFloat, label: String) -> SKNode {
        let unit = SKNode()
        unit.zPosition = 17
        if let locker = FieldSpriteAssets.groundedSprite(named: "maintenance_locker", targetHeight: h) {
            locker.position = CGPoint(x: 0, y: floor)
            unit.addChild(locker)
            let plate = DLOFont.terminalLabel(text: label, size: 7)
            plate.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
            plate.position = CGPoint(x: 0, y: floor + h * 0.55)
            unit.addChild(plate)
            return unit
        }
        let body = SKSpriteNode(color: SKColor(red: 0.08, green: 0.11, blue: 0.15, alpha: 1),
                                size: CGSize(width: w, height: h))
        body.anchorPoint = CGPoint(x: 0.5, y: 0)
        body.position = CGPoint(x: 0, y: floor)
        unit.addChild(body)
        let plate = DLOFont.terminalLabel(text: label, size: 7)
        plate.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
        plate.position = CGPoint(x: 0, y: floor + h * 0.55)
        unit.addChild(plate)
        return unit
    }

    private static func exitFrame(width w: CGFloat, height h: CGFloat, at floor: CGFloat) -> SKNode {
        let frame = SKNode()
        frame.zPosition = 17
        let jamb = SKSpriteNode(color: SKColor(white: 0.06, alpha: 1),
                                size: CGSize(width: w + 8, height: h))
        jamb.anchorPoint = CGPoint(x: 0.5, y: 0)
        jamb.position = CGPoint(x: 0, y: floor)
        frame.addChild(jamb)
        return frame
    }

    private static func fortifiedDoor(width w: CGFloat, height h: CGFloat, at floor: CGFloat) -> SKNode {
        let door = SKNode()
        door.zPosition = 17
        if let archiveDoor = FieldSpriteAssets.groundedSprite(named: "archive_door", targetHeight: h) {
            archiveDoor.position = CGPoint(x: 0, y: floor)
            door.addChild(archiveDoor)
            if let keypadSprite = FieldSpriteAssets.groundedSprite(named: "keypad", targetHeight: 20) {
                keypadSprite.position = CGPoint(x: w / 2 - 4, y: floor + h * 0.45)
                door.addChild(keypadSprite)
            }
            return door
        }
        let plate = SKSpriteNode(color: SKColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 1),
                                 size: CGSize(width: w + 12, height: h + 6))
        plate.anchorPoint = CGPoint(x: 0.5, y: 0)
        plate.position = CGPoint(x: 0, y: floor)
        door.addChild(plate)
        let stripe = SKSpriteNode(color: DLOColor.danger.withAlphaComponent(0.7),
                                  size: CGSize(width: w, height: 4))
        stripe.position = CGPoint(x: 0, y: floor + h - 12)
        door.addChild(stripe)
        let keypad = SKSpriteNode(color: SKColor(white: 0.14, alpha: 1),
                                  size: CGSize(width: 14, height: 18))
        keypad.position = CGPoint(x: w / 2 - 4, y: floor + h / 2)
        door.addChild(keypad)
        return door
    }

    private static func overridePort(width w: CGFloat, height h: CGFloat, at floor: CGFloat) -> SKNode {
        let port = SKNode()
        port.zPosition = 17
        if let hackPort = FieldSpriteAssets.groundedSprite(named: "pda_hack_port", targetHeight: h) {
            hackPort.position = CGPoint(x: 0, y: floor)
            port.addChild(hackPort)
            return port
        }
        let housing = SKSpriteNode(color: SKColor(red: 0.09, green: 0.12, blue: 0.14, alpha: 1),
                                   size: CGSize(width: w, height: h))
        housing.anchorPoint = CGPoint(x: 0.5, y: 0)
        housing.position = CGPoint(x: 0, y: floor)
        port.addChild(housing)
        let slot = SKSpriteNode(color: SKColor(red: 0.18, green: 0.28, blue: 0.24, alpha: 1),
                                size: CGSize(width: 28, height: 10))
        slot.position = CGPoint(x: 0, y: floor + h * 0.55)
        port.addChild(slot)
        let lbl = DLOFont.terminalLabel(text: "PDA", size: 7)
        lbl.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 0.85)
        lbl.position = CGPoint(x: 0, y: floor + h * 0.3)
        port.addChild(lbl)
        return port
    }

    private static func blinkAction(min: CGFloat, max: CGFloat, duration: TimeInterval) -> SKAction {
        SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: max, duration: duration),
            SKAction.fadeAlpha(to: min, duration: duration)
        ]))
    }
}
