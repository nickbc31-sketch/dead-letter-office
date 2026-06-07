import SpriteKit
import UIKit

/// Landmark environment structure placed between near parallax and gameplay layers.
struct BuildingNodeSpec: Codable {
    var asset: String
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat?
}

enum BuildingNode {

    /// Ground-line Y for field platform levels (matches `PlatformScene` floor top).
    static let floorY: CGFloat = 40

    /// Above near parallax (-10), below floor/player/interactables.
    static let landmarkZPosition: CGFloat = 15

    static func make(spec: BuildingNodeSpec) -> SKNode {
        let container = SKNode()
        container.name = "building_\(spec.asset)"
        container.position = CGPoint(x: spec.x, y: floorY + spec.y)
        container.zPosition = landmarkZPosition

        let multiplier = max(0.25, spec.scale ?? 1.0)
        if let sprite = loadSprite(named: spec.asset, scale: multiplier) {
            container.addChild(sprite)
        } else {
            NSLog("[DLO BuildingNode] WARNING — missing landmark asset '%@'", spec.asset)
        }
        return container
    }

    static func makeAll(from specs: [BuildingNodeSpec]) -> [SKNode] {
        specs.map { make(spec: $0) }
    }

    private static func loadSprite(named assetName: String, scale: CGFloat) -> SKSpriteNode? {
        guard UIImage(named: assetName) != nil else { return nil }
        let tex = SKTexture(imageNamed: assetName)
        tex.filteringMode = .nearest
        let native = tex.size()
        guard native.width > 1, native.height > 1 else { return nil }

        let sprite = SKSpriteNode(texture: tex)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.size = CGSize(width: native.width * scale, height: native.height * scale)
        return sprite
    }
}
