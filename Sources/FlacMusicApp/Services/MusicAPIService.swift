import Combine
import Foundation
import WebKit

// MARK: - Music Source

public enum MusicSource: String, CaseIterable, Sendable, Identifiable {
    public var id: String { rawValue }

    case kuwo = "kuwo"
    case neteaseHi = "wyy"

    case netease = "netease"

    case joox = "joox"
    case bilibili = "bilibili"
    case tencent = "tencent"
    case tidal = "tidal"
    case spotify = "spotify"
    case ytmusic = "ytmusic"
    case qobuz = "qobuz"
    case deezer = "deezer"
    case migu = "migu"
    case kugou = "kugou"
    case ximalaya = "ximalaya"
    case apple = "apple"

    var displayName: String {
        switch self {
        case .kuwo: return "酷我"
        case .neteaseHi: return "网易云"
        case .netease: return "网易云"
        case .joox: return "JOOX"
        case .bilibili: return "哔哩哔哩"
        case .tencent: return "QQ音乐"
        case .tidal: return "TIDAL"
        case .spotify: return "Spotify"
        case .ytmusic: return "YouTube Music"
        case .qobuz: return "Qobuz"
        case .deezer: return "Deezer"
        case .migu: return "咪咕音乐"
        case .kugou: return "酷狗"
        case .ximalaya: return "喜马拉雅"
        case .apple: return "Apple Music"
        }
    }

    var hiCNRawValue: String {
        switch self {
        case .kuwo: return "kuwo"
        case .neteaseHi: return "wyy"
        default: return rawValue
        }
    }
}

public enum MusicProvider: String, CaseIterable, Sendable, Identifiable {
    public var id: String { rawValue }
    case hiCN = "hican"
    case gdStudio = "gdstudio"
    case paojiao = "paojiao"

    var displayName: String {
        switch self {
        case .hiCN: return "Hi音乐"
        case .gdStudio: return "GD Studio"
        case .paojiao: return "泡椒音乐"
        }
    }

    var availableSources: [MusicSource] {
        switch self {
        case .hiCN: return [.kuwo, .neteaseHi]
        case .gdStudio: return MusicSource.allCases.filter { $0 != .neteaseHi }
        case .paojiao: return [.kuwo]
        }
    }

    var stableSources: [MusicSource] {
        switch self {
        case .hiCN: return [.kuwo, .neteaseHi]
        case .gdStudio: return [.netease, .kuwo, .joox, .bilibili]
        case .paojiao: return [.kuwo]
        }
    }
}

protocol MusicProviderProtocol {
    var provider: MusicProvider { get }
    var source: MusicSource { get set }
    var needsCookie: Bool { get }

    func searchSongs(keyword: String, page: Int, pageSize: Int) async throws -> [Song]
    func getSongURL(songId: String, format: AudioFormat) async throws -> String
    func getLyrics(songId: String) async throws -> String
}

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

// MARK: - Facade Service

public final class MusicAPIService: @unchecked Sendable, ObservableObject {
    public static let shared = MusicAPIService()

    @Published public var currentProvider: MusicProvider = .hiCN
    @Published public var currentSource: MusicSource = .kuwo

    @Published public var isCookieValid: Bool = false
    @Published public var cookieNeedsRefresh: Bool = false
    @Published public var isRefreshingCookie: Bool = false

    private var hiCNProvider: HiCNProvider!
    private var gdStudioProvider: GDStudioProvider!
    private var paojiaoProvider: PaojiaoProvider!

    private var activeProvider: MusicProviderProtocol {
        switch currentProvider {
        case .hiCN: return hiCNProvider
        case .gdStudio: return gdStudioProvider
        case .paojiao: return paojiaoProvider
        }
    }

    private let session: URLSession
    private var backgroundTimer: Timer?
    private var heartbeatTimer: Timer?
    private var timeoutTimer: Timer?
    private let autoRefreshInterval: TimeInterval = 600
    private let heartbeatInterval: TimeInterval = 60
    private let refreshTimeout: TimeInterval = 10.0
    private var refreshStartTime: Date? = nil
    private var lastValidationTime: Date = .distantPast

    public var onCookieRefreshed: (() -> Void)?
    public var onCookieInvalid: (() -> Void)?
    public var onSongExpired: (() -> Void)?

    public init(session: URLSession = .shared) {
        self.session = session
        hiCNProvider = HiCNProvider(session: session, source: currentSource)
        gdStudioProvider = GDStudioProvider(session: session, source: currentSource)
        paojiaoProvider = PaojiaoProvider(session: session, source: currentSource)

        hiCNProvider.onCookieInvalid = { [weak self] in
            DispatchQueue.main.async {
                self?.onCookieInvalid?()
            }
        }
        hiCNProvider.onSongExpired = { [weak self] in
            DispatchQueue.main.async {
                self?.onSongExpired?()
            }
        }

        loadStoredCookies()
        startBackgroundCookieRefresh()
        startHeartbeat()
    }

