import SpriteKit

/// Procedural exterior shells for platform investigation buildings.
enum PlatformBuildingVisuals {

    static func build(preset: String, spec: BuildingVisualSpec, at pos: CGPoint,
                      screenWidth: CGFloat) -> SKNode {
        let size = spec.resolvedSize(screenWidth: screenWidth)
        switch preset {
        case "relay_depot":
            return buildRelayDepot(at: pos, width: size.width, height: size.height)
        case "checkpoint":
            return buildCheckpoint(at: pos, width: size.width, height: size.height)
        default:
            return buildGenericUtility(at: pos, width: size.width, height: size.height)
        }
    }

    // MARK: - Palette

    private static let shellMetal  = SKColor(red: 0.09, green: 0.12, blue: 0.17, alpha: 1)
    private static let panelMetal  = SKColor(red: 0.06, green: 0.09, blue: 0.13, alpha: 1)
    private static let roofMetal   = SKColor(red: 0.07, green: 0.10, blue: 0.15, alpha: 1)
    private static let conduit     = SKColor(white: 0.14, alpha: 0.75)

    // MARK: - Relay depot (wide PMCA utility station — roofline meets gantry deck)

    private static func buildRelayDepot(at pos: CGPoint, width w: CGFloat, height h: CGFloat) -> SKNode {
        let depot = SKNode()
        depot.position = CGPoint(x: pos.x, y: 40)
        depot.zPosition = 19

        // Foundation lip
        let foundation = SKSpriteNode(color: SKColor(white: 0.04, alpha: 1),
                                      size: CGSize(width: w + 20, height: 8))
        foundation.anchorPoint = CGPoint(x: 0.5, y: 0)
        depot.addChild(foundation)

        // Main shell — stepped facade (centre bay recessed)
        let wingW = w * 0.36
        let bayW = w - wingW * 2
        addFacadeWing(to: depot, width: wingW, height: h, x: -w / 2 + wingW / 2)
        addFacadeWing(to: depot, width: wingW, height: h, x: w / 2 - wingW / 2)
        let centre = SKSpriteNode(color: shellMetal,
                                  size: CGSize(width: bayW, height: h - 6))
        centre.anchorPoint = CGPoint(x: 0.5, y: 0)
        centre.position = CGPoint(x: 0, y: 6)
        depot.addChild(centre)

        // Roof deck — aligns with gantry walk height (~y 120 from floor top at 40)
        let roofDeck = SKSpriteNode(color: roofMetal, size: CGSize(width: w + 24, height: 12))
        roofDeck.anchorPoint = CGPoint(x: 0.5, y: 0)
        roofDeck.position = CGPoint(x: 0, y: h)
        depot.addChild(roofDeck)

        // Roof catwalk rail
        let rail = SKSpriteNode(color: SKColor(white: 0.18, alpha: 0.55),
                                size: CGSize(width: w + 8, height: 3))
        rail.anchorPoint = CGPoint(x: 0.5, y: 0)
        rail.position = CGPoint(x: 0, y: h + 10)
        depot.addChild(rail)

        // Roof equipment — vents, relay humps, conduit runs
        let humpCount = max(4, Int(w / 75))
        let humpSpacing = (w - 50) / CGFloat(max(1, humpCount - 1))
        for i in 0..<humpCount {
            let hx = -w / 2 + 25 + CGFloat(i) * humpSpacing
            addRoofVent(to: depot, at: CGPoint(x: hx, y: h + 12), wide: i % 3 == 0)
        }

        // Horizontal conduit along facade
        for yOff: CGFloat in [h * 0.45, h * 0.72] {
            let pipe = SKSpriteNode(color: conduit, size: CGSize(width: w - 20, height: 4))
            pipe.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            pipe.position = CGPoint(x: 0, y: yOff)
            depot.addChild(pipe)
        }

        // Vertical conduit drops at quarter points
        for fx: CGFloat in [-0.38, 0.38] {
            let drop = SKSpriteNode(color: conduit, size: CGSize(width: 5, height: h * 0.55))
            drop.anchorPoint = CGPoint(x: 0.5, y: 0)
            drop.position = CGPoint(x: w * fx, y: 14)
            depot.addChild(drop)
        }

        // Maintenance panels + amber hazard stripe
        let hazard = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.85),
                                  size: CGSize(width: w - 16, height: 5))
        hazard.anchorPoint = CGPoint(x: 0.5, y: 0)
        hazard.position = CGPoint(x: 0, y: h - 22)
        depot.addChild(hazard)

        // Central maintenance door
        let doorW = min(40, w * 0.1)
        let doorH = h - 14
        addIndustrialDoor(to: depot, width: doorW, height: doorH, x: 0, y: 8)

        // Warning lights along roofline
        let lightCount = max(6, Int(w / 48))
        let lightSpacing = (w - 36) / CGFloat(max(1, lightCount - 1))
        for i in 0..<lightCount {
            let light = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.7),
                                     size: CGSize(width: 6, height: 5))
            light.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            light.position = CGPoint(x: -w / 2 + 18 + CGFloat(i) * lightSpacing, y: h - 4)
            depot.addChild(light)
            if i % 2 == 0 {
                light.run(blinkAction(min: 0.25, max: 0.9, duration: 1.1))
            }
        }

        // Repeater mast + dish
        addRepeaterMast(to: depot, at: CGPoint(x: w * 0.36, y: h + 12))

        // Signage stack
        addSignage(to: depot, title: "PMCA RELAY STATION", sub: "NODE 7 — UTILITY DEPOT",
                   y: h - 10, size: w)

        return depot
    }

    // MARK: - Checkpoint (fortified destination — taller, heavier than relay)

    private static func buildCheckpoint(at pos: CGPoint, width w: CGFloat, height h: CGFloat) -> SKNode {
        let gate = SKNode()
        gate.position = CGPoint(x: pos.x, y: 40)
        gate.zPosition = 19

        // Wide foundation plinth
        let plinth = SKSpriteNode(color: SKColor(white: 0.03, alpha: 1),
                                  size: CGSize(width: w + 36, height: 12))
        plinth.anchorPoint = CGPoint(x: 0.5, y: 0)
        gate.addChild(plinth)

        // Main bastion — tapered silhouette via side buttresses
        let core = SKSpriteNode(color: shellMetal, size: CGSize(width: w, height: h))
        core.anchorPoint = CGPoint(x: 0.5, y: 0)
        core.position = CGPoint(x: 0, y: 12)
        gate.addChild(core)

        for side: CGFloat in [-1, 1] {
            let buttress = SKSpriteNode(color: panelMetal,
                                        size: CGSize(width: 18, height: h - 20))
            buttress.anchorPoint = CGPoint(x: 0.5, y: 0)
            buttress.position = CGPoint(x: side * (w / 2 + 6), y: 16)
            gate.addChild(buttress)
        }

        // Armoured roof with overhang
        let roof = SKSpriteNode(color: roofMetal, size: CGSize(width: w + 28, height: 16))
        roof.anchorPoint = CGPoint(x: 0.5, y: 0)
        roof.position = CGPoint(x: 0, y: h + 12)
        gate.addChild(roof)

        // Searchlight bracket
        let bracket = SKSpriteNode(color: SKColor(white: 0.16, alpha: 0.8),
                                     size: CGSize(width: 20, height: 6))
        bracket.position = CGPoint(x: -w * 0.28, y: h + 20)
        gate.addChild(bracket)
        let lamp = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.5),
                                size: CGSize(width: 10, height: 8))
        lamp.position = CGPoint(x: -w * 0.28, y: h + 26)
        gate.addChild(lamp)
        lamp.run(blinkAction(min: 0.2, max: 0.75, duration: 2.0))

        // Restricted hazard bands
        for yOff: CGFloat in [h - 36, h - 52] {
            let band = SKSpriteNode(color: DLOColor.danger.withAlphaComponent(0.75),
                                    size: CGSize(width: w - 8, height: 5))
            band.anchorPoint = CGPoint(x: 0.5, y: 0)
            band.position = CGPoint(x: 0, y: yOff + 12)
            gate.addChild(band)
        }

        // Blast shutter slats above door
        let slatCount = 5
        for i in 0..<slatCount {
            let slat = SKSpriteNode(color: SKColor(white: 0.08, alpha: 0.9),
                                    size: CGSize(width: w * 0.35, height: 4))
            slat.position = CGPoint(x: 0, y: h - 18 - CGFloat(i) * 6 + 12)
            gate.addChild(slat)
        }

        // Fortified entry
        addIndustrialDoor(to: gate, width: 32, height: h - 36, x: 0, y: 20, reinforced: true)

        // Flanking barrier posts
        for side: CGFloat in [-1, 1] {
            let post = SKSpriteNode(color: SKColor(white: 0.10, alpha: 1),
                                    size: CGSize(width: 10, height: h - 40))
            post.anchorPoint = CGPoint(x: 0.5, y: 0)
            post.position = CGPoint(x: side * (w * 0.32), y: 20)
            gate.addChild(post)
            let cap = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.6),
                                   size: CGSize(width: 12, height: 6))
            cap.position = CGPoint(x: 0, y: h - 52)
            post.addChild(cap)
        }

        // PMCA crest block
        let crest = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1),
                                 size: CGSize(width: 48, height: 20))
        crest.position = CGPoint(x: 0, y: h - 8 + 12)
        gate.addChild(crest)
        let crestLbl = DLOFont.terminalLabel(text: "PMCA", size: 8)
        crestLbl.fontColor = DLOColor.terminalAmber
        crestLbl.position = CGPoint(x: 0, y: 0)
        crest.addChild(crestLbl)

        addSignage(to: gate, title: "INNER CHECKPOINT", sub: "ARCHIVE ACCESS — LEVEL 3",
                   y: h + 2, size: w, accent: DLOColor.danger.withAlphaComponent(0.9))

        return gate
    }

    // MARK: - Generic fallback

    private static func buildGenericUtility(at pos: CGPoint, width w: CGFloat, height h: CGFloat) -> SKNode {
        let booth = SKNode()
        booth.position = CGPoint(x: pos.x, y: 40)
        booth.zPosition = 19
        let shell = SKSpriteNode(color: shellMetal, size: CGSize(width: w, height: h))
        shell.anchorPoint = CGPoint(x: 0.5, y: 0)
        booth.addChild(shell)
        return booth
    }

    // MARK: - Shared primitives

    private static func addFacadeWing(to parent: SKNode, width w: CGFloat, height h: CGFloat, x: CGFloat) {
        let wing = SKSpriteNode(color: panelMetal, size: CGSize(width: w, height: h))
        wing.anchorPoint = CGPoint(x: 0.5, y: 0)
        wing.position = CGPoint(x: x, y: 0)
        parent.addChild(wing)
        // Maintenance panel inset
        let inset = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.11, alpha: 1),
                                 size: CGSize(width: w - 14, height: h - 30))
        inset.anchorPoint = CGPoint(x: 0.5, y: 0)
        inset.position = CGPoint(x: x, y: 8)
        parent.addChild(inset)
        // Vent grille
        let vent = SKSpriteNode(color: SKColor(white: 0.17, alpha: 0.5),
                                size: CGSize(width: w - 22, height: 5))
        vent.position = CGPoint(x: x, y: h - 28)
        parent.addChild(vent)
    }

    private static func addRoofVent(to parent: SKNode, at pos: CGPoint, wide: Bool) {
        let size = wide ? CGSize(width: 34, height: 16) : CGSize(width: 18, height: 12)
        let vent = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.11, alpha: 1), size: size)
        vent.anchorPoint = CGPoint(x: 0.5, y: 0)
        vent.position = pos
        parent.addChild(vent)
        let grill = SKSpriteNode(color: SKColor(white: 0.15, alpha: 0.45),
                                 size: CGSize(width: size.width - 6, height: 3))
        grill.position = CGPoint(x: 0, y: size.height - 4)
        vent.addChild(grill)
    }

    private static func addRepeaterMast(to parent: SKNode, at base: CGPoint) {
        let mast = SKSpriteNode(color: SKColor(white: 0.20, alpha: 0.75),
                                size: CGSize(width: 3, height: 28))
        mast.anchorPoint = CGPoint(x: 0.5, y: 0)
        mast.position = base
        parent.addChild(mast)
        let dish = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.4),
                                size: CGSize(width: 16, height: 9))
        dish.anchorPoint = CGPoint(x: 0.5, y: 0)
        dish.position = CGPoint(x: base.x, y: base.y + 26)
        parent.addChild(dish)
    }

    private static func addIndustrialDoor(to parent: SKNode, width w: CGFloat, height h: CGFloat,
                                          x: CGFloat, y: CGFloat, reinforced: Bool = false) {
        let frameColor = SKColor(white: 0.03, alpha: 1)
        let frame = SKSpriteNode(color: frameColor,
                                 size: CGSize(width: w + (reinforced ? 10 : 6), height: h))
        frame.anchorPoint = CGPoint(x: 0.5, y: 0)
        frame.position = CGPoint(x: x, y: y)
        parent.addChild(frame)

        let door = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.11, alpha: 1),
                                size: CGSize(width: w, height: h - 8))
        door.anchorPoint = CGPoint(x: 0.5, y: 0)
        door.position = CGPoint(x: x, y: y + 4)
        parent.addChild(door)

        if reinforced {
            let bolts = SKSpriteNode(color: SKColor(white: 0.12, alpha: 0.8),
                                     size: CGSize(width: w - 8, height: 2))
            bolts.position = CGPoint(x: x, y: y + h * 0.5)
            parent.addChild(bolts)
        }
    }

    private static func addSignage(to parent: SKNode, title: String, sub: String,
                                     y: CGFloat, size w: CGFloat,
                                     accent: SKColor = DLOColor.terminalAmber) {
        let plate = SKSpriteNode(color: SKColor(red: 0.04, green: 0.06, blue: 0.09, alpha: 0.9),
                                 size: CGSize(width: min(w - 20, 220), height: 28))
        plate.position = CGPoint(x: 0, y: y)
        parent.addChild(plate)

        let titleLbl = DLOFont.terminalLabel(text: title, size: min(10, w * 0.024))
        titleLbl.fontColor = accent
        titleLbl.horizontalAlignmentMode = .center
        titleLbl.position = CGPoint(x: 0, y: y + 4)
        parent.addChild(titleLbl)

        let subLbl = DLOFont.terminalLabel(text: sub, size: min(7, w * 0.018))
        subLbl.fontColor = DLOColor.dimText
        subLbl.horizontalAlignmentMode = .center
        subLbl.position = CGPoint(x: 0, y: y - 6)
        parent.addChild(subLbl)
    }

    private static func blinkAction(min: CGFloat, max: CGFloat, duration: TimeInterval) -> SKAction {
        SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: max, duration: duration),
            SKAction.fadeAlpha(to: min, duration: duration)
        ]))
    }
}

