import Foundation

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

        return parseSearchHTML(html)
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

        let urlPattern = #"url:\s*\"(https?://[^\"]+)\""#
        guard let regex = try? NSRegularExpression(pattern: urlPattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              match.numberOfRanges >= 2,
              let range = Range(match.range(at: 1), in: html)
        else {
            print("[Paojiao] No URL found in song page")
            print("[Paojiao] HTML snippet: \(html.prefix(500))")
            throw MusicAPIError.noDownloadURL
        }

        let audioURL = String(html[range])
        print("[Paojiao] Got URL: \(audioURL.prefix(80))...")
        return audioURL
    }

    func getLyrics(songId: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/song.php?id=\(songId)") else {
            throw MusicAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("\(baseURL)", forHTTPHeaderField: "Referer")

        print("[Paojiao] Get lyrics: songId=\(songId)")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else { throw MusicAPIError.serverError }

        guard let html = String(data: data, encoding: .utf8) else {
            throw MusicAPIError.parseError
        }

        let lyricPattern = #"<div class="lyric-item">([^<]+)</div>"#
        guard let regex = try? NSRegularExpression(pattern: lyricPattern) else {
            throw MusicAPIError.parseError
        }

        let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let lines = matches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: html) else { return nil }
            return String(html[range])
        }

        guard !lines.isEmpty else {
            print("[Paojiao] No lyrics found")
            throw MusicAPIError.noData
        }

        print("[Paojiao] Lyrics: \(lines.count) lines")
        return lines.joined(separator: "\n")
    }

    private func parseSearchHTML(_ html: String) -> [Song] {
        let itemPattern = #"<a\s+class="search-result-list-item[^"]*"\s+href="song\.php\?id=(\d+)"[^>]*>.*?<img\s+src="([^"]+)"[^>]*>.*?item-left-song">([^<]+).*?item-left-singer">([^<]+)"#
        guard let regex = try? NSRegularExpression(pattern: itemPattern, options: [.dotMatchesLineSeparators]) else {
            return []
        }

        let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        print("[Paojiao] Parsed \(matches.count) songs from search")

        return matches.compactMap { match -> Song? in
            guard match.numberOfRanges >= 5,
                  let idRange = Range(match.range(at: 1), in: html),
                  let coverRange = Range(match.range(at: 2), in: html),
                  let nameRange = Range(match.range(at: 3), in: html),
                  let artistRange = Range(match.range(at: 4), in: html)
            else { return nil }

            let id = String(html[idRange])
            let cover = String(html[coverRange])
            let name = String(html[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let artist = String(html[artistRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            return Song(id: id, name: name, artist: artist, album: "", coverUrl: cover, duration: 0, formats: [.mp3320, .mp3128])
        }
    }
}
