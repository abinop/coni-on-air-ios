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
    private var isInitialSetup = true

    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect interfaceController: CPInterfaceController) {
        print("🚗 [CarPlay] Connected to CarPlay interface")
        print("🎵 [CarPlay] Initial player state - isPlaying: \(radioPlayer.isPlaying), state: \(radioPlayer.state.rawValue), URL: \(radioPlayer.radioURL?.absoluteString ?? "nil")")
        
        self.interfaceController = interfaceController
        setupAudioSession()
        setupNowPlayingTemplate()
        setupDatabaseListener()
        
        // Stop any existing playback
        print("🎵 [CarPlay] Stopping any existing playback")
        radioPlayer.stop()
        radioPlayer.delegate = self
        
        // Setup remote command center
        setupRemoteCommandCenter()
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
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Remove all previous targets
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        
        // Enable and handle play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            print("🎵 [CarPlay] Play command received")
            self?.handlePlayPause()
            return .success
        }
        
        // Enable and handle pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            print("🎵 [CarPlay] Pause command received")
            self?.handlePlayPause()
            return .success
        }
        
        // Enable and handle toggle command
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            print("🎵 [CarPlay] Toggle play/pause command received")
            self?.handlePlayPause()
            return .success
        }
        
        // Disable unnecessary commands
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.changePlaybackRateCommand.isEnabled = false
    }
    
    private func setupNowPlayingTemplate() {
        print("🎵 [CarPlay] Creating now playing template")
        nowPlayingTemplate = CPNowPlayingTemplate.shared
        nowPlayingTemplate?.isUpNextButtonEnabled = false
        nowPlayingTemplate?.isAlbumArtistButtonEnabled = false
        
        updatePlayButtonState()
        interfaceController?.setRootTemplate(nowPlayingTemplate!, animated: true)
        print("🎵 [CarPlay] Template setup complete - Current state - isPlaying: \(radioPlayer.isPlaying), state: \(radioPlayer.state.rawValue)")
    }
    
    private func setupDatabaseListener() {
        print("📡 [CarPlay] Setting up database listener")
        databaseRef = Database.database().reference()
        
        // Listen for now playing data
        databaseRef?.child("data").observe(.value) { [weak self] snapshot, _ in
            guard let self,
                  let json = snapshot.value as? [String: Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let decoder = JSONDecoder()
                self.nowPlayingData = try decoder.decode(NowPlayingData.self, from: data)
                print("📡 [CarPlay] Received now playing data with URL: \(self.nowPlayingData?.url.absoluteString ?? "nil")")
                print("🎵 [CarPlay] Current player state - isPlaying: \(self.radioPlayer.isPlaying), state: \(self.radioPlayer.state.rawValue), URL: \(self.radioPlayer.radioURL?.absoluteString ?? "nil")")
                
                // Only set the URL during initial setup, don't start playing
                if self.isInitialSetup, let url = self.nowPlayingData?.url {
                    print("🎵 [CarPlay] Initial setup - Setting radio URL")
                    self.radioPlayer.stop()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("🎵 [CarPlay] Setting URL after stop")
                        self.radioPlayer.enableArtwork = true
                        self.radioPlayer.radioURL = url
                        print("🎵 [CarPlay] URL set - Current state - isPlaying: \(self.radioPlayer.isPlaying), state: \(self.radioPlayer.state.rawValue)")
                        self.isInitialSetup = false
                        
                        // Force stop again after URL is set
                        self.radioPlayer.stop()
                        print("🎵 [CarPlay] Forced stop after URL set - isPlaying: \(self.radioPlayer.isPlaying), state: \(self.radioPlayer.state.rawValue)")
                        
                        // Update button state after setup
                        self.updatePlayButtonState()
                    }
                }
            } catch {
                print("❌ [CarPlay] Error decoding now playing data:", error)
            }
        }
        
        // Listen for track info
        databaseRef?.child("nowPlaying").observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let data = snapshot.value as? [String: Any],
                  let title = data["title"] as? String,
                  let artist = data["artist"] as? String else { return }
            
            print("📡 [CarPlay] Updating now playing info - Title: \(title), Artist: \(artist)")
            
            // Update both MPNowPlayingInfoCenter and CarPlay template
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
        print("🎵 [CarPlay] Play/Pause requested")
        print("🎵 [CarPlay] Current state - isPlaying: \(radioPlayer.isPlaying), state: \(radioPlayer.state.rawValue), URL: \(radioPlayer.radioURL?.absoluteString ?? "nil")")
        
        if radioPlayer.isPlaying {
            print("🎵 [CarPlay] Attempting to stop playback")
            radioPlayer.stop()
        } else {
            print("🎵 [CarPlay] Attempting to start playback")
            if radioPlayer.radioURL == nil {
                if let url = nowPlayingData?.url {
                    print("🎵 [CarPlay] No URL set, setting now: \(url)")
                    radioPlayer.enableArtwork = true
                    radioPlayer.radioURL = url
                } else {
                    print("❌ [CarPlay] No URL available for playback")
                    return
                }
            }
            
            do {
                print("🎵 [CarPlay] Setting up audio session")
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                print("✅ [CarPlay] Audio session activated")
            } catch {
                print("❌ [CarPlay] Failed to set up audio session:", error)
            }
            
            print("🎵 [CarPlay] Calling play()")
            radioPlayer.play()
        }
    }
    
    private func updatePlayButtonState() {
        let isPlaying = radioPlayer.isPlaying
        print("🎵 [CarPlay] Updating button - isPlaying: \(isPlaying), state: \(radioPlayer.state.rawValue)")
        
        let buttons: [CPNowPlayingButton] = [
            CPNowPlayingButton()
        ]
        
        nowPlayingTemplate?.updateNowPlayingButtons(buttons)
        print("🎵 [CarPlay] Button updated - isPlaying: \(radioPlayer.isPlaying), state: \(radioPlayer.state.rawValue)")
    }
}

extension CarPlaySceneDelegate: FRadioPlayerDelegate {
    public func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("🎵 [CarPlay] Player state changed - New state: \(state.rawValue), isPlaying: \(player.isPlaying)")
        DispatchQueue.main.async {
            self.updatePlayButtonState()
        }
    }
    
    public func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("🎵 [CarPlay] Playback state changed - New state: \(state.rawValue), isPlaying: \(player.isPlaying)")
        DispatchQueue.main.async {
            self.updatePlayButtonState()
        }
    }
}
