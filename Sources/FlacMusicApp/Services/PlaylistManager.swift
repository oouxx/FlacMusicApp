import Foundation

public enum PlayMode: String, CaseIterable, Sendable {
    case normal
    case loopAll
    case loopOne
    case shuffle

    public var icon: String {
        switch self {
        case .normal:  return "play.fill"
        case .loopAll: return "repeat"
        case .loopOne: return "repeat.1"
        case .shuffle: return "shuffle"
        }
    }

    public var next: PlayMode {
        switch self {
        case .normal:  return .loopAll
        case .loopAll: return .loopOne
        case .loopOne: return .shuffle
        case .shuffle: return .normal
        }
    }
}

public final class PlaylistManager: ObservableObject {
    public static let shared = PlaylistManager()

    @Published public var queue: [Song] = []
    @Published public var currentIndex: Int = 0
    @Published public var playMode: PlayMode = .normal

    private var shuffleOrder: [Int] = []

    private init() {}

    // MARK: - Shuffle

    private func syncShuffleOrder() {
        guard playMode == .shuffle && !queue.isEmpty else {
            shuffleOrder = []
            return
        }
        let currentId = currentSong?.id
        shuffleOrder = Array(0..<queue.count).shuffled()
        // 保证当前歌在 shuffle 序列首位
        if let id = currentId,
           let queueIdx = queue.firstIndex(where: { $0.id == id }),
           let shuffleIdx = shuffleOrder.firstIndex(of: queueIdx) {
            shuffleOrder.swapAt(0, shuffleIdx)
        }
    }

    // MARK: - Current Song

    public var currentSong: Song? {
        guard currentIndex >= 0 && currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }

    // MARK: - Navigation Capability

    // loopOne 模式下手动点上/下一首仍可切歌（只有自动播放结束时才循环单曲）
    public var hasNext: Bool {
        switch playMode {
        case .loopAll, .shuffle, .loopOne:
            return !queue.isEmpty
        case .normal:
            return currentIndex < queue.count - 1
        }
    }

    public var hasPrevious: Bool {
        switch playMode {
        case .loopAll, .shuffle, .loopOne:
            return !queue.isEmpty
        case .normal:
            return currentIndex > 0
        }
    }

    // MARK: - Queue Management

    public func setSearchResults(_ songs: [Song]) {
        queue = songs
        currentIndex = 0
        syncShuffleOrder()
    }

    public func addToQueue(_ song: Song) {
        if let existingIndex = queue.firstIndex(where: { $0.id == song.id }) {
            currentIndex = existingIndex
            return
        }
        queue.append(song)
        currentIndex = queue.count - 1
        if playMode == .shuffle {
            syncShuffleOrder()
        }
    }

    public func removeFromQueue(at index: Int) {
        guard index >= 0 && index < queue.count else { return }

        let wasPlaying = (index == currentIndex)
        queue.remove(at: index)

        if queue.isEmpty {
            currentIndex = 0
            shuffleOrder = []
            PlayerManager.shared.stop()
            return
        }

        if wasPlaying {
            // 删除当前曲，播放同位置的新歌（或最后一首）
            currentIndex = min(index, queue.count - 1)
            if playMode == .shuffle {
                syncShuffleOrder()
            }
            if let song = currentSong {
                Task { await PlayerManager.shared.play(song: song) }
            }
        } else {
            if currentIndex > index {
                currentIndex -= 1
            }
            if playMode == .shuffle {
                syncShuffleOrder()
            }
        }
    }

    public func clearQueue() {
        queue.removeAll()
        currentIndex = 0
        shuffleOrder.removeAll()
        PlayerManager.shared.stop()
    }

    public func play(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        currentIndex = index
    }

    // MARK: - Playback Order

    public func playNext() {
        guard !queue.isEmpty else { return }

        switch playMode {
        case .loopOne:
            // 手动下一首时跳到真正的下一首，不循环单曲
            currentIndex = (currentIndex + 1) % queue.count
        case .loopAll:
            currentIndex = (currentIndex + 1) % queue.count
        case .shuffle:
            if let currentShuffleIdx = shuffleOrder.firstIndex(of: currentIndex) {
                let nextShuffleIdx = (currentShuffleIdx + 1) % shuffleOrder.count
                currentIndex = shuffleOrder[nextShuffleIdx]
            }
        case .normal:
            if currentIndex < queue.count - 1 {
                currentIndex += 1
            }
        }
    }

    public func playPrevious() {
        guard !queue.isEmpty else { return }

        switch playMode {
        case .loopOne:
            // 手动上一首时跳到真正的上一首，不循环单曲
            currentIndex = (currentIndex - 1 + queue.count) % queue.count
        case .loopAll:
            currentIndex = (currentIndex - 1 + queue.count) % queue.count
        case .shuffle:
            if let currentShuffleIdx = shuffleOrder.firstIndex(of: currentIndex) {
                let prevShuffleIdx = (currentShuffleIdx - 1 + shuffleOrder.count) % shuffleOrder.count
                currentIndex = shuffleOrder[prevShuffleIdx]
            }
        case .normal:
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }

    // MARK: - Play Mode

    public func togglePlayMode() {
        playMode = playMode.next
        // 统一用 syncShuffleOrder 初始化，避免两套逻辑
        syncShuffleOrder()
    }
}
