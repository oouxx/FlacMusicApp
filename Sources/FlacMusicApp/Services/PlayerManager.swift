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
    @Published public var currentLyrics: String = ""
    
    private let playlistManager = PlaylistManager.shared
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var endObserver: NSObjectProtocol?
    
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
        if playlistManager.queue.isEmpty || playlistManager.currentSong?.id != song.id {
            playlistManager.addToQueue(song)
        }
        
        await playCurrentSong(song)
    }
    
    private func playCurrentSong(_ song: Song) async {
        await MainActor.run {
            isLoading = true
            currentSong = song
            if let observer = timeObserver {
                player?.removeTimeObserver(observer)
                timeObserver = nil
            }
            endObserver = nil
            player?.pause()
            player = nil
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
                setupEndObserver()
                player?.play()
                isPlaying = true
                
                updateNowPlayingInfo()
            }
            
            loadLyrics(songId: song.id)
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func setupEndObserver() {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.handleSongEnded()
        }
    }
    
    private func handleSongEnded() {
        switch playlistManager.playMode {
        case .loopOne:
            seek(to: 0)
            player?.play()
        case .loopAll, .shuffle:
            playlistManager.playNext()
            if let nextSong = playlistManager.currentSong {
                Task { await playCurrentSong(nextSong) }
            }
        case .normal:
            if playlistManager.hasNext {
                playlistManager.playNext()
                if let nextSong = playlistManager.currentSong {
                    Task { await playCurrentSong(nextSong) }
                }
            } else {
                stop()
            }
        }
    }
    
    public func playNext() {
        playlistManager.playNext()
        if let nextSong = playlistManager.currentSong {
            Task { await playCurrentSong(nextSong) }
        }
    }
    
    public func playPrevious() {
        if currentTime > 3 {
            seek(to: 0)
        } else {
            playlistManager.playPrevious()
            if let prevSong = playlistManager.currentSong {
                Task { await playCurrentSong(prevSong) }
            }
        }
    }
    
    public func togglePlayMode() {
        playlistManager.togglePlayMode()
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
        currentLyrics = ""
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func loadLyrics(songId: String) {
        Task {
            do {
                let lyrics = try await MusicAPIService.shared.getLyrics(songId: songId)
                await MainActor.run {
                    currentLyrics = lyrics
                }
            } catch {
                print("[PlayerManager] Failed to load lyrics: \(error)")
            }
        }
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
