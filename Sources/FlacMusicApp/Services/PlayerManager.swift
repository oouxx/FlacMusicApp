import Foundation
import AVFoundation
import Combine
import MediaPlayer

public final class PlayerManager: ObservableObject {
    
    public static let shared = PlayerManager()
    
    @Published public var currentSong: Song?
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: Double = 0
    @Published public var duration: Double = 0
    @Published public var isLoading: Bool = false
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }
    
    // MARK: - Playback Control
    
    public func play(song: Song) async {
        await MainActor.run {
            isLoading = true
            currentSong = song
        }
        
        do {
            let urlString = try await MusicAPIService.shared.getSongURL(songId: song.id, format: song.bestFormat)
            guard let url = URL(string: urlString) else {
                await MainActor.run { isLoading = false }
                return
            }
            
            await MainActor.run {
                let playerItem = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: playerItem)
                
                // Observe duration
                playerItem.publisher(for: \.status)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] status in
                        if status == .readyToPlay {
                            self?.duration = playerItem.duration.seconds.isNaN ? 0 : playerItem.duration.seconds
                            self?.isLoading = false
                        }
                    }
                    .store(in: &cancellables)
                
                setupTimeObserver()
                player?.play()
                isPlaying = true
                
                updateNowPlayingInfo()
            }
        } catch {
            await MainActor.run {
                isLoading = false
                currentSong = nil
            }
        }
    }
    
    public func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        updateNowPlayingInfo()
    }
    
    public func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentSong = nil
        currentTime = 0
        duration = 0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    public func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
        updateNowPlayingInfo()
    }
    
    // MARK: - Private
    
    private func setupTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds.isNaN ? 0 : time.seconds
            
            if let duration = self.player?.currentItem?.duration.seconds, !duration.isNaN {
                self.duration = duration
            }
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.name,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyAlbumTitle: song.album,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        
        #if os(iOS)
        if let coverUrl = song.coverUrl, let url = URL(string: coverUrl) {
            Task {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    }
                }
            }
        }
        #endif
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
