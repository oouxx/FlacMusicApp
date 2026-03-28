import Foundation
import Combine

public final class DownloadManager: ObservableObject {
    
    public static let shared = DownloadManager()
    
    @Published public var tasks: [DownloadTask] = []
    
    private var activeTasks: [String: URLSessionDownloadTask] = [:]
    private lazy var downloadSession: URLSession = {
        URLSession(configuration: .default)
    }()
    
    private init() {}
    
    // MARK: - Download
    
    @MainActor
    public func download(song: Song, format: AudioFormat) async {
        // Prevent duplicate
        let isDuplicate = tasks.contains { task in
            guard task.song.id == song.id && task.format == format else { return false }
            switch task.state {
            case .downloading, .completed:
                return true
            default:
                return false
            }
        }
        if isDuplicate { return }
        
        let task = DownloadTask(song: song, format: format)
        tasks.append(task)
        let taskId = task.id
        
        // Update state
        updateTask(id: taskId) { $0.state = .downloading }
        
        do {
            let urlString = try await MusicAPIService.shared.getSongURL(songId: song.id, format: format)
            guard let url = URL(string: urlString) else {
                updateTask(id: taskId) { $0.state = .failed("无效的下载地址") }
                return
            }
            
            let (tempURL, _) = try await downloadSession.download(from: url)
            
            // Save to Downloads
            let fileName = "\(song.artist) - \(song.name).\(format.rawValue)"
            let destURL = downloadsDirectory.appendingPathComponent(sanitize(fileName))
            
            try? FileManager.default.removeItem(at: destURL)
            try FileManager.default.moveItem(at: tempURL, to: destURL)
            
            updateTask(id: taskId) { 
                $0.state = .completed
                $0.progress = 1.0
                $0.localURL = destURL
            }
        } catch {
            updateTask(id: taskId) { $0.state = .failed(error.localizedDescription) }
        }
    }
    
    @MainActor
    public func removeTask(_ task: DownloadTask) {
        tasks.removeAll { $0.id == task.id }
    }
    
    @MainActor
    public func clearCompleted() {
        tasks.removeAll {
            if case .completed = $0.state { return true }
            return false
        }
    }
    
    // MARK: - Helpers
    
    @MainActor
    private func updateTask(id: String, update: (inout DownloadTask) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        update(&tasks[index])
    }
    
    private var downloadsDirectory: URL {
        #if os(macOS)
        return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        #else
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        #endif
    }
    
    private func sanitize(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return name.components(separatedBy: invalid).joined(separator: "_")
    }
}
