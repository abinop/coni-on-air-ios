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
    private var nowPlayingData: NowPlayingData?
    private var playButton: CPNowPlayingButton?

    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect interfaceController: CPInterfaceController) {
        print("🚗 [CarPlay] Connected to CarPlay interface")
        self.interfaceController = interfaceController
        setupAudioSession()
        setupNowPlayingTemplate()
        setupDatabaseListener()
        radioPlayer.delegate = self
        
        // Initialize player if we already have URL
        if let url = nowPlayingData?.url {
            print("🎵 [CarPlay] Initializing player with URL: \(url)")
            radioPlayer.radioURL = url
            radioPlayer.enableArtwork = true
        }
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
        
        playButton = CPNowPlayingButton(handler: { [weak self] _ in
            print("🎵 [CarPlay] Play button tapped")
            self?.handlePlayPause()
        })
        
        nowPlayingTemplate?.updateNowPlayingButtons([playButton!])
        interfaceController?.setRootTemplate(nowPlayingTemplate!, animated: true)
        updatePlayButtonState()
    }
    
    private func setupDatabaseListener() {
        print("📡 [CarPlay] Setting up database listener")
        databaseRef = Database.database().reference()
        
        // Listen for now playing data
        databaseRef?.child("data").observe(.value) { [weak self] snapshot in
            guard let self,
                  let json = snapshot.value as? [String: Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let decoder = JSONDecoder()
                self.nowPlayingData = try decoder.decode(NowPlayingData.self, from: data)
                print("📡 [CarPlay] Received now playing data with URL: \(self.nowPlayingData?.url.absoluteString ?? "nil")")
                
                // Initialize player URL if not set
                if radioPlayer.radioURL == nil, let url = self.nowPlayingData?.url {
                    print("🎵 [CarPlay] Setting initial radio URL: \(url)")
                    radioPlayer.radioURL = url
                    radioPlayer.enableArtwork = true
                }
            } catch {
                print("❌ [CarPlay] Error decoding now playing data:", error)
            }
        }
        
        // Listen for track info
        databaseRef?.child("nowPlaying").observe(.value) { [weak self] snapshot in
            guard let data = snapshot.value as? [String: Any],
                  let title = data["title"] as? String,
                  let artist = data["artist"] as? String else { return }
            let nowPlaying = MPNowPlayingInfoCenter.default()
            var nowPlayingInfo = [String: Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
            if let image = UIImage(named: "image") {
                let artWork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artWork
            }
            nowPlaying.nowPlayingInfo = nowPlayingInfo
        }
    }
    
    private func handlePlayPause() {
        print("🎵 [CarPlay] Handle play/pause - Current state: isPlaying=\(radioPlayer.isPlaying)")
        
        if radioPlayer.isPlaying {
            print("🎵 [CarPlay] Stopping playback")
            radioPlayer.stop()
        } else {
            print("🎵 [CarPlay] Starting playback")
            if radioPlayer.radioURL == nil {
                if let url = nowPlayingData?.url {
                    print("🎵 [CarPlay] Setting radio URL: \(url)")
                    radioPlayer.radioURL = url
                    radioPlayer.enableArtwork = true
                } else {
                    print("❌ [CarPlay] No URL available for playback")
                    return
                }
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                print("🎵 [CarPlay] Audio session activated")
            } catch {
                print("❌ [CarPlay] Failed to set up audio session:", error)
            }
            
            radioPlayer.play()
        }
        
        updatePlayButtonState()
    }
    
    private func updatePlayButtonState() {
        guard let playButton = playButton else { return }
        let isPlaying = radioPlayer.isPlaying
        print("🎵 [CarPlay] Updating play button state - isPlaying=\(isPlaying)")
        
        let newButtons = [
            CPNowPlayingButton(handler: { [weak self] _ in
                print("🎵 [CarPlay] Play button tapped")
                self?.handlePlayPause()
            })
        ]
        nowPlayingTemplate?.updateNowPlayingButtons(newButtons)
    }
}

extension CarPlaySceneDelegate: FRadioPlayerDelegate {
    public func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("🎵 [CarPlay] Player state changed to: \(state)")
        updatePlayButtonState()
    }
    
    public func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("🎵 [CarPlay] Playback state changed to: \(state)")
        updatePlayButtonState()
    }
}
