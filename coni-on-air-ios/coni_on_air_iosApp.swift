//
//  coni_on_air_iosApp.swift
//  coni-on-air-ios
//

import SwiftUI
import Firebase
import CarPlay
import MediaPlayer
import FRadioPlayer
import FirebaseDatabase

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
        }
    }

    public class AppDelegate: NSObject, UIApplicationDelegate {
        public func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            return true
        }
        
        public func application(_ application: UIApplication,
                        configurationForConnecting connectingSceneSession: UISceneSession,
                        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            print("🔄 [App Lifecycle] Configuring new scene...")
            print("📱 Current scene role:", connectingSceneSession.role)
            print("🏷️ Scene configuration name:", connectingSceneSession.configuration.name ?? "None")
            print("🔍 Session role raw value:", connectingSceneSession.role.rawValue)
            
            // Check if this is a CarPlay scene request
            let isCarPlayScene = connectingSceneSession.role.rawValue == "CPTemplateApplicationSceneSessionRoleApplication"
            let isCarPlayConfig = connectingSceneSession.configuration.name == "CarPlay Configuration"
            
            if isCarPlayScene || isCarPlayConfig {
                print("🚗 [CarPlay] Setting up CarPlay scene configuration")
                let config = UISceneConfiguration(
                    name: "CarPlay Configuration",
                    sessionRole: connectingSceneSession.role
                )
                config.delegateClass = CarPlaySceneDelegate.self
                config.sceneClass = CPTemplateApplicationScene.self
                print("✅ [CarPlay] Configuration complete - Using CarPlaySceneDelegate")
                return config
            }
            
            // Handle main app window scene
            print("📱 [App] Setting up main app window configuration")
            let config = UISceneConfiguration(
                name: "Default Configuration",
                sessionRole: connectingSceneSession.role
            )
            config.delegateClass = SceneDelegate.self
            print("✅ [App] Configuration complete - Using SceneDelegate")
            return config
        }
        
        public func application(_ application: UIApplication,
                        didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        }
    }
}
