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
    private let cache = AudioCacheManager.shared
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var endObserver: NSObjectProtocol?
    private var lyricsLoadTask: Task<Void, Never>?
    private var prefetchTask: Task<Void, Never>?
    public var lastSearchQuery: String = ""

    private var isHandlingCookieInvalid = false
    private var isHandlingSongExpired = false

    private init() {
        setupAudioSession()
        #if os(iOS)
            setupRemoteCommandCenter()
        #endif

        MusicAPIService.shared.onCookieRefreshed = { [weak self] in
            guard let self = self else { return }
            Task { await self.refreshQueueUrls() }
        }
        MusicAPIService.shared.onCookieInvalid = { [weak self] in
            guard let self = self else { return }
            Task { await self.handleCookieInvalid() }
        }
        MusicAPIService.shared.onSongExpired = { [weak self] in
            guard let self = self else { return }
            Task { await self.handleSongExpired() }
        }
    }

    // MARK: - Cookie / Expiry Handlers

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
            let results = try await MusicAPIService.shared.searchSongs(
                keyword: query, page: 1, pageSize: 30)
            if !results.isEmpty {
                await MainActor.run { playlistManager.setSearchResults(results) }
            }
        } catch {
            print("[PlayerManager] handleSongExpired: clearing cookie")
            await MainActor.run {
                CookieStorage.shared.clear()
                MusicAPIService.shared.clearCookies()
            }
        }
    }

    private func refreshQueueUrls() async {
        let songs = await MainActor.run { playlistManager.queue }
        for song in songs {
            // 已缓存的跳过
            if cache.cachedURL(songId: song.id, format: song.bestFormat) != nil { continue }
            do {
                _ = try await MusicAPIService.shared.getSongURL(
                    songId: song.id, format: song.bestFormat)
            } catch {
                print("[PlayerManager] Failed to refresh URL for \(song.name): \(error)")
            }
        }
    }

    // MARK: - Prefetch

    private func prefetchNextSongURL() {
        prefetchTask?.cancel()
        guard let nextSong = playlistManager.nextSong else { return }

        // 已缓存无需预取
        if cache.cachedURL(songId: nextSong.id, format: nextSong.bestFormat) != nil {
            print("[PlayerManager] Next song already cached: \(nextSong.name)")
            return
        }

        prefetchTask = Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            do {
                try Task.checkCancellation()
                let urlString = try await MusicAPIService.shared.getSongURL(
                    songId: nextSong.id, format: nextSong.bestFormat)
                try Task.checkCancellation()
                // 后台下载并存入缓存
                guard let url = URL(string: urlString) else { return }
                let tempURL = try await self.downloadToTemp(url: url)
                self.cache.store(tempURL: tempURL, songId: nextSong.id, format: nextSong.bestFormat)
                print("[PlayerManager] Prefetch cached: \(nextSong.name)")
            } catch is CancellationError {
                // 正常取消
            } catch {
                print("[PlayerManager] Prefetch failed for \(nextSong.name): \(error)")
            }
        }
    }

    // MARK: - Audio Session

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
        prefetchTask?.cancel()

        await MainActor.run {
            isLoading = true
            currentSong = song
            if let observer = oldObserver, let p = oldPlayer {
                p.removeTimeObserver(observer)
            }
            timeObserver = nil
            if let observer = oldEndObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            endObserver = nil
            cancellables.removeAll()
            oldPlayer?.pause()
        }

        do {
            let playURL: URL

            // 1️⃣ 优先命中缓存，直接本地播放
            if let cachedURL = cache.cachedURL(songId: song.id, format: song.bestFormat) {
                print("[PlayerManager] Cache hit: \(song.name)")
                playURL = cachedURL
            } else {
                // 2️⃣ 未缓存：获取远程 URL
                print("[PlayerManager] Cache miss: \(song.name), fetching remote URL")
                let urlString = try await MusicAPIService.shared.getSongURL(
                    songId: song.id, format: song.bestFormat)
                guard let remoteURL = URL(string: urlString) else {
                    await MainActor.run { isLoading = false }
                    return
                }

                // 3️⃣ 后台下载到临时文件并存入缓存，同时开始流播放
                // 先用远程 URL 流播，下载完成后缓存供下次使用
                Task.detached(priority: .background) { [weak self] in
                    guard let self = self else { return }
                    do {
                        let tempURL = try await self.downloadToTemp(url: remoteURL)
                        self.cache.store(
                            tempURL: tempURL, songId: song.id, format: song.bestFormat)
                        print("[PlayerManager] Background cached: \(song.name)")
                    } catch {
                        print("[PlayerManager] Background cache failed: \(error)")
                    }
                }

                playURL = remoteURL
            }

            await MainActor.run {
                let playerItem = AVPlayerItem(url: playURL)
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
                                playerItem.duration.seconds.isNaN
                                ? 0 : playerItem.duration.seconds
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
            prefetchNextSongURL()

        } catch {
            if retryCount == 0 {
                print("[PlayerManager] URL failed, silently refreshing sign for: \(song.name)")
                let refreshed = await silentRefreshSign(for: song)
                if refreshed {
                    await playCurrentSong(song, retryCount: 1)
                    return
                }
            }
            print("[PlayerManager] Playback failed after retry: \(error)")
            await MainActor.run {
                isLoading = false
                stop()
            }
        }
    }

    private func silentRefreshSign(for song: Song) async -> Bool {
        let query = lastSearchQuery.isEmpty ? song.name : lastSearchQuery
        do {
            let results = try await MusicAPIService.shared.searchSongs(
                keyword: query, page: 1, pageSize: 30)
            return results.contains { $0.id == song.id }
        } catch {
            print("[PlayerManager] silentRefreshSign failed: \(error)")
            return false
        }
    }

    // MARK: - Download Helper

    /// 下载文件到临时目录，供缓存使用
    private func downloadToTemp(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let tempURL = tempURL else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                let keepURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension)
                do {
                    try FileManager.default.moveItem(at: tempURL, to: keepURL)
                    continuation.resume(returning: keepURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }

    // MARK: - End Observer

    private func setupEndObserver() {
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
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
        updateNowPlayingInfo()
    }

    public func stop() {
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }
        if let observer = timeObserver, let p = player {
            p.removeTimeObserver(observer)
            timeObserver = nil
        }
        prefetchTask?.cancel()
        prefetchTask = nil
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

    // MARK: - Lyrics

    private func loadLyrics(songId: String) {
        lyricsLoadTask?.cancel()
        lyricsLoadTask = Task {
            do {
                try Task.checkCancellation()
                let lyrics = try await MusicAPIService.shared.getLyrics(songId: songId)
                try Task.checkCancellation()
                await MainActor.run { currentLyrics = lyrics }
            } catch is CancellationError {
                print("[PlayerManager] Lyrics load cancelled for \(songId)")
            } catch {
                print("[PlayerManager] Failed to load lyrics: \(error)")
            }
        }
    }

    // MARK: - Seek / Time

    public func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
        updateNowPlayingInfo()
    }

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
            if let d = self.player?.currentItem?.duration.seconds, !d.isNaN {
                self.duration = d
            }
        }
    }

    // MARK: - Remote Command Center

    #if os(iOS)
        private func setupRemoteCommandCenter() {
            let commandCenter = MPRemoteCommandCenter.shared()

            commandCenter.playCommand.isEnabled = true
            commandCenter.playCommand.addTarget { [weak self] _ in
                guard let self = self else { return .commandFailed }
                if !self.isPlaying, let song = self.currentSong {
                    Task { await self.play(song: song) }
                }
                return .success
            }
            commandCenter.pauseCommand.isEnabled = true
            commandCenter.pauseCommand.addTarget { [weak self] _ in
                guard let self = self else { return .commandFailed }
                if self.isPlaying { self.togglePlayPause() }
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

    // MARK: - Now Playing Info

    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }
        let info: [String: Any] = [
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
                                var i = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                                i[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                                    boundsSize: image.size) { _ in image }
                                MPNowPlayingInfoCenter.default().nowPlayingInfo = i
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
