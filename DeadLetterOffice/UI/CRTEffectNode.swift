import SpriteKit

// Layered CRT visual effect: scanlines + vignette + flicker.
final class CRTEffectNode: SKNode {

    private var scanlineNode: SKSpriteNode?
    private var vignetteNode: SKSpriteNode?
    private var flickerAction: SKAction?

    init(size: CGSize) {
        super.init()
        zPosition = 900
        setupScanlines(size)
        setupVignette(size)
        if !GameState.shared.reducedFlashingEnabled {
            startFlicker()
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupScanlines(_ size: CGSize) {
        let lineSpacing: CGFloat = 4
        let lineCount = Int(size.height / lineSpacing)
        // opaque=true → white background; multiply(white, content) = content (neutral)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext(); return
        }
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(CGRect(origin: .zero, size: size))
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
        for i in 0..<lineCount {
            let y = CGFloat(i) * lineSpacing
            ctx.fill(CGRect(x: 0, y: y, width: size.width, height: 1.5))
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = img {
            let tex = SKTexture(image: img)
            let node = SKSpriteNode(texture: tex, size: size)
            node.position = CGPoint(x: size.width/2, y: size.height/2)
            node.blendMode = .multiply
            addChild(node)
            scanlineNode = node
        }
    }

    private func setupVignette(_ size: CGSize) {
        // Transparent center fading to opaque-black at edges — use alpha blend (not multiply)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext(); return
        }
        let colors = [UIColor.clear.cgColor,
                      UIColor.black.withAlphaComponent(0.72).cgColor] as CFArray
        let locs: [CGFloat] = [0, 1]
        let space = CGColorSpaceCreateDeviceRGB()
        if let grad = CGGradient(colorsSpace: space, colors: colors, locations: locs) {
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius = max(size.width, size.height) * 0.75
            // inner radius = clear (center visible), outer = dark edges
            ctx.drawRadialGradient(grad,
                startCenter: center, startRadius: radius * 0.35,
                endCenter: center,   endRadius: radius,
                options: [.drawsAfterEndLocation])
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = img {
            let tex = SKTexture(image: img)
            let node = SKSpriteNode(texture: tex, size: size)
            node.position = CGPoint(x: size.width/2, y: size.height/2)
            node.blendMode = .alpha
            addChild(node)
            vignetteNode = node
        }
    }

    private func startFlicker() {
        let flicker = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.92, duration: 0.05),
            SKAction.fadeAlpha(to: 1.00, duration: 0.05),
            SKAction.wait(forDuration: 4.0, withRange: 6.0)
        ])
        run(SKAction.repeatForever(flicker))
    }

    func applySettings() {
        removeAllActions()
        if !GameState.shared.reducedFlashingEnabled {
            startFlicker()
        }
    }
}