    deinit {
        backgroundTimer?.invalidate()
        heartbeatTimer?.invalidate()
        timeoutTimer?.invalidate()
    }

    // MARK: - Public API

    public func searchSongs(keyword: String, page: Int = 1, pageSize: Int = 30) async throws -> [Song] {
        try await activeProvider.searchSongs(keyword: keyword, page: page, pageSize: pageSize)
    }

    public func getSongURL(songId: String, format: AudioFormat) async throws -> String {
        try await activeProvider.getSongURL(songId: songId, format: format)
    }

    public func getLyrics(songId: String) async throws -> String {
        try await activeProvider.getLyrics(songId: songId)
    }

    public func setProvider(_ provider: MusicProvider) {
        currentProvider = provider
        if let firstSource = provider.availableSources.first {
            currentSource = firstSource
        }
        hiCNProvider.source = currentSource
        gdStudioProvider.source = currentSource
    }

    public func setSource(_ source: MusicSource) {
        currentSource = source
        hiCNProvider.source = source
        gdStudioProvider.source = source
    }

    public var currentProviderPublic: MusicProvider { currentProvider }
    public var currentSourcePublic: MusicSource { currentSource }

    // MARK: - Cookie Management (hi.cn only)

    public func updateCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            guard let self else { return }
            let dict = Dictionary(uniqueKeysWithValues: cookies.map { ($0.name, $0.value) })
            let sessionCookie = dict["sl-session"] ?? ""
            let jwt = dict["sl_jwt_session"] ?? ""

            guard !sessionCookie.isEmpty && !jwt.isEmpty else { return }

            let cookieStr = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            self.signCache.removeAll()
            self.timeCache.removeAll()
            CookieStorage.shared.save(cookieStr)

            DispatchQueue.main.async {
                self.isCookieValid = true
                self.cookieNeedsRefresh = false
                self.isRefreshingCookie = false
                self.onCookieRefreshed?()
            }
        }
    }

    public func clearCookies() {
        CookieStorage.shared.clear()
        DispatchQueue.main.async { [weak self] in
            self?.isCookieValid = false
            self?.isRefreshingCookie = false
        }
    }

    public func validateCookieIfNeeded() {
        guard Date().timeIntervalSince(lastValidationTime) > 30 else { return }
        lastValidationTime = Date()
        validateCookie()
    }

    // MARK: - Heartbeat (hi.cn only)

    private func startBackgroundCookieRefresh() {
        backgroundTimer?.invalidate()
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            self?.triggerBackgroundCookieRefresh()
        }
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkRefreshTimeout()
        }
    }

    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
            self?.validateCookie()
        }
    }

    private func validateCookie() {
        guard let cookie = CookieStorage.shared.getNextValidCookie() else {
            triggerCookieRefresh()
            return
        }

        Task {
            do {
                let url = URL(string: "https://flac.music.hi.cn/ajax.php?act=search")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                request.setValue(cookie, forHTTPHeaderField: "Cookie")
                request.setValue("https://flac.music.hi.cn", forHTTPHeaderField: "Referer")
                request.httpBody = "platform=kuwo&keyword=test&page=1&size=1".data(using: .utf8)

                let (data, response) = try await session.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    let firstByte = data.first
                    let isJSON = firstByte == 123 || firstByte == 91

                    if httpResponse.statusCode == 468 || !isJSON {
                        CookieStorage.shared.markCookieInvalid(cookie)
                        await MainActor.run { self.onCookieInvalid?() }
                    }
                }
            } catch {
                await MainActor.run { self.onCookieInvalid?() }
            }
        }
    }

    private func triggerCookieRefresh() {
        guard !isRefreshingCookie else { return }
        refreshStartTime = Date()
        DispatchQueue.main.async { [weak self] in
            self?.cookieNeedsRefresh = true
        }
    }

    private func triggerBackgroundCookieRefresh() {
        guard !isRefreshingCookie else { return }
        refreshStartTime = Date()
        DispatchQueue.main.async { [weak self] in
            self?.cookieNeedsRefresh = true
        }
    }

    private func checkRefreshTimeout() {
        guard let startTime = refreshStartTime, isRefreshingCookie else { return }
        if Date().timeIntervalSince(startTime) > refreshTimeout {
            refreshStartTime = nil
            isRefreshingCookie = false
            if !CookieStorage.shared.hasValidCookie {
                cookieNeedsRefresh = true
            }
        }
    }

    private func loadStoredCookies() {
        if let stored = CookieStorage.shared.getNextValidCookie(), !stored.isEmpty {
            isCookieValid = true
            cookieNeedsRefresh = false
        } else {
            isCookieValid = false
            cookieNeedsRefresh = true
        }
    }

    private var signCache: [String: String] = [:]
    private var timeCache: [String: Int] = [:]
}
