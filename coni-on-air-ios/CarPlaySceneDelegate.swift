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
        
        databaseRef?.child("data").observe(.value) { [weak self] snapshot, _ in
            guard let self,
                  let json = snapshot.value as? [String: Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let decoder = JSONDecoder()
                self.nowPlayingData = try decoder.decode(NowPlayingData.self, from: data)
                print("📡 [CarPlay] Received now playing data with URL: \(self.nowPlayingData?.url.absoluteString ?? "nil")")
                
                if self.isInitialSetup, let url = self.nowPlayingData?.url {
                    print("🎵 [CarPlay] Initial setup - Setting radio URL")
                    self.radioPlayer.stop()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.radioPlayer.enableArtwork = true
                        self.radioPlayer.radioURL = url
                        self.isInitialSetup = false
                        self.updatePlayButtonState() // Update UI but don't play
                    }
                }
            } catch {
                print("❌ [CarPlay] Error decoding now playing data:", error)
            }
        }
        // Rest of the method remains the same...
    }

    private func handlePlayPause() {
        print("🎵 [CarPlay] Play/Pause requested")
        print("🎵 [CarPlay] Current state - isPlaying: \(radioPlayer.isPlaying), state: \(radioPlayer.state.rawValue)")
        
        if radioPlayer.isPlaying {
            radioPlayer.stop()
        } else {
            if radioPlayer.radioURL == nil {
                if let url = nowPlayingData?.url {
                    radioPlayer.radioURL = url
                } else {
                    print("❌ [CarPlay] No URL available for playback")
                    return
                }
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                radioPlayer.play()
            } catch {
                print("❌ [CarPlay] Failed to set up audio session or play:", error)
            }
        }
        // Update button state after action
        DispatchQueue.main.async {
            self.updatePlayButtonState()
        }
    }

    private func updatePlayButtonState() {
        let isPlaying = radioPlayer.isPlaying
        print("🎵 [CarPlay] Updating button - isPlaying: \(isPlaying), state: \(radioPlayer.state.rawValue)")
        
        // Create SF Symbol image for play or pause
        let buttonImage = UIImage(
            systemName: isPlaying ? "pause.fill" : "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)
        ) ?? UIImage()
        
        // Initialize with just the handler and then set the image
        let playPauseButton = CPNowPlayingButton { [weak self] button in
            self?.handlePlayPause()
        }
        
        // Since we can't set image in init, we'll need to update the template differently
        nowPlayingTemplate?.updateNowPlayingButtons([playPauseButton])
        
        // Update MPNowPlayingInfoCenter to reflect the state visually
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
