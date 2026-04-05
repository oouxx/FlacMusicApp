import Combine
import Foundation
import UniformTypeIdentifiers

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

public final class DownloadManager: ObservableObject {

    public static let shared = DownloadManager()

    @Published public var tasks: [DownloadTask] = []

    private lazy var downloadSession: URLSession = {
        URLSession(configuration: .default)
    }()

    private init() {}

    // MARK: - Download

    public func download(song: Song, format: AudioFormat) async {
        let isDuplicate = await MainActor.run {
            tasks.contains { task in
                guard task.song.id == song.id && task.format == format else { return false }
                switch task.state {
                case .downloading, .completed: return true
                default: return false
                }
            }
        }
        if isDuplicate { return }

        let task = DownloadTask(song: song, format: format)
        let taskId = task.id

        await MainActor.run {
            tasks.append(task)
            updateTask(id: taskId) { $0.state = .downloading }
        }

        do {
            print("[DownloadManager] Getting URL for: \(song.name), format: \(format)")
            let urlString = try await MusicAPIService.shared.getSongURL(
                songId: song.id, format: format)
            print("[DownloadManager] Got URL: \(urlString)")

            guard let url = URL(string: urlString) else {
                await MainActor.run {
                    updateTask(id: taskId) { $0.state = .failed("无效的下载地址") }
                }
                return
            }

            // 优先从缓存复制，避免重复下载
            let provider = MusicAPIService.shared.currentProviderPublic
            let sourceURL: URL
            if let cached = AudioCacheManager.shared.cachedURL(
                provider: provider, songId: song.id, format: format) {
                print("[DownloadManager] Using cached file for: \(song.name)")
                sourceURL = cached
                await MainActor.run {
                    updateTask(id: taskId) { $0.progress = 1.0 }
                }
            } else {
                sourceURL = try await downloadWithProgress(url: url, taskId: taskId)
                // 顺便存入播放缓存
                AudioCacheManager.shared.store(
                    tempURL: sourceURL, provider: provider, songId: song.id, format: format)
            }

            // 确定保存路径
            let fileName = "\(song.artist) - \(song.name).\(format.rawValue)"
            let destURL: URL? = await MainActor.run { () -> URL? in
                #if os(macOS)
                    let savePanel = NSSavePanel()
                    savePanel.nameFieldStringValue = sanitize(fileName)
                    savePanel.allowedContentTypes = [.audio]
                    savePanel.canCreateDirectories = true
                    let response = savePanel.runModal()
                    return response == .OK ? savePanel.url : nil
                #else
                    let documents = FileManager.default.urls(
                        for: .documentDirectory, in: .userDomainMask)[0]
                    let sanitized = sanitize(fileName)
                    var finalName = sanitized
                    var counter = 1
                    while FileManager.default.fileExists(
                        atPath: documents.appendingPathComponent(finalName).path)
                    {
                        let nameWithoutExt = (sanitized as NSString).deletingPathExtension
                        let ext = (sanitized as NSString).pathExtension
                        finalName = "\(nameWithoutExt)_\(counter).\(ext)"
                        counter += 1
                    }
                    return documents.appendingPathComponent(finalName)
                #endif
            }

            guard let finalURL = destURL else {
                await MainActor.run {
                    updateTask(id: taskId) { $0.state = .failed("用户取消") }
                }
                return
            }

            try? FileManager.default.removeItem(at: finalURL)
            try FileManager.default.copyItem(at: sourceURL, to: finalURL)

            await MainActor.run {
                updateTask(id: taskId) {
                    $0.state = .completed
                    $0.progress = 1.0
                    $0.localURL = finalURL
                }
            }
            print("[DownloadManager] Download completed: \(finalURL.lastPathComponent)")

        } catch {
            await MainActor.run {
                updateTask(id: taskId) { $0.state = .failed(error.localizedDescription) }
            }
            print("[DownloadManager] Download failed: \(error)")
        }
    }

    // MARK: - 带进度的下载

    private func downloadWithProgress(url: URL, taskId: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let request = URLRequest(url: url)
            var observation: NSKeyValueObservation?

            let downloadTask = downloadSession.downloadTask(with: request) { tempURL, _, error in
                observation?.invalidate()
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

            observation = downloadTask.observe(\.countOfBytesReceived) { [weak self] task, _ in
                let total = task.countOfBytesExpectedToReceive
                let received = task.countOfBytesReceived
                guard total > 0 else { return }
                let progress = Double(received) / Double(total)
                Task { @MainActor in
                    self?.updateTask(id: taskId) { $0.progress = progress }
                }
            }

            downloadTask.resume()
        }
    }

    // MARK: - Task Management

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

    @MainActor
    private func updateTask(id: String, update: (inout DownloadTask) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        update(&tasks[index])
    }

    private func sanitize(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return name.components(separatedBy: invalid).joined(separator: "_")
    }
}
