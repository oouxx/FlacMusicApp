
import Foundation

final class GDStudioProvider: MusicProviderProtocol {
    let provider: MusicProvider = .gdStudio
    var source: MusicSource
    var needsCookie: Bool { false }

    private let session: URLSession
    private let gdStudioBase = "https://music-api.gdstudio.xyz/api.php"

    init(session: URLSession = .shared, source: MusicSource = .netease) {
        self.session = session
        self.source = source
    }

    func searchSongs(keyword: String, page: Int, pageSize: Int) async throws -> [Song] {
        guard var components = URLComponents(string: gdStudioBase) else {
            throw MusicAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "types", value: "search"),
            URLQueryItem(name: "source", value: source.rawValue),
            URLQueryItem(name: "name", value: keyword),
            URLQueryItem(name: "count", value: String(pageSize)),
            URLQueryItem(name: "pages", value: String(page)),
        ]

        guard let url = components.url else { throw MusicAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("https://music.gdstudio.xyz", forHTTPHeaderField: "Referer")

        print("[GDStudio] Search: keyword=\(keyword), source=\(source.rawValue), page=\(page)")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else { throw MusicAPIError.serverError }

        print("[GDStudio] Search response: status=\(httpResponse.statusCode), size=\(data.count) bytes")

        let decodedData: Data
        if String(data: data, encoding: .utf8) != nil {
            decodedData = data
        } else if let gbkText = String(data: data, encoding: .init(rawValue: 0x80000632)),
                  let utf8Data = gbkText.data(using: .utf8) {
            decodedData = utf8Data
            print("[GDStudio] Converted GBK to UTF-8")
        } else {
            decodedData = data
        }

        guard let list = try? JSONSerialization.jsonObject(with: decodedData) as? [[String: Any]] else {
            print("[GDStudio] Failed to parse search response")
            throw MusicAPIError.parseError
        }

        print("[GDStudio] Parsed \(list.count) songs, fetching covers...")

        let songs = list.compactMap { parseSongDict($0) }
        let songsWithCovers = await fetchCoversForSongs(songs, from: list)
        print("[GDStudio] Search complete: \(songsWithCovers.count) songs with covers")
        return songsWithCovers
    }

    func getSongURL(songId: String, format: AudioFormat) async throws -> String {
        guard var components = URLComponents(string: gdStudioBase) else {
            throw MusicAPIError.invalidURL
        }

        let br: String
        switch format {
        case .flac, .ape: br = "999"
        case .mp3320: br = "320"
        case .mp3128: br = "128"
        }

        components.queryItems = [
            URLQueryItem(name: "types", value: "url"),
            URLQueryItem(name: "source", value: source.rawValue),
            URLQueryItem(name: "id", value: songId),
            URLQueryItem(name: "br", value: br),
        ]

        guard let url = components.url else { throw MusicAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("https://music.gdstudio.xyz", forHTTPHeaderField: "Referer")

        print("[GDStudio] Get URL: songId=\(songId), format=\(format.rawValue), br=\(br)")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else { throw MusicAPIError.serverError }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let urlStr = json["url"] as? String, urlStr.hasPrefix("http")
        else {
            print("[GDStudio] No URL in response: \(String(data: data, encoding: .utf8) ?? "")")
            throw MusicAPIError.noDownloadURL
        }

        print("[GDStudio] Got URL: \(urlStr.prefix(80))...")
        return urlStr
    }

    func getLyrics(songId: String) async throws -> String {
        guard var components = URLComponents(string: gdStudioBase) else {
            throw MusicAPIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "types", value: "lyric"),
            URLQueryItem(name: "source", value: source.rawValue),
            URLQueryItem(name: "id", value: songId),
        ]

        guard let url = components.url else { throw MusicAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("https://music.gdstudio.xyz", forHTTPHeaderField: "Referer")

        print("[GDStudio] Get lyrics: songId=\(songId), source=\(source.rawValue)")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
        else { throw MusicAPIError.serverError }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw MusicAPIError.parseError
        }

        if let lyric = json["lyric"] as? String, !lyric.isEmpty {
            if let tlyric = json["tlyric"] as? String, !tlyric.isEmpty {
                print("[GDStudio] Lyrics: main + translated")
                return lyric + "\n" + tlyric
            }
            print("[GDStudio] Lyrics: main only")
            return lyric
        }

        print("[GDStudio] No lyrics found")
        throw MusicAPIError.noData
    }

    private func parseSongDict(_ dict: [String: Any]) -> Song? {
        guard let idRaw = dict["id"], let name = dict["name"] as? String else { return nil }

        let id = "\(idRaw)"

        let artist: String
        if let artistArr = dict["artist"] as? [String], !artistArr.isEmpty {
            artist = artistArr.joined(separator: " / ")
        } else if let artistStr = dict["artist"] as? String, !artistStr.isEmpty {
            artist = artistStr
        } else {
            artist = "未知歌手"
        }

        let album = (dict["album"] as? String) ?? "未知专辑"

        return Song(id: id, name: name, artist: artist, album: album, coverUrl: nil, duration: 0, formats: [.mp3320, .mp3128])
    }

    private func fetchCoversForSongs(_ songs: [Song], from list: [[String: Any]]) async -> [Song] {
        await withTaskGroup(of: (Int, String?).self) { group in
            var results: [Int: String?] = [:]
            for (index, item) in list.enumerated() {
                guard let picId = item["pic_id"] as? String, !picId.isEmpty, index < songs.count else {
                    results[index] = nil
                    continue
                }
                group.addTask { [weak self] in
                    guard let self = self,
                          var components = URLComponents(string: self.gdStudioBase)
                    else { return (index, nil) }
                    components.queryItems = [
                        URLQueryItem(name: "types", value: "pic"),
                        URLQueryItem(name: "source", value: self.source.rawValue),
                        URLQueryItem(name: "id", value: picId),
                        URLQueryItem(name: "size", value: "500"),
                    ]
                    guard let url = components.url else { return (index, nil) }

                    var request = URLRequest(url: url)
                    request.setValue("https://music.gdstudio.xyz", forHTTPHeaderField: "Referer")

                    do {
                        let (data, _) = try await self.session.data(for: request)
                        let decodedData: Data
                        if String(data: data, encoding: .utf8) != nil {
                            decodedData = data
                        } else if let gbkText = String(data: data, encoding: .init(rawValue: 0x80000632)),
                                  let utf8Data = gbkText.data(using: .utf8) {
                            decodedData = utf8Data
                        } else {
                            decodedData = data
                        }

                        if let json = try? JSONSerialization.jsonObject(with: decodedData) as? [String: Any],
                           let coverUrl = json["url"] as? String, coverUrl.hasPrefix("http") {
                            return (index, coverUrl)
                        }
                    } catch {}
                    return (index, nil)
                }
            }
            for await (index, coverUrl) in group {
                results[index] = coverUrl
            }
            return songs.enumerated().map { index, song in
                if let coverUrl = results[index] {
                    return Song(id: song.id, name: song.name, artist: song.artist, album: song.album, coverUrl: coverUrl, duration: song.duration, formats: song.formats)
                }
                return song
            }
        }
    }
}
