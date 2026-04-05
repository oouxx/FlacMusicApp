import Foundation
import SwiftSoup

final class PaojiaoProvider: MusicProviderProtocol {
    let provider: MusicProvider = .paojiao
    var source: MusicSource
    var needsCookie: Bool { false }

    private let session: URLSession
    private let baseURL = "https://pjmp3.com"

    init(session: URLSession = .shared, source: MusicSource = .kuwo) {
        self.session = session
        self.source = source
    }

    func searchSongs(keyword: String, page: Int, pageSize: Int) async throws -> [Song] {
        guard var components = URLComponents(string: "\(baseURL)/search.php") else {
            throw MusicAPIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "keyword", value: keyword),
        ]
        guard let url = components.url else { throw MusicAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("\(baseURL)", forHTTPHeaderField: "Referer")

        print("[Paojiao] Search: keyword=\(keyword)")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else { throw MusicAPIError.serverError }

        guard let html = String(data: data, encoding: .utf8) else {
            throw MusicAPIError.parseError
        }

        print("[Paojiao] Search response: size=\(html.count) chars")

        return try parseSearchHTML(html)
    }

    func getSongURL(songId: String, format: AudioFormat) async throws -> String {
        guard let url = URL(string: "\(baseURL)/song.php?id=\(songId)") else {
            throw MusicAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("\(baseURL)", forHTTPHeaderField: "Referer")

        print("[Paojiao] Get URL: songId=\(songId), format=\(format.rawValue)")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else { throw MusicAPIError.serverError }

        guard let html = String(data: data, encoding: .utf8) else {
            throw MusicAPIError.parseError
        }

        let doc = try SwiftSoup.parse(html)
        let scripts = try doc.select("script")

        for script in scripts {
            let text = try script.html()
            if text.contains("new APlayer") {
                let pattern = #"url:\s*['"]([^'"]+)['"]"#
                if let range = text.range(of: pattern, options: .regularExpression) {
                    let match = String(text[range])
                    let urlPattern2 = #"['"]([^'"]+)['"]"#
                    if let urlRange = match.range(of: urlPattern2, options: .regularExpression) {
                        let rawURL = String(match[urlRange])
                        let audioURL = rawURL.trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
                        if audioURL.hasPrefix("http") {
                            print("[Paojiao] Got URL: \(audioURL.prefix(100))...")
                            return audioURL
                        }
                    }
                }
            }
        }

        print("[Paojiao] No URL found in APlayer config")
        throw MusicAPIError.noDownloadURL
    }

    func getLyrics(songId: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/song.php?id=\(songId)") else {
            throw MusicAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("\(baseURL)", forHTTPHeaderField: "Referer")
        request.timeoutInterval = 15

        print("[Paojiao] Get lyrics: songId=\(songId)")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else { throw MusicAPIError.serverError }

        guard let html = String(data: data, encoding: .utf8) else {
            throw MusicAPIError.parseError
        }

        let doc = try SwiftSoup.parse(html)
        let items = try doc.select(".lyric-item")
        let lines = try items.array().compactMap { try $0.text() }

        guard !lines.isEmpty else {
            print("[Paojiao] No lyrics found for songId=\(songId)")
            throw MusicAPIError.noData
        }

        print("[Paojiao] Lyrics: \(lines.count) lines")
        return lines.joined(separator: "\n")
    }

    private func parseSearchHTML(_ html: String) throws -> [Song] {
        let doc = try SwiftSoup.parse(html)
        let items = try doc.select("a.search-result-list-item")

        print("[Paojiao] Parsed \(items.array().count) songs from search")

        return try items.array().compactMap { item -> Song? in
            let href = try item.attr("href")
            let id = href.replacingOccurrences(of: "song.php?id=", with: "")
            guard !id.isEmpty, Int(id) != nil else { return nil }

            let img = try item.select("img").first()
            let cover = try img?.attr("src") ?? ""

            let name = try item.select(".search-result-list-item-left-song").first()?.text() ?? ""
            let artist = try item.select(".search-result-list-item-left-singer").first()?.text() ?? ""

            guard !name.isEmpty else { return nil }

            return Song(id: id, name: name, artist: artist, album: "", coverUrl: cover, duration: 0, formats: [.mp3320, .mp3128])
        }
    }
}
