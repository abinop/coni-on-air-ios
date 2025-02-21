import SwiftUI
import CarPlay
import MediaPlayer
import FRadioPlayer
import FirebaseDatabase
import AVFoundation
import UIKit

@objc public class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    public var interfaceController: CPInterfaceController?
    public var nowPlayingTemplate: CPNowPlayingTemplate?
    public var window: UIWindow?
    private var radioPlayer = FRadioPlayer.shared
    private var databaseRef: DatabaseReference?
    
    // MARK: - CPTemplateApplicationSceneDelegate Required Methods
    
    @objc(templateApplicationScene:didConnectInterfaceController:)
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect interfaceController: CPInterfaceController) {
        print("🚗 [CarPlay] Connected to CarPlay interface")
        self.interfaceController = interfaceController
        print("🎵 [CarPlay] Setting up audio session...")
        setupAudioSession()
        print("📱 [CarPlay] Setting up now playing template...")
        setupNowPlayingTemplate()
        print("🔄 [CarPlay] Setting up real-time updates...")
        setupDatabaseListener()
        print("✅ [CarPlay] Setup complete")
    }
    
    @objc(templateApplicationScene:didDisconnectInterfaceController:)
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                         didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        print("🚫 [CarPlay] Disconnected from CarPlay interface")
        self.interfaceController = nil
        self.nowPlayingTemplate = nil
    }
    
    @objc(templateApplicationScene:didConnectTemplate:)
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect nowPlayingTemplate: CPNowPlayingTemplate) {
        print("🎵 [CarPlay] Now playing template connected")
        self.nowPlayingTemplate = nowPlayingTemplate
    }
    
    @objc(templateApplicationScene:didDisconnectTemplate:)
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didDisconnect nowPlayingTemplate: CPNowPlayingTemplate) {
        print("🎵 [CarPlay] Now playing template disconnected")
        self.nowPlayingTemplate = nil
    }
    
    // MARK: - UISceneDelegate Methods
    
    @objc public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("🔄 [CarPlay] Scene connection starting...")
        print("🔍 [CarPlay] Scene type: \(type(of: scene))")
        print("🔍 [CarPlay] Session role: \(session.role)")
        
        guard let carPlayScene = scene as? CPTemplateApplicationScene else {
            print("⚠️ [CarPlay] Not a CarPlay scene - ignoring")
            return
        }
        print("✅ [CarPlay] Valid CarPlay scene - setting delegate")
        carPlayScene.delegate = self
        
        // Initialize audio session early
        setupAudioSession()
    }
    
    @objc public func sceneDidBecomeActive(_ scene: UIScene) {
        print("▶️ [CarPlay] Scene became active")
        if let carPlayScene = scene as? CPTemplateApplicationScene {
            print("✅ [CarPlay] Confirming delegate assignment")
            carPlayScene.delegate = self
        }
    }
    
    @objc public func sceneWillResignActive(_ scene: UIScene) {
        print("⏸️ [CarPlay] Scene will become inactive")
    }
    
    @objc public func sceneDidDisconnect(_ scene: UIScene) {
        print("🔌 [CarPlay] Scene disconnected - cleaning up")
        interfaceController = nil
        nowPlayingTemplate = nil
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ [CarPlay] Audio session setup complete")
        } catch {
            print("❌ [CarPlay] Failed to set up audio session:", error)
        }
    }
    
    private func setupNowPlayingTemplate() {
        print("🎵 [CarPlay] Creating now playing template")
        nowPlayingTemplate = CPNowPlayingTemplate.shared
        nowPlayingTemplate?.isUpNextButtonEnabled = false
        nowPlayingTemplate?.isAlbumArtistButtonEnabled = false
        
        print("🔘 [CarPlay] Setting up playback controls")
        nowPlayingTemplate?.updateNowPlayingButtons([
            CPNowPlayingPlaybackRateButton(),
            CPNowPlayingButton(handler: { [weak self] _ in
                print("👆 [CarPlay] Play/Pause button tapped")
                self?.radioPlayer.togglePlaying()
            })
        ])
        
        print("📱 [CarPlay] Setting root template")
        interfaceController?.setRootTemplate(nowPlayingTemplate!, animated: true)
        print("✅ [CarPlay] Now playing template setup complete")
    }
    
    private func setupDatabaseListener() {
        print("📡 [CarPlay] Setting up database listener")
        databaseRef = Database.database().reference()
        databaseRef?.child("nowPlaying").observe(.value) { [weak self] snapshot in
            guard let data = snapshot.value as? [String: Any],
                  let title = data["title"] as? String,
                  let artist = data["artist"] as? String else {
                print("⚠️ [CarPlay] Invalid data received from database")
                return
            }
            
            print("🎵 [CarPlay] Updating now playing info - Title: \(title), Artist: \(artist)")
            let nowPlaying = MPNowPlayingInfoCenter.default()
            var nowPlayingInfo = [String: Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            nowPlaying.nowPlayingInfo = nowPlayingInfo
            
            print("🔄 [CarPlay] Updating playback controls")
            self?.nowPlayingTemplate?.updateNowPlayingButtons([
                CPNowPlayingPlaybackRateButton(),
                CPNowPlayingButton(handler: { [weak self] _ in
                    print("👆 [CarPlay] Play/Pause button tapped")
                    self?.radioPlayer.togglePlaying()
                })
            ])
        }
        print("✅ [CarPlay] Database listener setup complete")
    }
} 
