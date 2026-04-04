import Foundation
import WebKit

final class HiCNProvider: MusicProviderProtocol {
    let provider: MusicProvider = .hiCN
    var source: MusicSource
    var needsCookie: Bool { true }

    private let session: URLSession
    private let hiCNBase = "https://flac.music.hi.cn"
    private let kuwoSongURLBase = "https://www.kuwo.cn/api/v1/www/music/playUrl"
    private var signCache: [String: String] = [:]
    private var timeCache: [String: Int] = [:]

    var onCookieInvalid: (() -> Void)?
    var onSongExpired: (() -> Void)?

    init(session: URLSession = .shared, source: MusicSource = .kuwo) {
        self.session = session
        self.source = source
    }

    func searchSongs(keyword: String, page: Int, pageSize: Int) async throws -> [Song] {
        guard let url = URL(string: "\(hiCNBase)/ajax.php?act=search") else {
            throw MusicAPIError.invalidURL
        }

        let currentCookie = getCurrentCookie()
        guard let cookie = currentCookie, !cookie.isEmpty else {
            onCookieInvalid?()
            throw MusicAPIError.cookiesRequired
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.setValue(hiCNBase, forHTTPHeaderField: "Referer")
        request.setValue(hiCNBase, forHTTPHeaderField: "Origin")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")

        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let body = "platform=\(source.hiCNRawValue)&keyword=\(encodedKeyword)&page=\(page)&size=\(pageSize)"
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw MusicAPIError.serverError }

        guard (200...299).contains(httpResponse.statusCode) else {
            handleAPIError(statusCode: httpResponse.statusCode, currentCookie: cookie)
            throw MusicAPIError.serverError
        }

        let firstByte = data.first
        guard firstByte == 123 || firstByte == 91 else {
            CookieStorage.shared.markCookieInvalid(cookie)
            onCookieInvalid?()
            throw MusicAPIError.serverError
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let code = json["code"] as? Int, code != 0 {
            onSongExpired?()
            throw MusicAPIError.serverError
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataObj = json["data"] as? [String: Any],
           let list = dataObj["list"] as? [[String: Any]] {
            for item in list {
                if let id = item["id"] as? String {
                    if let timeVal = item["time"] as? Int { timeCache[id] = timeVal }
                    if let sign = item["sign"] as? String { signCache[id] = sign }
                }
            }
            return list.compactMap { parseSongDict($0) }
        }

        if let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return list.compactMap { parseSongDict($0) }
        }

        throw MusicAPIError.parseError
    }

    func getSongURL(songId: String, format: AudioFormat) async throws -> String {
        guard let url = URL(string: "\(hiCNBase)/ajax.php?act=getUrl") else {
            throw MusicAPIError.invalidURL
        }

        let currentCookie = getCurrentCookie()
        guard let cookie = currentCookie, !cookie.isEmpty else {
            onCookieInvalid?()
            throw MusicAPIError.cookiesRequired
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
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

        let requestTime = timeCache[songId] ?? Int(Date().timeIntervalSince1970)
        let sign = signCache[songId] ?? ""
        var body = "platform=\(source.hiCNRawValue)&songid=\(songId)&format=\(format.rawValue)&bitrate=\(bitrate)&time=\(requestTime)"
        if !sign.isEmpty { body += "&sign=\(sign)" }
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                handleAPIError(statusCode: httpResponse.statusCode, currentCookie: cookie)
            }
            throw MusicAPIError.serverError
        }

        let firstByte = data.first
        let isPlainURL = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("http") ?? false
        let isJSON = firstByte == 123 || firstByte == 91
        guard isPlainURL || isJSON else {
            CookieStorage.shared.markCookieInvalid(cookie)
            onCookieInvalid?()
            throw MusicAPIError.serverError
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let code = json["code"] as? Int, code != 0 {
            signCache.removeAll()
            timeCache.removeAll()
            throw MusicAPIError.serverError
        }

        if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           text.hasPrefix("http") {
            return text
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let urlStr = json["url"] as? String, urlStr.hasPrefix("http") { return urlStr }
            if let dataObj = json["data"] as? [String: Any],
               let urlStr = dataObj["url"] as? String, urlStr.hasPrefix("http") { return urlStr }
        }

        throw MusicAPIError.noDownloadURL
    }

    func getLyrics(songId: String) async throws -> String {
        guard let url = URL(string: "\(hiCNBase)/ajax.php?act=getLyric") else {
            throw MusicAPIError.invalidURL
        }

        let currentCookie = getCurrentCookie()
        guard let cookie = currentCookie, !cookie.isEmpty else {
            onCookieInvalid?()
            throw MusicAPIError.cookiesRequired
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.setValue(hiCNBase, forHTTPHeaderField: "Referer")
        request.setValue(hiCNBase, forHTTPHeaderField: "Origin")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")

        let cachedSign = signCache[songId] ?? ""
        let cachedTime = timeCache[songId] ?? Int(Date().timeIntervalSince1970)
        var body = "platform=\(source.hiCNRawValue)&songid=\(songId)&time=\(cachedTime)"
        if !cachedSign.isEmpty { body += "&sign=\(cachedSign)" }
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                handleAPIError(statusCode: httpResponse.statusCode, currentCookie: cookie)
            }
            throw MusicAPIError.serverError
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let code = json["code"] as? Int, code != 0 {
                handleAPIErrorWithCode(code, currentCookie: cookie)
            }
            if let lrc = json["data"] as? String {
                return lrc
            }
        }

        throw MusicAPIError.noData
    }

