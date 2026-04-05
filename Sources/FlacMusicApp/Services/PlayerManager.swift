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
            setupAudioSessionObservers()
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

        // Wait for cookie refresh (max 15s)
        var waited: TimeInterval = 0
        while !MusicAPIService.shared.isCookieValid, waited < 15 {
            try? await Task.sleep(for: .seconds(0.5))
            waited += 0.5
        }

        guard MusicAPIService.shared.isCookieValid else {
            print("[PlayerManager] handleCookieInvalid: cookie refresh timed out")
            return
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
            print("[PlayerManager] handleCookieInvalid: re-search failed: \(error)")
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
        let provider = MusicAPIService.shared.currentProviderPublic
        for song in songs {
            if cache.cachedURL(provider: provider, songId: song.id, format: song.bestFormat) != nil { continue }
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

        let provider = MusicAPIService.shared.currentProviderPublic
        if cache.cachedURL(provider: provider, songId: nextSong.id, format: nextSong.bestFormat) != nil {
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
                guard let url = URL(string: urlString) else { return }
                let tempURL = try await self.downloadToTemp(url: url)
                self.cache.store(
                    tempURL: tempURL, provider: provider, songId: nextSong.id, format: nextSong.bestFormat)
                print("[PlayerManager] Prefetch cached: \(nextSong.name)")
            } catch is CancellationError {
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
            print("[PlayerManager] Failed to setup audio session: \(error)")
        }
        #endif
    }

    #if os(iOS)
    private func setupAudioSessionObservers() {
        // 打断监听（来电话、Siri、其他 App 抢占音频）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )

        // 路由变化监听（拔耳机等）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )

        // App 进入后台/前台时确保 session 激活
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        switch type {
        case .began:
            print("[PlayerManager] Audio session interrupted (began)")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.isPlaying {
                    self.player?.pause()
                    self.isPlaying = false
                    self.updateNowPlayingInfo()
                }
            }

        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            print("[PlayerManager] Audio session interruption ended, shouldResume=\(options.contains(.shouldResume))")

            if options.contains(.shouldResume) {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                        self.player?.play()
                        self.isPlaying = true
                        self.updateNowPlayingInfo()
                    } catch {
                        print("[PlayerManager] Failed to reactivate audio session: \(error)")
                        // session 激活失败时尝试重新播放当前歌曲
                        if let song = self.currentSong {
                            Task { await self.playCurrentSong(song) }
                        }
                    }
                }
            }

        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else { return }

        switch reason {
        case .oldDeviceUnavailable:
            // 拔耳机，iOS 惯例暂停
            print("[PlayerManager] Output device disconnected, pausing")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.player?.pause()
                self.isPlaying = false
                self.updateNowPlayingInfo()
            }

        case .newDeviceAvailable:
            // 插入耳机，不自动恢复（遵循系统惯例）
            print("[PlayerManager] New output device available")

        default:
            break
        }
    }

    @objc private func handleAppBecomeActive() {
        // App 回到前台时确保 AVAudioSession 仍然激活
        guard isPlaying else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[PlayerManager] Failed to reactivate session on foreground: \(error)")
        }
    }
    #endif

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
            let provider = MusicAPIService.shared.currentProviderPublic

            if let cachedURL = cache.cachedURL(provider: provider, songId: song.id, format: song.bestFormat) {
                print("[PlayerManager] Cache hit: \(song.name)")
                playURL = cachedURL
            } else {
                print("[PlayerManager] Cache miss: \(song.name), fetching remote URL")
                let urlString = try await MusicAPIService.shared.getSongURL(
                    songId: song.id, format: song.bestFormat)
                guard let remoteURL = URL(string: urlString) else {
                    await MainActor.run { isLoading = false }
                    return
                }

                Task.detached(priority: .background) { [weak self] in
                    guard let self = self else { return }
                    do {
                        let tempURL = try await self.downloadToTemp(url: remoteURL)
                        self.cache.store(
                            tempURL: tempURL, provider: provider, songId: song.id, format: song.bestFormat)
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

                // 监听 playerItem 状态，包括 .failed
                playerItem.publisher(for: \.status)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] status in
                        guard let self else { return }
                        switch status {
                        case .readyToPlay:
                            self.duration =
                                playerItem.duration.seconds.isNaN
                                ? 0 : playerItem.duration.seconds
                            self.isLoading = false

                        case .failed:
                            let err = playerItem.error?.localizedDescription ?? "unknown"
                            print("[PlayerManager] PlayerItem failed: \(err)")
                            self.isLoading = false
                            // If cache hit failed, delete corrupted file and retry with remote
                            if let song = self.currentSong,
                               let cachedURL = self.cache.cachedURL(
                                   provider: MusicAPIService.shared.currentProviderPublic,
                                   songId: song.id, format: song.bestFormat) {
                                print("[PlayerManager] Cache file corrupted, deleting: \(song.name)")
                                self.cache.deleteEntry(AudioCacheManager.CacheEntryInfo(
                                    id: self.cache.cacheKey(
                                        provider: MusicAPIService.shared.currentProviderPublic,
                                        songId: song.id, format: song.bestFormat),
                                    provider: MusicAPIService.shared.currentProviderPublic,
                                    songId: song.id,
                                    format: song.bestFormat,
                                    fileSize: 0,
                                    lastAccessed: Date()
                                ))
                            }
                            if let song = self.currentSong {
                                Task { await self.playCurrentSong(song, retryCount: 1) }
                            }

                        default:
                            break
                        }
                    }
                    .store(in: &cancellables)

                // 监听 AVPlayer 自身状态
                self.player?.publisher(for: \.timeControlStatus)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] status in
                        guard let self else { return }
                        switch status {
                        case .playing:
                            if !self.isPlaying { self.isPlaying = true }
                        case .paused:
                            // 只有用户主动暂停才同步，不要覆盖 isPlaying
                            break
                        case .waitingToPlayAtSpecifiedRate:
                            // 缓冲中，不做额外处理
                            break
                        @unknown default:
                            break
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
            if !self.isPlaying {
                self.player?.play()
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