// MARK: - Field investigation interactables

/// Grounded field investigation interactable visuals (Ch1–8).
enum FieldInvestigationVisuals {

    // MARK: - PMCA Field Terminal (chest-height kiosk)

    static func pmcaFieldTerminal() -> SKNode {
        if let node = FieldSpriteAssets.groundedNode(named: "pmca_terminal", targetHeight: 56) {
            return node
        }
        return pmcaFieldTerminalProcedural()
    }

    // MARK: - Public Notice Board (distinct from terminals)

    static func publicNoticeBoard(label: String = "NOTICE") -> SKNode {
        if let board = FieldSpriteAssets.groundedSprite(named: "notice_board", targetHeight: 52) {
            let node = SKNode()
            node.addChild(board)
            if label != "NOTICE" {
                let tag = DLOFont.terminalLabel(text: label, size: 6)
                tag.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.85)
                tag.position = CGPoint(x: 0, y: 58)
                node.addChild(tag)
            }
            return node
        }
        return publicNoticeBoardProcedural(label: label)
    }

    static func informationNodeBeacon(label: String = "NOTICE") -> SKNode {
        publicNoticeBoard(label: label)
    }

    // MARK: - Network Access Node (PDA hack port)

    static func networkAccessNode() -> SKNode {
        if let node = FieldSpriteAssets.groundedNode(named: "pda_hack_port", targetHeight: 42) {
            return node
        }
        return networkAccessNodeProcedural()
    }

    // MARK: - Data Cache / file pickup

    static func dataCacheUnit() -> SKNode {
        if let node = FieldSpriteAssets.groundedNode(named: "data_cartridge", targetHeight: 26) {
            return node
        }
        return dataCacheUnitProcedural()
    }

    static func enforcementRobot() -> SKNode {
        let robot = SKNode()
        robot.name = "enforcement_robot"

        let bodyTop: CGFloat
        if let sprite = FieldSpriteAssets.groundedSprite(named: "enforcer_robot", targetHeight: 96) {
            robot.addChild(sprite)
            bodyTop = 96
        } else {
            let fallback = enforcementRobotBodyProcedural()
            robot.addChild(fallback)
            bodyTop = 48
        }

        let lbl = DLOFont.terminalLabel(text: "ENFORCER", size: 6)
        lbl.fontColor = DLOColor.danger.withAlphaComponent(0.8)
        lbl.position = CGPoint(x: 0, y: bodyTop + 14)
        robot.addChild(lbl)

        let cone = SKShapeNode()
        let conePath = CGMutablePath()
        conePath.move(to: CGPoint(x: 0, y: bodyTop * 0.5))
        conePath.addLine(to: CGPoint(x: -55, y: -72))
        conePath.addLine(to: CGPoint(x: 55, y: -72))
        conePath.closeSubpath()
        cone.path = conePath
        cone.fillColor = DLOColor.danger.withAlphaComponent(0.08)
        cone.strokeColor = DLOColor.danger.withAlphaComponent(0.25)
        cone.lineWidth = 1
        cone.zPosition = -1
        robot.addChild(cone)

        let warn = DLOFont.terminalLabel(text: "RESTRICTED", size: 5)
        warn.fontColor = DLOColor.danger.withAlphaComponent(0.65)
        warn.position = CGPoint(x: 0, y: bodyTop + 26)
        robot.addChild(warn)
        return robot
    }

    static func maintenanceCabinet() -> SKNode {
        if let node = FieldSpriteAssets.groundedNode(named: "maintenance_locker", targetHeight: 46) {
            return node
        }
        return maintenanceCabinetProcedural()
    }

    static func dataCartridgePedestal() -> SKNode {
        if let node = FieldSpriteAssets.groundedNode(named: "data_cartridge_2", targetHeight: 28) {
            return node
        }
        if let node = FieldSpriteAssets.groundedNode(named: "data_cartridge", targetHeight: 28) {
            return node
        }
        return dataCacheUnitProcedural()
    }

    static func civicNoticeBoard(label: String) -> SKNode {
        publicNoticeBoard(label: label)
    }

    // MARK: - Procedural fallbacks

    private static func pmcaFieldTerminalProcedural() -> SKNode {
        let node = SKNode()
        let base = SKSpriteNode(
            color: SKColor(red: 0.14, green: 0.16, blue: 0.18, alpha: 1),
            size: CGSize(width: 34, height: 8))
        base.position = CGPoint(x: 0, y: 4)
        node.addChild(base)

        let pedestal = SKSpriteNode(
            color: SKColor(red: 0.11, green: 0.13, blue: 0.15, alpha: 1),
            size: CGSize(width: 28, height: 38))
        pedestal.position = CGPoint(x: 0, y: 24)
        node.addChild(pedestal)

        let screen = SKSpriteNode(
            color: SKColor(red: 0.06, green: 0.18, blue: 0.22, alpha: 1),
            size: CGSize(width: 22, height: 16))
        screen.position = CGPoint(x: 0, y: 34)
        node.addChild(screen)

        let glow = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.35),
                                size: CGSize(width: 24, height: 2))
        glow.position = CGPoint(x: 0, y: 26)
        node.addChild(glow)
        glow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.15, duration: 1.2),
            SKAction.fadeAlpha(to: 0.55, duration: 1.2),
        ])))

        let tag = DLOFont.terminalLabel(text: "PMCA", size: 5)
        tag.fontColor = DLOColor.teal.withAlphaComponent(0.8)
        tag.position = CGPoint(x: 0, y: 48)
        node.addChild(tag)
        return node
    }

    private static func publicNoticeBoardProcedural(label: String) -> SKNode {
        let node = SKNode()
        let postL = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.45),
                                 size: CGSize(width: 4, height: 44))
        postL.position = CGPoint(x: -16, y: 22)
        node.addChild(postL)
        let postR = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.45),
                                 size: CGSize(width: 4, height: 44))
        postR.position = CGPoint(x: 16, y: 22)
        node.addChild(postR)

        let board = SKSpriteNode(
            color: SKColor(red: 0.18, green: 0.16, blue: 0.12, alpha: 1),
            size: CGSize(width: 38, height: 28))
        board.position = CGPoint(x: 0, y: 38)
        node.addChild(board)

        let pin = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.7),
                               size: CGSize(width: 4, height: 4))
        pin.position = CGPoint(x: 0, y: 50)
        node.addChild(pin)

        let tag = DLOFont.terminalLabel(text: label, size: 6)
        tag.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.85)
        tag.position = CGPoint(x: 0, y: 56)
        node.addChild(tag)
        return node
    }

    private static func networkAccessNodeProcedural() -> SKNode {
        let node = SKNode()
        let base = SKSpriteNode(
            color: SKColor(red: 0.12, green: 0.14, blue: 0.13, alpha: 1),
            size: CGSize(width: 30, height: 6))
        base.position = CGPoint(x: 0, y: 3)
        node.addChild(base)

        let housing = SKSpriteNode(
            color: SKColor(red: 0.14, green: 0.18, blue: 0.16, alpha: 1),
            size: CGSize(width: 24, height: 32))
        housing.position = CGPoint(x: 0, y: 20)
        node.addChild(housing)

        let port = SKSpriteNode(
            color: SKColor(red: 0.08, green: 0.22, blue: 0.18, alpha: 1),
            size: CGSize(width: 14, height: 10))
        port.position = CGPoint(x: 0, y: 26)
        node.addChild(port)

        let cable = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                                 size: CGSize(width: 2, height: 14))
        cable.position = CGPoint(x: 10, y: 14)
        node.addChild(cable)

        let lbl = DLOFont.terminalLabel(text: "PDA PORT", size: 5)
        lbl.fontColor = SKColor(red: 0.52, green: 0.74, blue: 0.62, alpha: 0.95)
        lbl.position = CGPoint(x: 0, y: 42)
        node.addChild(lbl)
        return node
    }

    private static func dataCacheUnitProcedural() -> SKNode {
        let node = SKNode()
        let base = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                                size: CGSize(width: 32, height: 6))
        base.position = CGPoint(x: 0, y: 3)
        node.addChild(base)

        let crate = SKSpriteNode(
            color: SKColor(red: 0.12, green: 0.14, blue: 0.13, alpha: 1),
            size: CGSize(width: 26, height: 22))
        crate.position = CGPoint(x: 0, y: 17)
        node.addChild(crate)

        let stripe = SKSpriteNode(color: DLOColor.terminalGreen.withAlphaComponent(0.45),
                                  size: CGSize(width: 26, height: 3))
        stripe.position = CGPoint(x: 0, y: 22)
        node.addChild(stripe)

        let tag = DLOFont.terminalLabel(text: "DATA CACHE", size: 5)
        tag.fontColor = DLOColor.terminalGreen.withAlphaComponent(0.85)
        tag.position = CGPoint(x: 0, y: 34)
        node.addChild(tag)
        return node
    }

    private static func enforcementRobotBodyProcedural() -> SKNode {
        let body = SKNode()
        let base = SKSpriteNode(color: SKColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1),
                                size: CGSize(width: 36, height: 14))
        base.position = CGPoint(x: 0, y: 7)
        body.addChild(base)

        let torso = SKSpriteNode(color: SKColor(red: 0.20, green: 0.20, blue: 0.24, alpha: 1),
                                 size: CGSize(width: 28, height: 44))
        torso.position = CGPoint(x: 0, y: 36)
        body.addChild(torso)

        let eye = SKShapeNode(circleOfRadius: 5)
        eye.fillColor = DLOColor.danger.withAlphaComponent(0.9)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 0, y: 48)
        body.addChild(eye)
        eye.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.6),
            SKAction.fadeAlpha(to: 1.0, duration: 0.6),
        ])))
        return body
    }

    private static func maintenanceCabinetProcedural() -> SKNode {
        let node = SKNode()
        let base = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.35),
                                size: CGSize(width: 30, height: 6))
        base.position = CGPoint(x: 0, y: 3)
        node.addChild(base)
        let door = SKSpriteNode(
            color: SKColor(red: 0.13, green: 0.15, blue: 0.14, alpha: 1),
            size: CGSize(width: 26, height: 36))
        door.position = CGPoint(x: 0, y: 22)
        node.addChild(door)
        let handle = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.6),
                                  size: CGSize(width: 3, height: 8))
        handle.position = CGPoint(x: 8, y: 22)
        node.addChild(handle)
        let tag = DLOFont.terminalLabel(text: "LOCKER", size: 5)
        tag.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.75)
        tag.position = CGPoint(x: 0, y: 44)
        node.addChild(tag)
        return node
    }
}
