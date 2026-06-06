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

    // MARK: - Relay depot (wide, low PMCA utility station)

    private static func buildRelayDepot(at pos: CGPoint, width w: CGFloat, height h: CGFloat) -> SKNode {
        let depot = SKNode()
        depot.position = CGPoint(x: pos.x, y: 40)
        depot.zPosition = 19

        let metal = DLOColor.platformSilhouette
        let roofMetal = SKColor(red: 0.07, green: 0.10, blue: 0.15, alpha: 1)

        // Main mass — wide low warehouse profile
        let shell = SKSpriteNode(color: metal, size: CGSize(width: w, height: h))
        shell.anchorPoint = CGPoint(x: 0.5, y: 0)
        depot.addChild(shell)

        // Cantilevered roof lip
        let roof = SKSpriteNode(color: roofMetal, size: CGSize(width: w + 16, height: 10))
        roof.anchorPoint = CGPoint(x: 0.5, y: 0)
        roof.position = CGPoint(x: 0, y: h)
        depot.addChild(roof)

        // Roof equipment humps (relay hardware silhouette)
        let humpCount = max(3, Int(w / 90))
        let humpSpacing = (w - 40) / CGFloat(humpCount - 1)
        for i in 0..<humpCount {
            let hump = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1),
                                    size: CGSize(width: 28, height: 14))
            hump.anchorPoint = CGPoint(x: 0.5, y: 0)
            hump.position = CGPoint(x: -w / 2 + 20 + CGFloat(i) * humpSpacing, y: h + 8)
            depot.addChild(hump)
        }

        // Long hazard stripe — full facade width
        let hazard = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.8),
                                  size: CGSize(width: w - 12, height: 5))
        hazard.anchorPoint = CGPoint(x: 0.5, y: 0)
        hazard.position = CGPoint(x: 0, y: h - 18)
        depot.addChild(hazard)

        // Utility panel bays along facade
        let bayCount = max(4, Int(w / 70))
        let bayW = (w - 48) / CGFloat(bayCount)
        for i in 0..<bayCount {
            let bayX = -w / 2 + 24 + CGFloat(i) * bayW + bayW / 2
            let panel = SKSpriteNode(color: SKColor(red: 0.06, green: 0.09, blue: 0.13, alpha: 1),
                                     size: CGSize(width: bayW - 8, height: h - 28))
            panel.anchorPoint = CGPoint(x: 0.5, y: 0)
            panel.position = CGPoint(x: bayX, y: 6)
            depot.addChild(panel)

            let vent = SKSpriteNode(color: SKColor(white: 0.16, alpha: 0.55),
                                    size: CGSize(width: bayW - 14, height: 4))
            vent.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            vent.position = CGPoint(x: bayX, y: h - 32)
            depot.addChild(vent)
        }

        // Central maintenance door (entry point)
        let doorW: CGFloat = min(36, w * 0.09)
        let doorH: CGFloat = h - 10
        let doorFrame = SKSpriteNode(color: SKColor(white: 0.03, alpha: 1),
                                     size: CGSize(width: doorW + 6, height: doorH))
        doorFrame.anchorPoint = CGPoint(x: 0.5, y: 0)
        doorFrame.position = CGPoint(x: 0, y: 2)
        depot.addChild(doorFrame)

        let doorPanel = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1),
                                     size: CGSize(width: doorW, height: doorH - 8))
        doorPanel.anchorPoint = CGPoint(x: 0.5, y: 0)
        doorPanel.position = CGPoint(x: 0, y: 6)
        depot.addChild(doorPanel)

        // Status lights along roofline
        let lightCount = max(5, Int(w / 55))
        let lightSpacing = (w - 30) / CGFloat(lightCount - 1)
        for i in 0..<lightCount {
            let lit = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(i % 2 == 0 ? 0.65 : 0.35),
                                   size: CGSize(width: 8, height: 6))
            lit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            lit.position = CGPoint(x: -w / 2 + 15 + CGFloat(i) * lightSpacing, y: h - 6)
            depot.addChild(lit)
        }

        // Antenna / repeater mast
        let mast = SKSpriteNode(color: SKColor(white: 0.22, alpha: 0.7),
                                size: CGSize(width: 3, height: 22))
        mast.anchorPoint = CGPoint(x: 0.5, y: 0)
        mast.position = CGPoint(x: w * 0.38, y: h + 10)
        depot.addChild(mast)
        let dish = SKSpriteNode(color: DLOColor.teal.withAlphaComponent(0.45),
                                size: CGSize(width: 14, height: 8))
        dish.anchorPoint = CGPoint(x: 0.5, y: 0)
        dish.position = CGPoint(x: w * 0.38, y: h + 30)
        depot.addChild(dish)

        // Signage
        let title = SKLabelNode(text: "PMCA RELAY STATION")
        title.fontName = "Menlo-Bold"
        title.fontSize = min(11, w * 0.028)
        title.fontColor = DLOColor.terminalAmber
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: h - 8)
        depot.addChild(title)

        let sub = SKLabelNode(text: "NODE 7 — UTILITY DEPOT")
        sub.fontName = "Menlo-Bold"
        sub.fontSize = min(8, w * 0.02)
        sub.fontColor = DLOColor.dimText
        sub.verticalAlignmentMode = .center
        sub.horizontalAlignmentMode = .center
        sub.position = CGPoint(x: 0, y: h - 16)
        depot.addChild(sub)

        return depot
    }

    // MARK: - Checkpoint

    private static func buildCheckpoint(at pos: CGPoint, width w: CGFloat, height h: CGFloat) -> SKNode {
        let booth = SKNode()
        booth.position = CGPoint(x: pos.x, y: 40)
        booth.zPosition = 19

        let metal = DLOColor.platformSilhouette

        let shell = SKSpriteNode(color: metal, size: CGSize(width: w, height: h))
        shell.anchorPoint = CGPoint(x: 0.5, y: 0)
        booth.addChild(shell)

        let roof = SKSpriteNode(color: SKColor(red: 0.07, green: 0.10, blue: 0.15, alpha: 1),
                                size: CGSize(width: w + 12, height: 12))
        roof.anchorPoint = CGPoint(x: 0.5, y: 0)
        roof.position = CGPoint(x: 0, y: h)
        booth.addChild(roof)

        let stripe = SKSpriteNode(color: DLOColor.terminalAmber.withAlphaComponent(0.8),
                                  size: CGSize(width: w - 6, height: 6))
        stripe.anchorPoint = CGPoint(x: 0.5, y: 0)
        stripe.position = CGPoint(x: 0, y: h - 28)
        booth.addChild(stripe)

        let doorFrame = SKSpriteNode(color: SKColor(white: 0.05, alpha: 1),
                                     size: CGSize(width: 24, height: h - 20))
        doorFrame.anchorPoint = CGPoint(x: 0.5, y: 0)
        doorFrame.position = CGPoint(x: 0, y: 2)
        booth.addChild(doorFrame)

        let title = SKLabelNode(text: "CHECKPOINT")
        title.fontName = "Menlo-Bold"
        title.fontSize = 7
        title.fontColor = DLOColor.terminalAmber
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: h - 12)
        booth.addChild(title)

        let sub = SKLabelNode(text: "ARCHIVE ACCESS")
        sub.fontName = "Menlo-Bold"
        sub.fontSize = 6
        sub.fontColor = DLOColor.dimText
        sub.verticalAlignmentMode = .center
        sub.horizontalAlignmentMode = .center
        sub.position = CGPoint(x: 0, y: h - 20)
        booth.addChild(sub)

        return booth
    }

    // MARK: - Generic fallback

    private static func buildGenericUtility(at pos: CGPoint, width w: CGFloat, height h: CGFloat) -> SKNode {
        let booth = SKNode()
        booth.position = CGPoint(x: pos.x, y: 40)
        booth.zPosition = 19

        let shell = SKSpriteNode(color: DLOColor.platformSilhouette,
                                 size: CGSize(width: w, height: h))
        shell.anchorPoint = CGPoint(x: 0.5, y: 0)
        booth.addChild(shell)

        return booth
    }
}
