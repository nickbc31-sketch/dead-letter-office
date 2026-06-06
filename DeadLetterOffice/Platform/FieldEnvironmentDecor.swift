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

    private static func backgroundGantry(at x: CGFloat, height: CGFloat = 100) -> SKNode {
        let gantry = SKNode()
        gantry.position = CGPoint(x: x, y: 40)
        let legL = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.25),
                                size: CGSize(width: 6, height: height))
        legL.position = CGPoint(x: -60, y: height / 2)
        gantry.addChild(legL)
        let legR = SKSpriteNode(color: DLOColor.uiBorder.withAlphaComponent(0.25),
                                size: CGSize(width: 6, height: height))
        legR.position = CGPoint(x: 60, y: height / 2)
        gantry.addChild(legR)
        let beam = SKSpriteNode(color: DLOColor.platformSilhouette.withAlphaComponent(0.35),
                                size: CGSize(width: 140, height: 8))
        beam.position = CGPoint(x: 0, y: height - 4)
        gantry.addChild(beam)
        return gantry
    }

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
                let win = SKSpriteNode(
                    color: Bool.random() ? DLOColor.terminalAmber.withAlphaComponent(0.25) : .clear,
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

    // MARK: - Chapter layouts

    private static func addCh1Decor(to root: SKNode, width: CGFloat) {
        root.addChild(backgroundGantry(at: 420))
        root.addChild(backgroundGantry(at: 1650))
        root.addChild(relayMast(at: 1550))
        root.addChild(barrier(at: 1980))
        root.addChild(dumpster(at: 280))
        root.addChild(dumpster(at: 1100))
    }

    private static func addCh2Decor(to root: SKNode, width: CGFloat) {
        for x in stride(from: 350, through: min(width - 200, 5200), by: 420) {
            root.addChild(backgroundGantry(at: x))
        }
        root.addChild(barrier(at: 3350))
        root.addChild(dumpster(at: 600))
        root.addChild(dumpster(at: 1800))
        root.addChild(relayMast(at: 4100))
        root.addChild(cameraPost(at: 3400))
    }

    private static func addCh3Decor(to root: SKNode, width: CGFloat) {
        root.addChild(apartmentFacade(at: 500, floors: 4))
        root.addChild(apartmentFacade(at: 1100, floors: 3))
        root.addChild(apartmentFacade(at: 2400, floors: 4))
        root.addChild(apartmentFacade(at: 3800, floors: 3))
        root.addChild(barrier(at: 2550))
        root.addChild(dumpster(at: 750))
        root.addChild(cameraPost(at: 2100))
        root.addChild(cameraPost(at: 2850))
    }

    private static func addCheckpointInteriorDecor(to root: SKNode, width: CGFloat) {
        let stack = SKSpriteNode(color: DLOColor.platformSilhouette.withAlphaComponent(0.4),
                                 size: CGSize(width: 40, height: 70))
        stack.position = CGPoint(x: 440, y: 75)
        root.addChild(stack)
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
