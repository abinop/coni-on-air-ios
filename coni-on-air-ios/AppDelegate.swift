import UIKit
import Firebase
import CarPlay
import SwiftUI

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("✅ [AppDelegate] Application launched")
        FirebaseApp.configure()
        
        // Force window setup for iOS
        print("📱 [AppDelegate] Setting up iOS window")
        let window = UIWindow(frame: UIScreen.main.bounds)
        let hostingController = UIHostingController(rootView: ContentView())
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        self.window = window
        print("📱 [AppDelegate] iOS window configured with root: \(String(describing: window.rootViewController))")
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("🔄 [AppDelegate] Configuring scene for role: \(connectingSceneSession.role.rawValue)")
        print("🔍 [AppDelegate] Session role: \(connectingSceneSession.role)")
        
        if connectingSceneSession.role == .carTemplateApplication ||
           connectingSceneSession.role.rawValue == "CPTemplateApplicationSceneSessionRoleApplication" {
            print("🚗 [AppDelegate] Configuring CarPlay scene")
            let config = UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
            config.delegateClass = CarPlaySceneDelegate.self
            print("🚗 [AppDelegate] Assigned CarPlaySceneDelegate: \(String(describing: config.delegateClass))")
            return config
        } else {
            print("📱 [AppDelegate] Configuring iOS scene")
            let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            config.delegateClass = SceneDelegate.self
            print("📱 [AppDelegate] Assigned SceneDelegate: \(String(describing: config.delegateClass))")
            return config
        }
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("🗑️ [AppDelegate] Discarded scenes: \(sceneSessions.count)")
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("📱 [SceneDelegate] Scene connecting for role: \(session.role)")
        guard let windowScene = scene as? UIWindowScene else {
            print("❌ [SceneDelegate] Failed to cast to UIWindowScene")
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: ContentView())
        window?.makeKeyAndVisible()
        print("📱 [SceneDelegate] iOS window configured")
    }
}
