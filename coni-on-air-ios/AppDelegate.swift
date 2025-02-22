//
//  AppDelegate.swift
//  coni-on-air-ios
//

import SwiftUI
import Firebase
import CarPlay

@main
struct coni_on_air_iosApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension coni_on_air_iosApp {
    public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?
        
        public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = scene as? UIWindowScene else { return }
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = UIHostingController(rootView: ContentView())
            window?.makeKeyAndVisible()
            print("📱 [SceneDelegate] iOS window configured")
        }
    }

    public class AppDelegate: NSObject, UIApplicationDelegate {
        public func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            print("✅ [AppDelegate] Application launched")
            return true
        }
        
        public func application(_ application: UIApplication,
                        configurationForConnecting connectingSceneSession: UISceneSession,
                        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            print("🔄 [AppDelegate] Configuring scene for role: \(connectingSceneSession.role.rawValue)")
            
            if connectingSceneSession.role == .carTemplateApplication {
                print("🚗 [AppDelegate] Configuring CarPlay scene")
                let config = UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
                config.delegateClass = CarPlaySceneDelegate.self
                return config
            } else {
                print("📱 [AppDelegate] Configuring iOS scene")
                let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
                config.delegateClass = SceneDelegate.self
                return config
            }
        }
        
        public func application(_ application: UIApplication,
                        didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            print("🗑️ [AppDelegate] Discarded scenes: \(sceneSessions.count)")
        }
    }
}
