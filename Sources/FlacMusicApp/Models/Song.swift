import Foundation

// MARK: - Song Model

public struct Song: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let artist: String
    public let album: String
    public let coverUrl: String?
    public let duration: Int   // seconds
    public let formats: [AudioFormat]
    
    public init(id: String, name: String, artist: String, album: String,
                coverUrl: String?, duration: Int, formats: [AudioFormat]) {
        self.id = id
        self.name = name
        self.artist = artist
        self.album = album
        self.coverUrl = coverUrl
        self.duration = duration
        self.formats = formats
    }
    
    public var durationString: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    public var hasFlac: Bool {
        formats.contains(.flac)
    }
    
    public var bestFormat: AudioFormat {
        if formats.contains(.flac) { return .flac }
        if formats.contains(.ape) { return .ape }
        if formats.contains(.mp3320) { return .mp3320 }
        if formats.contains(.mp3128) { return .mp3128 }
        return formats.first ?? .mp3128
    }
}

// MARK: - Audio Format

public enum AudioFormat: String, Codable, CaseIterable, Sendable {
    case flac = "flac"
    case ape = "ape"
    case mp3320 = "mp3"
    case mp3128 = "128"
    
    public var displayName: String {
        switch self {
        case .flac: return "FLAC"
        case .ape: return "APE"
        case .mp3320: return "320K"
        case .mp3128: return "128K"
        }
    }
    
    public var isLossless: Bool {
        self == .flac || self == .ape
    }
}

// MARK: - Download Task

public struct DownloadTask: Identifiable, Sendable {
    public let id: String
    public let song: Song
    public let format: AudioFormat
    public var progress: Double
    public var state: DownloadState
    public var localURL: URL?
    
    public enum DownloadState: Sendable {
        case pending
        case downloading
        case completed
        case failed(String)
    }
    
    public init(song: Song, format: AudioFormat) {
        self.id = UUID().uuidString
        self.song = song
        self.format = format
        self.progress = 0
        self.state = .pending
    }
}

// MARK: - API Response Models (Kuwo)

struct KuwoSearchResponse: Codable {
    let data: KuwoSearchData?
    let code: Int?
    
    struct KuwoSearchData: Codable {
        let list: [KuwoSong]?
        let total: Int?
        let num: Int?
        let page: Int?
    }
}

struct KuwoSong: Codable {
    let rid: Int?
    let name: String?
    let artist: String?
    let album: String?
    let pic: String?
    let duration: Int?
    let hasFlac: Int?
    let hasMv: Int?
    let songTimeMinutes: String?
    
    var toSong: Song {
        let id = String(rid ?? 0)
        let formats = resolveFormats()
        return Song(
            id: id,
            name: name ?? "未知歌曲",
            artist: artist ?? "未知歌手",
            album: album ?? "未知专辑",
            coverUrl: pic,
            duration: duration ?? 0,
            formats: formats
        )
    }
    
    private func resolveFormats() -> [AudioFormat] {
        var formats: [AudioFormat] = []
        if hasFlac == 1 { formats.append(.flac) }
        formats.append(.mp3320)
        formats.append(.mp3128)
        return formats
    }
}

struct KuwoSongURLResponse: Codable {
    let url: String?
    let code: Int?
    let msg: String?
    let format: String?
    let bitrate: Int?
    let expire: Int?
}
