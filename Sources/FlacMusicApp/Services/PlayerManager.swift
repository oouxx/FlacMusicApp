import AVFoundation
import Combine
import Foundation
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
    private var lyricsLoadTask: Task<Void, Never>?
    public var lastSearchQuery: String = ""

    private init() {
        setupAudioSession()
        #if os(iOS)
            setupRemoteCommandCenter()
        #endif

        MusicAPIService.shared.onCookieRefreshed = { [weak self] in
            guard let self = self else { return }
            Task {
                await self.refreshQueueUrls()
            }
        }

        MusicAPIService.shared.onCookieInvalid = { [weak self] in
            guard let self = self else { return }
            Task {
                await self.handleCookieInvalid()
            }
        }

        MusicAPIService.shared.onSongExpired = { [weak self] in
            guard let self = self else { return }
            Task {
                await self.handleSongExpired()
            }
        }
    }
    private var isHandlingCookieInvalid = false

    private func handleCookieInvalid() async {
        guard !isHandlingCookieInvalid else {
            print("[PlayerManager] handleCookieInvalid: already in progress, skipping")
            return
        }
        isHandlingCookieInvalid = true
        defer { isHandlingCookieInvalid = false }
        let query = lastSearchQuery
        guard !query.isEmpty else { return }

        await MainActor.run {
            playlistManager.queue.removeAll()
            playlistManager.currentIndex = 0
            stop()
        }

        do {
            let results = try await MusicAPIService.shared.searchSongs(
                keyword: query, page: 1, pageSize: 30)
            guard !results.isEmpty else { return }

            // 合并为一次 MainActor 调用，避免重复 setSearchResults
            let song = await MainActor.run {
                playlistManager.setSearchResults(results)
                return playlistManager.currentSong
            }

            if let song = song {
                await playCurrentSong(song)
            }
        } catch {
            print("[PlayerManager] handleCookieInvalid: re-search failed")
        }
    }
    
    private var isHandlingSongExpired = false

    private func handleSongExpired() async {
        guard !isHandlingSongExpired else {
            print("[PlayerManager] handleSongExpired: already in progress, skipping")
            return
        }
        isHandlingSongExpired = true
        defer { isHandlingSongExpired = false }
        
        let query = lastSearchQuery
        guard !query.isEmpty else { return }
        
        do {
            let results = try await MusicAPIService.shared.searchSongs(keyword: query, page: 1, pageSize: 30)
            if !results.isEmpty {
                await MainActor.run {
                    playlistManager.setSearchResults(results)
                }
            }
        } catch {
            print("[PlayerManager] handleSongExpired: re-search failed, trying cookie refresh")
            await MainActor.run {
                CookieStorage.shared.clear()
                MusicAPIService.shared.clearCookies()
            }
            // cookie 清掉后不再重试搜索，等用户触发或心跳恢复
            print("[PlayerManager] handleSongExpired: cookie cleared, waiting for refresh")
        }
    }

    private func refreshQueueUrls() async {
        let songs = await MainActor.run { playlistManager.queue }
        for song in songs {
            do {
                _ = try await MusicAPIService.shared.getSongURL(
                    songId: song.id, format: song.bestFormat)
            } catch {
                print("[PlayerManager] Failed to refresh URL for \(song.name): \(error)")
            }
        }
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

    private func playCurrentSong(_ song: Song, retryCount: Int = 0) async {
        let oldPlayer = player
        let oldObserver = timeObserver
        let oldEndObserver = endObserver

        await MainActor.run {
            isLoading = true
            currentSong = song

            // 清理旧的 time observer
            if let observer = oldObserver, let p = oldPlayer {
                p.removeTimeObserver(observer)
            }
            timeObserver = nil

            // 显式移除旧的 end observer，避免重复触发跳曲
            if let observer = oldEndObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            endObserver = nil

            // 清理旧的订阅，避免 cancellables 无限积累
            cancellables.removeAll()

            oldPlayer?.pause()
        }

        do {
            let urlString = try await MusicAPIService.shared.getSongURL(
                songId: song.id, format: song.bestFormat)
            guard let url = URL(string: urlString) else {
                await MainActor.run { isLoading = false }
                return
            }

            await MainActor.run {
                let playerItem = AVPlayerItem(url: url)
                if player == nil {
                    player = AVPlayer(playerItem: playerItem)
                } else {
                    player?.replaceCurrentItem(with: playerItem)
                }

                playerItem.publisher(for: \.status)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] status in
                        if status == .readyToPlay {
                            self?.duration =
                                playerItem.duration.seconds.isNaN ? 0 : playerItem.duration.seconds
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
                stop()
            }
        }
    }

    private func setupEndObserver() {
        // 先移除旧的，再注册新的，防止重复
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
        }

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
        // 清理 end observer
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }

        // 清理 time observer
        if let observer = timeObserver, let p = player {
            p.removeTimeObserver(observer)
            timeObserver = nil
        }

        cancellables.removeAll()
        lyricsLoadTask?.cancel()
        lyricsLoadTask = nil

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
        lyricsLoadTask?.cancel()
        lyricsLoadTask = Task {
            do {
                // 在网络请求前检查是否已被取消
                try Task.checkCancellation()
                let lyrics = try await MusicAPIService.shared.getLyrics(songId: songId)
                // 请求返回后再次检查，避免写入已切歌的状态
                try Task.checkCancellation()
                await MainActor.run {
                    currentLyrics = lyrics
                }
            } catch is CancellationError {
                print("[PlayerManager] Lyrics load cancelled for \(songId)")
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
        guard let player = player else { return }

        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
            [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds.isNaN ? 0 : time.seconds

            if let duration = self.player?.currentItem?.duration.seconds, !duration.isNaN {
                self.duration = duration
            }
        }
    }

    #if os(iOS)
        private func setupRemoteCommandCenter() {
            let commandCenter = MPRemoteCommandCenter.shared()

            commandCenter.playCommand.isEnabled = true
            commandCenter.playCommand.addTarget { [weak self] _ in
                guard let self = self else { return .commandFailed }
                if !self.isPlaying {
                    if let song = self.currentSong {
                        Task { await self.play(song: song) }
                    }
                }
                return .success
            }

            commandCenter.pauseCommand.isEnabled = true
            commandCenter.pauseCommand.addTarget { [weak self] _ in
                guard let self = self else { return .commandFailed }
                if self.isPlaying {
                    self.togglePlayPause()
                }
                return .success
            }

            commandCenter.nextTrackCommand.isEnabled = true
            commandCenter.nextTrackCommand.addTarget { [weak self] _ in
                self?.playNext()
                return .success
            }

            commandCenter.previousTrackCommand.isEnabled = true
            commandCenter.previousTrackCommand.addTarget { [weak self] _ in
                self?.playPrevious()
                return .success
            }

            commandCenter.changePlaybackPositionCommand.isEnabled = true
            commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
                if let event = event as? MPChangePlaybackPositionCommandEvent {
                    self?.seek(to: event.positionTime)
                }
                return .success
            }
        }
    #endif

    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.name,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyAlbumTitle: song.album,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]

        #if os(iOS)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info

            if let coverUrl = song.coverUrl, let url = URL(string: coverUrl) {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            await MainActor.run {
                                var infoWithArtwork =
                                    MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                                infoWithArtwork[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                                    boundsSize: image.size
                                ) { _ in image }
                                MPNowPlayingInfoCenter.default().nowPlayingInfo = infoWithArtwork
                            }
                        }
                    } catch {
                        print("[PlayerManager] Failed to load cover image: \(error)")
                    }
                }
            }
        #else
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        #endif
    }
}
