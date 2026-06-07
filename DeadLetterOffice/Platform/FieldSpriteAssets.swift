import SpriteKit
import UIKit

/// Loads production field sprite assets with nearest-neighbour filtering and procedural fallbacks.
enum FieldSpriteAssets {

    static func texture(named assetName: String) -> SKTexture? {
        guard UIImage(named: assetName) != nil else {
            NSLog("[DLO FieldSprite] WARNING — missing texture '%@', using procedural fallback", assetName)
            return nil
        }
        let tex = SKTexture(imageNamed: assetName)
        tex.filteringMode = .nearest
        return tex
    }

    /// Bottom-anchored sprite scaled to `targetHeight`, preserving aspect ratio.
    static func groundedSprite(named assetName: String, targetHeight: CGFloat,
                               anchorX: CGFloat = 0.5) -> SKSpriteNode? {
        guard let tex = texture(named: assetName) else { return nil }
        let native = tex.size()
        guard native.height > 1 else { return nil }
        let aspect = native.width / native.height
        let sprite = SKSpriteNode(texture: tex)
        sprite.anchorPoint = CGPoint(x: anchorX, y: 0)
        sprite.size = CGSize(width: targetHeight * aspect, height: targetHeight)
        return sprite
    }

    /// Wraps a grounded sprite in a container (ground contact at y = 0).
    static func groundedNode(named assetName: String, targetHeight: CGFloat,
                             anchorX: CGFloat = 0.5) -> SKNode? {
        guard let sprite = groundedSprite(named: assetName, targetHeight: targetHeight,
                                          anchorX: anchorX) else { return nil }
        let node = SKNode()
        node.addChild(sprite)
        return node
    }
}
