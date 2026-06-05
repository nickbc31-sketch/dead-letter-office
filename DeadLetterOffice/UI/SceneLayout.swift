import SpriteKit

/// Safe-area-aware layout helper for SpriteKit scenes using scaleMode = .resizeFill.
/// With resizeFill, scene.size == view.bounds.size (one scene point == one UIKit point),
/// so safe-area insets are applied directly with no aspect-ratio scaling.
struct SceneLayout {

    // MARK: - Scene-space safe boundaries (y=0 at bottom, y=size.height at top)
    let left:   CGFloat
    let right:  CGFloat
    let top:    CGFloat
    let bottom: CGFloat
    let size:   CGSize

    var midX:   CGFloat { (left + right)  / 2 }
    var midY:   CGFloat { (bottom + top)  / 2 }
    var w:      CGFloat { right - left }
    var h:      CGFloat { top - bottom }
    var center: CGPoint { CGPoint(x: midX, y: midY) }

    /// Horizontal fraction: 0 = safe left edge, 1 = safe right edge.
    func x(_ f: CGFloat) -> CGFloat { left   + w * f }
    /// Vertical fraction: 0 = safe bottom edge, 1 = safe top edge.
    func y(_ f: CGFloat) -> CGFloat { bottom + h * f }

    // MARK: - Factories

    /// Call inside `didMove(to:)` once the view is attached.
    /// Requires scaleMode == .resizeFill (scene.size == view.bounds.size).
    static func make(scene: SKScene) -> SceneLayout {
        let sz = scene.size
        guard let view = scene.view, view.bounds.width > 1, view.bounds.height > 1 else {
            return .fallback(size: sz)
        }

        // resizeFill: one scene point = one UIKit point — apply safe-area insets directly.
        let sa = view.safeAreaInsets
        let minPadX = max(sz.width  * 0.02, 8)
        let minPadY = max(sz.height * 0.02, 8)

        let layout = SceneLayout(
            left:   max(sa.left,   minPadX),
            right:  sz.width  - max(sa.right,  minPadX),
            top:    sz.height - max(sa.top,    minPadY),
            bottom: max(sa.bottom, minPadY),
            size:   sz
        )
        NSLog("%@", "[DLO] SceneLayout: sz=\(sz) sa=\(sa) → l=\(layout.left) r=\(layout.right) t=\(layout.top) b=\(layout.bottom) w=\(layout.w) h=\(layout.h)")
        return layout
    }

    /// Zero-dependency fallback used before `didMove` fires or if view isn't ready.
    static func fallback(size: CGSize) -> SceneLayout {
        SceneLayout(
            left:   size.width  * 0.04,
            right:  size.width  * 0.96,
            top:    size.height * 0.95,
            bottom: size.height * 0.05,
            size:   size
        )
    }

    // MARK: - Camera-space layout

    /// Layout bounds for HUD nodes that are children of an `SKCameraNode`.
    struct CameraLayout {
        let left:   CGFloat
        let right:  CGFloat
        let top:    CGFloat
        let bottom: CGFloat

        var w:    CGFloat { right - left }
        var h:    CGFloat { top   - bottom }
        var midX: CGFloat { (left + right)  / 2 }
        var midY: CGFloat { (bottom + top)  / 2 }
    }

    static func makeCamera(scene: SKScene) -> CameraLayout {
        let sz = scene.size
        guard let view = scene.view, view.bounds.width > 1 else {
            return CameraLayout(left: -sz.width / 2, right:  sz.width  / 2,
                                top:   sz.height / 2, bottom: -sz.height / 2)
        }
        // resizeFill: camera origin is scene centre; insets are in UIKit points.
        let sa   = view.safeAreaInsets
        let padX = max(sz.width  * 0.02, 8)
        let padY = max(sz.height * 0.02, 8)
        return CameraLayout(
            left:   -sz.width  / 2 + max(sa.left,   padX),
            right:   sz.width  / 2 - max(sa.right,  padX),
            top:     sz.height / 2 - max(sa.top,    padY),
            bottom: -sz.height / 2 + max(sa.bottom, padY)
        )
    }
}
