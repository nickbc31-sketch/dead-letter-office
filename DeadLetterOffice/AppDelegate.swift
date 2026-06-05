import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Use the physical screen bounds directly — without UIWindowScene, iOS cannot
        // apply its iOS 26 compact windowed mode. UIScreen.main.bounds reflects the real
        // device screen dimensions here.
        let screen = UIScreen.main
        let screenBounds = screen.bounds
        NSLog("[DLO-AD] screen bounds: %.0f×%.0f nativeBounds: %.0f×%.0f scale: %.0f",
              screenBounds.width, screenBounds.height,
              screen.nativeBounds.width, screen.nativeBounds.height, screen.scale)

        let w = UIWindow(frame: screenBounds)
        w.rootViewController = GameViewController()
        w.makeKeyAndVisible()
        NSLog("[DLO-AD] window: %.0f×%.0f", w.bounds.width, w.bounds.height)
        window = w
        return true
    }
}
