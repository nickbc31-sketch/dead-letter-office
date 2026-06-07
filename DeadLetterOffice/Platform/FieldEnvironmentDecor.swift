import SpriteKit

/// Non-colliding field scenery — depth without platforming requirements.
enum FieldEnvironmentDecor {

    static func addToScene(_ scene: SKScene, levelID: String, width: CGFloat) {
        let root = SKNode()
        root.name = "fieldDecor"
        root.zPosition = 8

        switch levelID {
        case "level_ch1":
            addCh1Decor(to: root, width: width)
        case "level_ch2":
            addCh2Decor(to: root, width: width)
        case "level_ch3":
            addCh3Decor(to: root, width: width)
        case "level_ch1_checkpoint_interior":
            addCheckpointInteriorDecor(to: root, width: width)
        default:
            break
        }
        scene.addChild(root)
    }

    // MARK: - Shared primitives

    private static func relayMast(at x: CGFloat) -> SKNode {
        let mast = SKNode()
        mast.position = CGPoint(x: x, y: 40)
        let pole = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                                size: CGSize(width: 5, height: 90))
        pole.position = CGPoint(x: 0, y: 45)
        mast.addChild(pole)
        let dish = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.3),
                                size: CGSize(width: 22, height: 10))
        dish.position = CGPoint(x: 0, y: 88)
        mast.addChild(dish)
        return mast
    }

    private static func barrier(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        for i in 0..<3 {
            let stripe = SKSpriteNode(
                color: i % 2 == 0 ? DLOColor.terminalAmber.withAlphaComponent(0.5) : .clear,
                size: CGSize(width: 14, height: 28))
            stripe.position = CGPoint(x: CGFloat(i) * 14 - 14, y: 14)
            node.addChild(stripe)
        }
        return node
    }

    private static func dumpster(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        let body = SKSpriteNode(color: SKColor(white: 0.12, alpha: 0.9),
                                size: CGSize(width: 36, height: 22))
        body.position = CGPoint(x: 0, y: 11)
        node.addChild(body)
        return node
    }

    private static func apartmentFacade(at x: CGFloat, floors: Int = 3) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        let w: CGFloat = 90
        let h = CGFloat(floors) * 28 + 16
        let wall = SKSpriteNode(color: DLOColor.platformSilhouette.withAlphaComponent(0.55),
                                size: CGSize(width: w, height: h))
        wall.position = CGPoint(x: 0, y: h / 2)
        node.addChild(wall)
        for f in 0..<floors {
            for c in 0..<3 {
                let lit = (f + c) % 3 != 0
                let win = SKSpriteNode(
                    color: lit ? DLOColor.terminalAmber.withAlphaComponent(0.22) : .clear,
                    size: CGSize(width: 10, height: 12))
                win.position = CGPoint(x: CGFloat(c - 1) * 24, y: 20 + CGFloat(f) * 28)
                node.addChild(win)
            }
        }
        return node
    }

    private static func cameraPost(at x: CGFloat) -> SKNode {
        let post = SKNode()
        post.position = CGPoint(x: x, y: 40)
        let pole = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.45),
                                size: CGSize(width: 4, height: 56))
        pole.position = CGPoint(x: 0, y: 28)
        post.addChild(pole)
        return post
    }

    private static func pmcaTerminalKiosk(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        node.addChild(FieldInvestigationVisuals.pmcaFieldTerminal())
        return node
    }

    // MARK: - Chapter layouts

    private static func addCh1Decor(to root: SKNode, width: CGFloat) {
        root.addChild(relayMast(at: 1550))
        root.addChild(barrier(at: 1980))
        root.addChild(dumpster(at: 280))
        root.addChild(dumpster(at: 1100))
        root.addChild(pmcaTerminalKiosk(at: 340))
    }

    private static func addCh2Decor(to root: SKNode, width: CGFloat) {
        root.addChild(relayMast(at: 560))
        root.addChild(relayMast(at: 1780))
        root.addChild(relayMast(at: 3650))
        root.addChild(barrier(at: 3100))
        root.addChild(barrier(at: 3350))
        root.addChild(dumpster(at: 480))
        root.addChild(dumpster(at: 1420))
        root.addChild(dumpster(at: 2200))
        root.addChild(cameraPost(at: 3180))
        root.addChild(pmcaTerminalKiosk(at: 950))
        root.addChild(pmcaTerminalKiosk(at: 3650))
    }

    private static func addCh3Decor(to root: SKNode, width: CGFloat) {
        root.addChild(apartmentFacade(at: 480, floors: 4))
        root.addChild(apartmentFacade(at: 1050, floors: 3))
        root.addChild(apartmentFacade(at: 1680, floors: 4))
        root.addChild(apartmentFacade(at: 3600, floors: 3))
        root.addChild(marrApartmentEntrance(at: 2680))
        root.addChild(residentDirectory(at: 420))
        root.addChild(mailboxRow(at: 1150))
        root.addChild(maintenanceCabinetDecor(at: 2550))
        root.addChild(pmcaSealGate(at: 2480))
        root.addChild(utilityJunction(at: 2100))
        root.addChild(securityCheckpointDecor(at: 2400))
        root.addChild(barrier(at: 2480))
        root.addChild(barrier(at: 2680))
        root.addChild(dumpster(at: 820))
        root.addChild(dumpster(at: 1920))
        root.addChild(cameraPost(at: 2480))
        root.addChild(cameraPost(at: 2100))
        root.addChild(pmcaTerminalKiosk(at: 1280))
    }

    private static func marrApartmentEntrance(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        let frame = SKSpriteNode(color: DLOColor.platformSilhouette.withAlphaComponent(0.6),
                                 size: CGSize(width: 48, height: 58))
        frame.position = CGPoint(x: 0, y: 29)
        node.addChild(frame)
        let door = SKSpriteNode(color: SKColor(red: 0.10, green: 0.12, blue: 0.11, alpha: 1),
                                size: CGSize(width: 28, height: 40))
        door.position = CGPoint(x: 0, y: 24)
        node.addChild(door)
        let seal = DLOFont.terminalLabel(text: "APT 312 — SEALED", size: 5)
        seal.fontColor = DLOColor.danger.withAlphaComponent(0.75)
        seal.position = CGPoint(x: 0, y: 62)
        node.addChild(seal)
        return node
    }

    private static func residentDirectory(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        let panel = SKSpriteNode(color: SKColor(red: 0.14, green: 0.15, blue: 0.13, alpha: 1),
                                 size: CGSize(width: 36, height: 48))
        panel.position = CGPoint(x: 0, y: 24)
        node.addChild(panel)
        let lbl = DLOFont.terminalLabel(text: "RESIDENT\nDIRECTORY", size: 5)
        lbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.7)
        lbl.numberOfLines = 2
        lbl.position = CGPoint(x: 0, y: 28)
        node.addChild(lbl)
        return node
    }

    private static func mailboxRow(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        for i in 0..<5 {
            let box = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.4),
                                   size: CGSize(width: 10, height: 14))
            box.position = CGPoint(x: CGFloat(i - 2) * 14, y: 10)
            node.addChild(box)
        }
        let lbl = DLOFont.terminalLabel(text: "MAILBOXES", size: 5)
        lbl.fontColor = DLOColor.dimText
        lbl.position = CGPoint(x: 0, y: 22)
        node.addChild(lbl)
        return node
    }

    private static func maintenanceCabinetDecor(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        node.addChild(FieldInvestigationVisuals.maintenanceCabinet())
        return node
    }

    private static func pmcaSealGate(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        let gateL = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.5),
                                 size: CGSize(width: 4, height: 52))
        gateL.position = CGPoint(x: -18, y: 26)
        node.addChild(gateL)
        let gateR = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.5),
                                 size: CGSize(width: 4, height: 52))
        gateR.position = CGPoint(x: 18, y: 26)
        node.addChild(gateR)
        let bar = SKSpriteNode(color: DLOColor.danger.withAlphaComponent(0.45),
                               size: CGSize(width: 36, height: 3))
        bar.position = CGPoint(x: 0, y: 44)
        node.addChild(bar)
        let lbl = DLOFont.terminalLabel(text: "PMCA SEAL", size: 5)
        lbl.fontColor = DLOColor.danger.withAlphaComponent(0.7)
        lbl.position = CGPoint(x: 0, y: 56)
        node.addChild(lbl)
        return node
    }

    private static func utilityJunction(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        let box = SKSpriteNode(color: SKColor(red: 0.12, green: 0.13, blue: 0.12, alpha: 1),
                               size: CGSize(width: 32, height: 24))
        box.position = CGPoint(x: 0, y: 12)
        node.addChild(box)
        let lbl = DLOFont.terminalLabel(text: "UTILITY", size: 5)
        lbl.fontColor = DLOColor.dimText
        lbl.position = CGPoint(x: 0, y: 30)
        node.addChild(lbl)
        return node
    }

    private static func securityCheckpointDecor(at x: CGFloat) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: x, y: 40)
        let post = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.45),
                                size: CGSize(width: 6, height: 40))
        post.position = CGPoint(x: 0, y: 20)
        node.addChild(post)
        let lbl = DLOFont.terminalLabel(text: "CHECKPOINT", size: 5)
        lbl.fontColor = DLOColor.danger.withAlphaComponent(0.65)
        lbl.position = CGPoint(x: 0, y: 46)
        node.addChild(lbl)
        return node
    }

    private static func addCheckpointInteriorDecor(to root: SKNode, width: CGFloat) {
        let stack = SKSpriteNode(color: DLOColor.platformSilhouette.withAlphaComponent(0.4),
                                 size: CGSize(width: 40, height: 70))
        stack.position = CGPoint(x: 440, y: 75)
        root.addChild(stack)
        let accessPort = FieldInvestigationVisuals.networkAccessNode()
        accessPort.position = CGPoint(x: 420, y: 40)
        root.addChild(accessPort)
        let blink = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.4),
                                 size: CGSize(width: 4, height: 4))
        blink.position = CGPoint(x: 448, y: 100)
        root.addChild(blink)
        blink.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.1, duration: 0.8),
            SKAction.fadeAlpha(to: 0.7, duration: 0.8),
        ])))
    }
}
