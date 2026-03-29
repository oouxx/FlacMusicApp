import Foundation
import Combine

public enum PlayMode: String, CaseIterable, Sendable {
    case normal
    case loopAll
    case loopOne
    case shuffle
    
    public var icon: String {
        switch self {
        case .normal: return "play.fill"
        case .loopAll: return "repeat"
        case .loopOne: return "repeat.1"
        case .shuffle: return "shuffle"
        }
    }
    
    public var next: PlayMode {
        switch self {
        case .normal: return .loopAll
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
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        $queue
            .sink { [weak self] newQueue in
                self?.updateShuffleOrder(newQueue)
            }
            .store(in: &cancellables)
    }
    
    private func updateShuffleOrder(_ newQueue: [Song]) {
        queue = newQueue
        if playMode == .shuffle && !queue.isEmpty {
            shuffleOrder = Array(0..<queue.count)
            shuffleOrder.shuffle()
        }
    }
    
    public var currentSong: Song? {
        guard currentIndex >= 0 && currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }
    
    public var hasNext: Bool {
        switch playMode {
        case .loopOne:
            return false
        case .loopAll, .shuffle:
            return !queue.isEmpty
        case .normal:
            return currentIndex < queue.count - 1
        }
    }
    
    public var hasPrevious: Bool {
        switch playMode {
        case .loopOne:
            return false
        case .loopAll, .shuffle:
            return !queue.isEmpty
        case .normal:
            return currentIndex > 0
        }
    }
    
    public func setSearchResults(_ songs: [Song]) {
        queue = songs
        currentIndex = 0
        if playMode == .shuffle && !queue.isEmpty {
            shuffleOrder = Array(0..<queue.count)
            shuffleOrder.shuffle()
        }
    }
    
    public func addToQueue(_ song: Song) {
        if queue.contains(where: { $0.id == song.id }) {
            return
        }
        queue.append(song)
        if playMode == .shuffle {
            shuffleOrder.append(queue.count - 1)
        }
    }
    
    public func playNext() {
        guard !queue.isEmpty else { return }
        
        switch playMode {
        case .loopOne:
            break
        case .loopAll:
            currentIndex = (currentIndex + 1) % queue.count
        case .shuffle:
            if let currentShuffleIndex = shuffleOrder.firstIndex(of: currentIndex) {
                let nextShuffleIndex = (currentShuffleIndex + 1) % shuffleOrder.count
                currentIndex = shuffleOrder[nextShuffleIndex]
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
            break
        case .loopAll:
            currentIndex = (currentIndex - 1 + queue.count) % queue.count
        case .shuffle:
            if let currentShuffleIndex = shuffleOrder.firstIndex(of: currentIndex) {
                let prevShuffleIndex = (currentShuffleIndex - 1 + shuffleOrder.count) % shuffleOrder.count
                currentIndex = shuffleOrder[prevShuffleIndex]
            }
        case .normal:
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }
    
    public func clearQueue() {
        queue.removeAll()
        currentIndex = 0
        shuffleOrder.removeAll()
        PlayerManager.shared.stop()
    }
    
    public func removeFromQueue(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        
        let wasPlaying = (index == currentIndex)
        queue.remove(at: index)
        
        if wasPlaying {
            // 删除当前播放歌曲，停止播放或播放下一首
            if !queue.isEmpty {
                currentIndex = min(currentIndex, queue.count - 1)
            } else {
                currentIndex = 0
                PlayerManager.shared.stop()
            }
        } else if currentIndex > index {
            currentIndex -= 1
        }
        
        if playMode == .shuffle {
            shuffleOrder.removeAll()
            for i in 0..<queue.count {
                shuffleOrder.append(i)
            }
        }
    }
    
    public func togglePlayMode() {
        playMode = playMode.next
        
        if playMode == .shuffle && !queue.isEmpty {
            shuffleOrder = Array(0..<queue.count)
            shuffleOrder.shuffle()
            if let current = queue.firstIndex(where: { $0.id == currentSong?.id }) {
                if let shuffleIdx = shuffleOrder.firstIndex(of: current) {
                    shuffleOrder.remove(at: shuffleIdx)
                    shuffleOrder.insert(current, at: 0)
                }
            }
        }
    }
    
    public func play(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        currentIndex = index
    }
}