    private func getCurrentCookie() -> String? {
        CookieStorage.shared.getNextValidCookie()
    }

    private func handleAPIError(statusCode: Int, currentCookie: String) {
        CookieStorage.shared.markCookieInvalid(currentCookie)
        signCache.removeAll()
        timeCache.removeAll()
        if CookieStorage.shared.getNextValidCookie() == nil {
            onCookieInvalid?()
        }
    }

    private func handleAPIErrorWithCode(_ code: Int, currentCookie: String) {
        CookieStorage.shared.markCookieInvalid(currentCookie)
        signCache.removeAll()
        timeCache.removeAll()
    }

    private func parseSongDict(_ dict: [String: Any]) -> Song? {
        guard let idRaw = dict["rid"] ?? dict["id"] ?? dict["songid"],
              let name = dict["name"] as? String ?? dict["title"] as? String
        else { return nil }

        let id = "\(idRaw)"
        let artist = dict["artist"] as? String ?? dict["singer"] as? String ?? dict["artistName"] as? String ?? "未知歌手"
        let album = dict["album"] as? String ?? dict["albumName"] as? String ?? dict["album_name"] as? String ?? "未知专辑"
        let cover = dict["pic"] as? String ?? dict["cover"] as? String ?? dict["album_img"] as? String ?? dict["pic_url"] as? String ?? dict["picurl"] as? String

        var duration: Int = 0
        if let dur = dict["duration"] {
            if let durInt = dur as? Int { duration = durInt }
            else if let durStr = dur as? String, let durInt = Int(durStr) { duration = durInt }
        }

        var formats: [AudioFormat] = []
        if let minfo = dict["minfo"] as? [[String: Any]] {
            for formatInfo in minfo {
                if let formatStr = formatInfo["format"] as? String {
                    switch formatStr.lowercased() {
                    case "flac": formats.append(.flac)
                    case "ape": formats.append(.ape)
                    case "mp3":
                        let br: Int?
                        if let bitrate = formatInfo["bitrate"] as? String { br = Int(bitrate) }
                        else { br = formatInfo["bitrate"] as? Int }
                        if let br = br {
                            formats.append(br >= 200 ? .mp3320 : .mp3128)
                        }
                    default: break
                    }
                }
            }
        }
        if formats.isEmpty {
            if let hasFlac = dict["hasFlac"] as? Int, hasFlac == 1 { formats.append(.flac) }
            if let hasSq = dict["hasSQ"] as? Bool, hasSq { formats.append(.flac) }
            if let hasHq = dict["hasHQ"] as? Bool, hasHq { formats.append(.mp3320) }
            if let hasMp3 = dict["hasMp3"] as? Int, hasMp3 == 1 { formats.append(.mp3320) }
            if formats.isEmpty { formats = [.mp3320, .mp3128] }
        }

        return Song(id: id, name: name, artist: artist, album: album, coverUrl: cover, duration: duration, formats: formats)
    }
}
