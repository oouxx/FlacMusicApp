import Foundation
import WebKit
import Combine

public enum MusicPlatform: String, CaseIterable, Sendable {
    case kuwo = "kuwo"
    case netease = "wyy"
    
    var displayName: String {
        switch self {
        case .kuwo: return "酷我"
        case .netease: return "网易云"
        }
    }
}

public final class MusicAPIService: @unchecked Sendable {
    
    public static let shared = MusicAPIService()
    
    private let hiCNBase = "https://flac.music.hi.cn"
    private let kuwoSearchBase = "https://www.kuwo.cn/api/www/search/searchMusicBykeyWord"
    private let kuwoSongURLBase = "https://www.kuwo.cn/api/v1/www/music/playUrl"
    
    private let session: URLSession
    private var cookieString: String = ""
    private var currentPlatform: MusicPlatform = .kuwo
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func updateCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            let cookieStr = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            print("[Cookies] Got \(cookies.count) cookies")
            print("[Cookies] Cookie string: \(cookieStr.prefix(200))")
            self?.cookieString = cookieStr
        }
    }
    
    public func setPlatform(_ platform: MusicPlatform) {
        currentPlatform = platform
    }
    
    // MARK: - Search Songs
    
    public func searchSongs(keyword: String, page: Int = 1, pageSize: Int = 30) async throws -> [Song] {
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        return try await fetchHiCNSearch(keyword: keyword, page: page, pageSize: pageSize, platform: currentPlatform)
    }
    
    // MARK: - Get Download URL
    
    private var signCache: [String: String] = [:]
    private var timeCache: [String: Int] = [:]
    
    public func cacheSign(for songId: String, sign: String) {
        signCache[songId] = sign
    }
    
    public func cacheTime(for songId: String, time: Int) {
        timeCache[songId] = time
    }
    
    public func getSongURL(songId: String, format: AudioFormat, sign: String? = nil, time: Int? = nil) async throws -> String {
        let cachedSign = sign ?? signCache[songId] ?? ""
        let cachedTime = time ?? timeCache[songId]
        return try await fetchHiCNSongURL(songId: songId, format: format, platform: currentPlatform, sign: cachedSign, time: cachedTime)
    }
    
    // MARK: - Get Lyrics
    
    public func getLyrics(songId: String, sign: String? = nil, time: Int? = nil) async throws -> String {
        guard let url = URL(string: "\(hiCNBase)/ajax.php?act=getLyric") else {
            throw MusicAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        if !cookieString.isEmpty {
            request.setValue(cookieString, forHTTPHeaderField: "Cookie")
            print("[Lyrics] Using cookies: \(cookieString.prefix(100))...")
        }
        request.setValue(hiCNBase, forHTTPHeaderField: "Referer")
        request.setValue(hiCNBase, forHTTPHeaderField: "Origin")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let cachedSign = sign ?? signCache[songId] ?? ""
        let cachedTime = time ?? timeCache[songId] ?? Int(Date().timeIntervalSince1970)
        
        var body = "platform=\(currentPlatform.rawValue)&songid=\(songId)&time=\(cachedTime)"
        if !cachedSign.isEmpty {
            body += "&sign=\(cachedSign)"
        }
        request.httpBody = body.data(using: .utf8)
        
        print("[Lyrics] Request body: \(body)")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[Lyrics] Response status: \(httpResponse.statusCode)")
        }
        
        if let responseText = String(data: data, encoding: .utf8) {
            print("[Lyrics] Response: \(responseText.prefix(300))")
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let code = json["code"] as? Int, code != 0 {
                let msg = json["msg"] as? String ?? "unknown error"
                print("[Lyrics] API error: \(code) - \(msg)")
            }
            if let lrc = json["data"] as? String {
                return lrc
            }
        }
        
        throw MusicAPIError.noData
    }
    
    // MARK: - Private
    
    private func fetchHiCNSearch(keyword: String, page: Int, pageSize: Int, platform: MusicPlatform) async throws -> [Song] {
        guard let url = URL(string: "\(hiCNBase)/ajax.php?act=search") else {
            throw MusicAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        if !cookieString.isEmpty {
            request.setValue(cookieString, forHTTPHeaderField: "Cookie")
            print("[MusicAPI] Using cookies: \(cookieString.prefix(100))...")
        } else {
            print("[MusicAPI] WARNING: No cookies available!")
        }
        request.setValue(hiCNBase, forHTTPHeaderField: "Referer")
        request.setValue(hiCNBase, forHTTPHeaderField: "Origin")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let body = "platform=\(platform.rawValue)&keyword=\(encodedKeyword)&page=\(page)&size=\(pageSize)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MusicAPIError.serverError
        }
        
        print("[MusicAPI] Response status: \(httpResponse.statusCode)")
        
        if let responseText = String(data: data, encoding: .utf8) {
            print("[MusicAPI] Response: \(responseText.prefix(200))")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw MusicAPIError.serverError
        }
        
        // Cache signs and times from search results
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataObj = json["data"] as? [String: Any],
           let list = dataObj["list"] as? [[String: Any]] {
            for item in list {
                if let id = item["id"] as? String {
                    if let sign = item["sign"] as? String {
                        signCache[id] = sign
                    }
                    if let timeVal = item["time"] as? Int {
                        timeCache[id] = timeVal
                    }
                }
            }
        }
        
        // Try output.json format first
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let list = json["data"] as? [String: Any],
           let songsList = list["list"] as? [[String: Any]] {
            return songsList.compactMap { parseSongDict($0, platform: platform) }
        }
        
        // Try direct list format
        if let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return list.compactMap { parseSongDict($0, platform: platform) }
        }
        
        throw MusicAPIError.parseError
    }
    
    private func fetchHiCNSongURL(songId: String, format: AudioFormat, platform: MusicPlatform, sign: String = "", time: Int? = nil) async throws -> String {
        guard let url = URL(string: "\(hiCNBase)/ajax.php?act=getUrl") else {
            throw MusicAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        if !cookieString.isEmpty {
            request.setValue(cookieString, forHTTPHeaderField: "Cookie")
            print("[PlayerManager] Using cookies for getURL: \(cookieString.prefix(100))...")
        } else {
            print("[PlayerManager] WARNING: No cookies for getURL!")
        }
        request.setValue(hiCNBase, forHTTPHeaderField: "Referer")
        request.setValue(hiCNBase, forHTTPHeaderField: "Origin")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let bitrate: String
        switch format {
        case .flac: bitrate = "2000"
        case .ape: bitrate = "1000"
        case .mp3320: bitrate = "320"
        case .mp3128: bitrate = "128"
        }
        
        let requestTime = time ?? Int(Date().timeIntervalSince1970)
        var body = "platform=\(platform.rawValue)&songid=\(songId)&format=\(format.rawValue)&bitrate=\(bitrate)&time=\(requestTime)"
        if !sign.isEmpty {
            body += "&sign=\(sign)"
        }
        print("[PlayerManager] Request body: \(body)")
        request.httpBody = body.data(using: .utf8)
        
        print("[PlayerManager] Request body: \(body)")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[PlayerManager] Response status: \(httpResponse.statusCode)")
        }
        
        if let responseText = String(data: data, encoding: .utf8) {
            print("[PlayerManager] Response: \(responseText.prefix(300))")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MusicAPIError.serverError
        }
        
        // Try plain URL string
        if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           text.hasPrefix("http") {
            return text
        }
        
        // Try JSON format
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let urlStr = json["url"] as? String, urlStr.hasPrefix("http") {
                return urlStr
            }
            if let dataObj = json["data"] as? [String: Any],
               let urlStr = dataObj["url"] as? String, urlStr.hasPrefix("http") {
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
        request.setValue("0", forHTTPHeaderField: "csrf")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MusicAPIError.serverError
        }
        
        // Try to parse as Kuwo API response
        if let decoded = try? JSONDecoder().decode(KuwoSearchResponse.self, from: data),
           let songs = decoded.data?.list?.map({ $0.toSong }) {
            if !songs.isEmpty {
                return songs
            }
        }
        
        // Try to parse as output.json format
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let list = json["data"] as? [String: Any],
           let songsList = list["list"] as? [[String: Any]] {
            return songsList.compactMap { parseSongDict($0, platform: .kuwo) }
        }
        
        // Try direct array format
        if let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return list.compactMap { parseSongDict($0, platform: .kuwo) }
        }
        
        throw MusicAPIError.parseError
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
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MusicAPIError.serverError
        }
        
        // Try Kuwo format
        if let decoded = try? JSONDecoder().decode(KuwoSongURLResponse.self, from: data),
           let urlStr = decoded.url, !urlStr.isEmpty {
            return urlStr
        }
        
        // Try output.json format for URL
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let urlStr = json["url"] as? String, urlStr.hasPrefix("http") {
                return urlStr
            }
            if let dataObj = json["data"] as? [String: Any],
               let urlStr = dataObj["url"] as? String, urlStr.hasPrefix("http") {
                return urlStr
            }
        }
        
        throw MusicAPIError.noDownloadURL
    }
    
    private func parseSongDict(_ dict: [String: Any], platform: MusicPlatform) -> Song? {
        // Handle both "id" and "rid" for song ID
        guard let idRaw = dict["rid"] ?? dict["id"] ?? dict["songid"],
              let name = dict["name"] as? String ?? dict["title"] as? String else {
            return nil
        }
        
        let id = "\(idRaw)"
        
        // Handle various artist field names (kuwo + netease)
        let artist = dict["artist"] as? String 
            ?? dict["singer"] as? String 
            ?? dict["artistName"] as? String
            ?? dict["artist_id"] as? String
            ?? dict["ar"] as? String
            ?? "未知歌手"
        
        // Handle various album field names
        let album = dict["album"] as? String 
            ?? dict["albumName"] as? String
            ?? dict["album_name"] as? String
            ?? dict["album_id"] as? String
            ?? dict["al"] as? String
            ?? "未知专辑"
        
        // Handle cover URL
        let cover = dict["pic"] as? String 
            ?? dict["cover"] as? String 
            ?? dict["album_img"] as? String
            ?? dict["pic_url"] as? String
            ?? dict["picurl"] as? String
        
        // Handle duration (can be String or Int)
        var duration: Int = 0
        if let dur = dict["duration"] {
            if let durInt = dur as? Int {
                duration = durInt
            } else if let durStr = dur as? String, let durInt = Int(durStr) {
                duration = durInt
            }
        }
        
        // Parse formats from minfo array (kuwo format)
        var formats: [AudioFormat] = []
        if let minfo = dict["minfo"] as? [[String: Any]] {
            for formatInfo in minfo {
                if let formatStr = formatInfo["format"] as? String {
                    switch formatStr.lowercased() {
                    case "flac":
                        formats.append(.flac)
                    case "ape":
                        formats.append(.ape)
                    case "mp3":
                        if let bitrate = formatInfo["bitrate"] as? String, let br = Int(bitrate) {
                            if br >= 200 {
                                formats.append(.mp3320)
                            } else {
                                formats.append(.mp3128)
                            }
                        } else if let bitrate = formatInfo["bitrate"] as? Int {
                            if bitrate >= 200 {
                                formats.append(.mp3320)
                            } else {
                                formats.append(.mp3128)
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        // Fallback: check for hasFlac/hasMp3 flags
        if formats.isEmpty {
            if let hasFlac = dict["hasFlac"] as? Int, hasFlac == 1 {
                formats.append(.flac)
            }
            if let hasSq = dict["hasSQ"] as? Bool, hasSq == true {
                formats.append(.flac)
            }
            if let hasHq = dict["hasHQ"] as? Bool, hasHq == true {
                formats.append(.mp3320)
            }
            if let hasMp3 = dict["hasMp3"] as? Int, hasMp3 == 1 {
                formats.append(.mp3320)
            }
            if formats.isEmpty {
                formats = [.mp3320, .mp3128]
            }
        }
        
        return Song(id: id, name: name, artist: artist, album: album,
                   coverUrl: cover, duration: duration, formats: formats)
    }
    
    private func cacheSignFromSearch(_ songs: [Song], responseData: Data) {
        if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
           let data = json["data"] as? [String: Any],
           let list = data["list"] as? [[String: Any]] {
            for item in list {
                if let id = item["id"] as? String, let sign = item["sign"] as? String {
                    signCache[id] = sign
                }
            }
        }
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
