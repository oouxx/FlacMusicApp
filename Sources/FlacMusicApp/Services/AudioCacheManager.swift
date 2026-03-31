import Foundation

/// 音乐播放缓存，最大 1GB，LRU 淘汰
/// 和 DownloadManager 职责分离：
///   - AudioCacheManager = 播放时自动缓存，对用户透明
///   - DownloadManager   = 用户主动下载，保存到 Documents
public final class AudioCacheManager: @unchecked Sendable {

    public static let shared = AudioCacheManager()

    // MARK: - Config

    private let maxCacheSize: Int64 = 1 * 1024 * 1024 * 1024  // 1 GB
    private let cacheDir: URL
    private let metaFile: URL
    private let lock = NSLock()

    // MARK: - Meta（LRU 记录）

    private struct CacheMeta: Codable {
        var entries: [String: Entry]  // key = cacheKey

        struct Entry: Codable {
            let fileName: String
            let fileSize: Int64
            var lastAccessed: Date
        }
    }

    private var meta: CacheMeta = .init(entries: [:])

    // MARK: - Init

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDir = caches.appendingPathComponent("FlacMusicApp/AudioCache", isDirectory: true)
        metaFile = cacheDir.appendingPathComponent(".meta.json")

        try? FileManager.default.createDirectory(
            at: cacheDir, withIntermediateDirectories: true)
        loadMeta()
    }

    // MARK: - Public API

    /// 缓存 key：songId + format
    public func cacheKey(songId: String, format: AudioFormat) -> String {
        "\(songId)_\(format.rawValue)"
    }

    /// 检查是否已缓存，返回本地 URL
    public func cachedURL(songId: String, format: AudioFormat) -> URL? {
        let key = cacheKey(songId: songId, format: format)
        lock.lock()
        defer { lock.unlock() }

        guard var entry = meta.entries[key] else { return nil }
        let fileURL = cacheDir.appendingPathComponent(entry.fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // 文件被外部删除，清除 meta
            meta.entries.removeValue(forKey: key)
            saveMeta()
            return nil
        }

        // 更新访问时间（LRU）
        entry.lastAccessed = Date()
        meta.entries[key] = entry
        saveMeta()

        return fileURL
    }

    /// 将下载好的临时文件移入缓存，返回缓存 URL
    @discardableResult
    public func store(tempURL: URL, songId: String, format: AudioFormat) -> URL? {
        let key = cacheKey(songId: songId, format: format)
        let fileName = "\(key).\(format.rawValue)"
        let destURL = cacheDir.appendingPathComponent(fileName)

        lock.lock()
        defer { lock.unlock() }

        do {
            // 已存在则先删掉
            try? FileManager.default.removeItem(at: destURL)
            try FileManager.default.copyItem(at: tempURL, to: destURL)

            let fileSize = (try? FileManager.default.attributesOfItem(
                atPath: destURL.path)[.size] as? Int64) ?? 0

            meta.entries[key] = CacheMeta.Entry(
                fileName: fileName,
                fileSize: fileSize,
                lastAccessed: Date()
            )
            saveMeta()
            evictIfNeeded()
            print("[AudioCache] Stored: \(fileName), size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file))")
            return destURL
        } catch {
            print("[AudioCache] Store failed: \(error)")
            return nil
        }
    }

    /// 当前缓存总大小
    public var currentCacheSize: Int64 {
        lock.lock()
        defer { lock.unlock() }
        return meta.entries.values.reduce(0) { $0 + $1.fileSize }
    }

    /// 缓存条目数
    public var cacheCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return meta.entries.count
    }

    /// 手动清空全部缓存
    public func clearAll() {
        lock.lock()
        defer { lock.unlock() }

        for entry in meta.entries.values {
            let fileURL = cacheDir.appendingPathComponent(entry.fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        meta.entries.removeAll()
        saveMeta()
        print("[AudioCache] All cache cleared")
    }

    // MARK: - LRU 淘汰

    private func evictIfNeeded() {
        var totalSize = meta.entries.values.reduce(0) { $0 + $1.fileSize }
        guard totalSize > maxCacheSize else { return }

        // 按最后访问时间升序排列（最旧的最先淘汰）
        let sorted = meta.entries.sorted { $0.value.lastAccessed < $1.value.lastAccessed }

        for (key, entry) in sorted {
            guard totalSize > maxCacheSize else { break }
            let fileURL = cacheDir.appendingPathComponent(entry.fileName)
            try? FileManager.default.removeItem(at: fileURL)
            totalSize -= entry.fileSize
            meta.entries.removeValue(forKey: key)
            print("[AudioCache] Evicted: \(entry.fileName)")
        }
        saveMeta()
    }

    // MARK: - Meta 持久化

    private func loadMeta() {
        guard let data = try? Data(contentsOf: metaFile),
              let decoded = try? JSONDecoder().decode(CacheMeta.self, from: data)
        else { return }
        meta = decoded

        // 清理 meta 中实际不存在的文件
        var dirty = false
        for (key, entry) in meta.entries {
            let fileURL = cacheDir.appendingPathComponent(entry.fileName)
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                meta.entries.removeValue(forKey: key)
                dirty = true
            }
        }
        if dirty { saveMeta() }
    }

    private func saveMeta() {
        guard let data = try? JSONEncoder().encode(meta) else { return }
        try? data.write(to: metaFile, options: .atomic)
    }
}
