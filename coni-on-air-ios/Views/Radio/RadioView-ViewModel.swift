//
//  LiveView-ViewModel.swift
//  coni-on-air
//

import Foundation
import FirebaseDatabase
import AVFoundation
import MediaPlayer
import FRadioPlayer

extension RadioView {
    @MainActor class ViewModel: NSObject, ObservableObject {
        private lazy var dbPath: DatabaseReference? = {
            let ref = Database.database()
                .reference()
                .child("data")
            return ref
        }()

        @Published var isPlaying: Bool = false
        @Published var nowPlayingData: NowPlayingData?
        @Published var playingState: SwimplyPlayIndicator.AudioState = .stop
        @Published var isLoadingPlayer: Bool = false
        @Published var playerFacedError: Bool = false

        private let decoder = JSONDecoder()
        private let radioPlayer = FRadioPlayer.shared
        
        override init() {
            super.init()
            radioPlayer.delegate = self
            listenForData()
        }

        func listenForData() {
            guard let dbPath = dbPath else {
                return
            }
            dbPath.observe(.value) { [weak self] snapshot in
                guard let self, let json = snapshot.value as? [String: Any] else {
                    return
                }
                do {
                    let data = try JSONSerialization.data(withJSONObject: json)
                    let nowPlayingData = try self.decoder.decode(NowPlayingData.self, from: data)
                    self.nowPlayingData = nowPlayingData
                } catch {
                    print("an error occurred", error)
                }
            } withCancel: { error in
                print(error.localizedDescription)
            }
        }

        func startPlaying() {
            guard let url = nowPlayingData?.url else { return }
            radioPlayer.radioURL = url
            radioPlayer.enableArtwork = true
            radioPlayer.delegate = self
        }

        func playPTapped() {
            if radioPlayer.isPlaying {
                radioPlayer.stop()
            } else {
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                startPlaying()
            }
        }

        func setupNowPlaying(isPlaying: Bool) {
            guard isPlaying else {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
                return
            }
            setupRemoteTransportControls()
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyArtist] = "CONI ON AIR"
            if let songData = nowPlayingData?.songTitle {
                nowPlayingInfo[MPMediaItemPropertyTitle] = songData.uppercased()
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
            if let image = UIImage(named: "image") {
                let artWork = MPMediaItemArtwork(boundsSize: image.size) { (size) -> UIImage in
                    return image
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artWork
            }

            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }

        func setupRemoteTransportControls() {
            let commandCenter = MPRemoteCommandCenter.shared()
            UIApplication.shared.beginReceivingRemoteControlEvents()

            commandCenter.playCommand.isEnabled = true
            commandCenter.playCommand.addTarget { [weak self] event in
                if self?.radioPlayer.radioURL == nil {
                    self?.startPlaying()
                    return .success
                } else if self?.radioPlayer.isPlaying == false {
                    self?.radioPlayer.play()
                    return .success
                } else {
                    return .commandFailed
                }
            }
            [
                commandCenter.seekBackwardCommand,
                commandCenter.seekForwardCommand,
                commandCenter.previousTrackCommand,
                commandCenter.nextTrackCommand,
                commandCenter.skipBackwardCommand,
                commandCenter.skipForwardCommand,
                commandCenter.bookmarkCommand
            ]
                .forEach({
                    $0.isEnabled = false
                })
            commandCenter.pauseCommand.isEnabled = true
            commandCenter.pauseCommand.addTarget { [weak self] event in
                if self?.radioPlayer.isPlaying == true {
                    self?.radioPlayer.pause()
                    return .success
                } else {
                    return .commandFailed
                }
            }

        }
    }
}

extension RadioView.ViewModel: FRadioPlayerDelegate {
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        isPlaying = ((state == .loadingFinished || state == .readyToPlay) && player.playbackState == .playing)
        playingState = isPlaying ? .play : .stop
        isLoadingPlayer = state == .loading
        playerFacedError = state == .error
    }

    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        isPlaying = ((player.state == .loadingFinished || player.state == .readyToPlay) && state == .playing)
        playingState = isPlaying ? .play : .stop
        setupNowPlaying(isPlaying: state == .playing)
    }
}
