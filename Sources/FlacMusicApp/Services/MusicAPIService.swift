import Foundation
import WebKit
import Combine

public final class MusicAPIService: @unchecked Sendable {
    
    public static let shared = MusicAPIService()
    
    private let hiCNBase = "https://flac.music.hi.cn"
    private let kuwoSearchBase = "https://www.kuwo.cn/api/www/search/searchMusicBykeyWord"
    private let kuwoSongURLBase = "https://www.kuwo.cn/api/v1/www/music/playUrl"
    
    private let session: URLSession
    
    private var cookieString: String = ""
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 120
        session = URLSession(configuration: config)
    }
    
    public func updateCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            let cookieStr = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            self?.cookieString = cookieStr
        }
    }
    
    // MARK: - Search Songs
    
    public func searchSongs(keyword: String, page: Int = 1, pageSize: Int = 30) async throws -> [Song] {
        guard !cookieString.isEmpty else {
            throw MusicAPIError.cookiesRequired
        }
        
        let url = URL(string: "\(hiCNBase)/ajax.php?act=search")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(cookieString, forHTTPHeaderField: "Cookie")
        request.setValue(hiCNBase, forHTTPHeaderField: "Referer")
        request.setValue(hiCNBase, forHTTPHeaderField: "Origin")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        
        let body = "platform=kuwo&keyword=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword)&page=\(page)&size=\(pageSize)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MusicAPIError.serverError
        }
        
        return try parseSearchResponse(data)
    }
    
    // MARK: - Get Download URL
    
    public func getSongURL(songId: String, format: AudioFormat) async throws -> String {
        guard !cookieString.isEmpty else {
            throw MusicAPIError.cookiesRequired
        }
        
        let url = URL(string: "\(hiCNBase)/api/url?id=\(songId)&type=\(format.rawValue)")!
        var request = URLRequest(url: url)
        request.setValue(cookieString, forHTTPHeaderField: "Cookie")
        request.setValue(hiCNBase, forHTTPHeaderField: "Referer")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await session.data(for: request)
        
        if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           text.hasPrefix("http") {
            return text
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let urlStr = json["url"] as? String, urlStr.hasPrefix("http") {
            return urlStr
        }
        
        throw MusicAPIError.noDownloadURL
    }
    
    // MARK: - Private
    
    private func parseSearchResponse(_ data: Data) throws -> [Song] {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let list = json["data"] as? [[String: Any]] {
                return list.compactMap { parseSongDict($0) }
            }
            if let info = json["info"] as? [[String: Any]] {
                return info.compactMap { parseSongDict($0) }
            }
        }
        
        if let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return list.compactMap { parseSongDict($0) }
        }
        
        throw MusicAPIError.parseError
    }
    
    // MARK: - Get Lyrics
    
    public func getLyrics(songId: String) async throws -> String {
        let urlString = "\(hiCNBase)/api/lrc?id=\(songId)"
        guard let url = URL(string: urlString) else {
            throw MusicAPIError.invalidURL
        }
        let (data, _) = try await session.data(from: url)
        
        // Response may be plain text or JSON with lrc field
        if let text = String(data: data, encoding: .utf8) {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let lrc = json["lrc"] as? String {
                return lrc
            }
            return text
        }
        throw MusicAPIError.noData
    }
    
    // MARK: - Private Helpers
    
    private func fetchHiCNSearch(urlString: String, keyword: String) async throws -> [Song] {
        guard let url = URL(string: urlString) else { throw MusicAPIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue("https://flac.music.hi.cn", forHTTPHeaderField: "Referer")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MusicAPIError.serverError
        }
        
        // Parse the response (hi.cn likely returns a JSON array or object)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Possible shapes: {data: [{...}]} or {list: [...]} or direct array
            let list = json["data"] as? [[String: Any]] 
                    ?? json["list"] as? [[String: Any]]
                    ?? json["songs"] as? [[String: Any]]
                    ?? []
            return list.compactMap { parseSongDict($0) }
        }
        
        if let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return list.compactMap { parseSongDict($0) }
        }
        
        throw MusicAPIError.parseError
    }
    
    private func fetchHiCNSongURL(urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else { throw MusicAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue("https://flac.music.hi.cn", forHTTPHeaderField: "Referer")
        
        let (data, _) = try await session.data(for: request)
        
        // Could be plain URL string, or JSON
        if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           text.hasPrefix("http") {
            return text
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let urlStr = json["url"] as? String, urlStr.hasPrefix("http") {
                return urlStr
            }
            if let urlStr = json["data"] as? String, urlStr.hasPrefix("http") {
                return urlStr
            }
        }
        
        throw MusicAPIError.noDownloadURL
    }
    
    private func fetchKuwoSearch(keyword: String, page: Int, pageSize: Int) async throws -> [Song] {
        guard var components = URLComponents(string: kuwoSearchBase) else {
            throw MusicAPIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "key", value: keyword),
            URLQueryItem(name: "pn", value: String(page)),
            URLQueryItem(name: "rn", value: String(pageSize)),
            URLQueryItem(name: "httpsStatus", value: "1"),
            URLQueryItem(name: "reqId", value: UUID().uuidString.lowercased())
        ]
        
        guard let url = components.url else { throw MusicAPIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue("https://www.kuwo.cn", forHTTPHeaderField: "Referer")
        request.setValue("https://www.kuwo.cn", forHTTPHeaderField: "Origin")
        // Kuwo requires a csrf token — in a real app you'd fetch it first
        request.setValue("0", forHTTPHeaderField: "csrf")
        
        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode(KuwoSearchResponse.self, from: data)
        return decoded.data?.list?.map { $0.toSong } ?? []
    }
    
    private func fetchKuwoSongURL(songId: String, format: AudioFormat) async throws -> String {
        guard var components = URLComponents(string: kuwoSongURLBase) else {
            throw MusicAPIError.invalidURL
        }
        
        let formatParam: String
        switch format {
        case .flac: formatParam = "flac"
        case .ape: formatParam = "ape"
        case .mp3320: formatParam = "mp3"
        case .mp3128: formatParam = "mp3"
        }
        
        components.queryItems = [
            URLQueryItem(name: "musicId", value: songId),
            URLQueryItem(name: "type", value: formatParam),
            URLQueryItem(name: "httpsStatus", value: "1"),
            URLQueryItem(name: "reqId", value: UUID().uuidString.lowercased())
        ]
        
        guard let url = components.url else { throw MusicAPIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.setValue("https://www.kuwo.cn", forHTTPHeaderField: "Referer")
        request.setValue("0", forHTTPHeaderField: "csrf")
        
        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode(KuwoSongURLResponse.self, from: data)
        
        guard let urlStr = decoded.url, !urlStr.isEmpty else {
            throw MusicAPIError.noDownloadURL
        }
        return urlStr
    }
    
    private func parseSongDict(_ dict: [String: Any]) -> Song? {
        guard let idRaw = dict["rid"] ?? dict["id"] ?? dict["songid"],
              let name = dict["name"] as? String ?? dict["title"] as? String else {
            return nil
        }
        
        let id = "\(idRaw)"
        let artist = dict["artist"] as? String 
            ?? dict["singer"] as? String 
            ?? dict["artistName"] as? String 
            ?? "未知歌手"
        let album = dict["album"] as? String 
            ?? dict["albumName"] as? String 
            ?? "未知专辑"
        let cover = dict["pic"] as? String 
            ?? dict["cover"] as? String 
            ?? dict["album_img"] as? String
        let duration = dict["duration"] as? Int ?? 0
        
        var formats: [AudioFormat] = []
        if let hasFlac = dict["hasFlac"] as? Int, hasFlac == 1 { formats.append(.flac) }
        if let hasMp3 = dict["hasMp3"] as? Int, hasMp3 == 1 { formats.append(.mp3320) }
        if formats.isEmpty { formats = [.mp3320, .mp3128] }
        
        return Song(id: id, name: name, artist: artist, album: album,
                   coverUrl: cover, duration: duration, formats: formats)
    }
}

// MARK: - Errors

public enum MusicAPIError: LocalizedError {
    case invalidURL
    case serverError
    case parseError
    case noDownloadURL
    case noData
    case networkError(Error)
    case cookiesRequired
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的请求地址"
        case .serverError: return "服务器错误"
        case .parseError: return "数据解析失败"
        case .noDownloadURL: return "无法获取下载链接（可能需要会员）"
        case .noData: return "没有返回数据"
        case .networkError(let e): return "网络错误: \(e.localizedDescription)"
        case .cookiesRequired: return "正在获取验证信息，请稍后重试"
        }
    }
}
