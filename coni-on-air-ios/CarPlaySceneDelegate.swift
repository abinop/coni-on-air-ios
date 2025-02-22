//
//  CarPlaySceneDelegate.swift
//  coni-on-air-ios
//

import SwiftUI
import CarPlay
import MediaPlayer
import FRadioPlayer
import FirebaseDatabase
import AVFoundation

public class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    var nowPlayingTemplate: CPNowPlayingTemplate?
    private var radioPlayer = FRadioPlayer.shared
    private var databaseRef: DatabaseReference?

    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect interfaceController: CPInterfaceController) {
        print("🚗 [CarPlay] Connected to CarPlay interface")
        self.interfaceController = interfaceController
        setupAudioSession()
        setupNowPlayingTemplate()
        setupDatabaseListener()
    }
    
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        print("🚫 [CarPlay] Disconnected from CarPlay interface")
        self.interfaceController = nil
        self.nowPlayingTemplate = nil
    }
    
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
        
        nowPlayingTemplate?.updateNowPlayingButtons([
            CPNowPlayingPlaybackRateButton(),
            CPNowPlayingButton(handler: { [weak self] _ in
                self?.radioPlayer.togglePlaying()
            })
        ])
        
        interfaceController?.setRootTemplate(nowPlayingTemplate!, animated: true)
    }
    
    private func setupDatabaseListener() {
        print("📡 [CarPlay] Setting up database listener")
        databaseRef = Database.database().reference()
        databaseRef?.child("nowPlaying").observe(.value) { [weak self] snapshot in
            guard let data = snapshot.value as? [String: Any],
                  let title = data["title"] as? String,
                  let artist = data["artist"] as? String else { return }
            let nowPlaying = MPNowPlayingInfoCenter.default()
            nowPlaying.nowPlayingInfo = [
                MPMediaItemPropertyTitle: title,
                MPMediaItemPropertyArtist: artist
            ]
        }
    }
}
