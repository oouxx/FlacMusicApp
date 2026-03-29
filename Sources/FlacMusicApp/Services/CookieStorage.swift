import Foundation

public struct PooledCookie: Codable, Sendable {
    public let cookie: String
    public let timestamp: Date
    
    public init(cookie: String, timestamp: Date = Date()) {
        self.cookie = cookie
        self.timestamp = timestamp
    }
    
    public var isExpired: Bool {
        let expirationInterval: TimeInterval = 600
        return Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

public final class CookieStorage: @unchecked Sendable {
    public static let shared = CookieStorage()
    
    private let userDefaults = UserDefaults.standard
    private let poolKey = "flacmusic_cookie_pool"
    private let refreshCountKey = "flacmusic_refresh_count"
    private let poolCapacity = 5
    private let expirationInterval: TimeInterval = 600
    
    private var cookiePool: [PooledCookie] = []
    private let queue = DispatchQueue(label: "com.flacmusic.cookiemanager", attributes: .concurrent)
    
    private init() {
        loadPool()
    }
    
    // MARK: - Pool Management
    
    private func loadPool() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if let data = self.userDefaults.data(forKey: self.poolKey),
               let pool = try? JSONDecoder().decode([PooledCookie].self, from: data) {
                self.cookiePool = pool
            }
        }
    }
    
    public func addToPool(_ cookie: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.cookiePool.removeAll { $0.isExpired }
            guard !self.cookiePool.contains(where: { $0.cookie == cookie }) else { return }
            self.cookiePool.append(PooledCookie(cookie: cookie))
            if self.cookiePool.count > self.poolCapacity {
                self.cookiePool.removeFirst()
            }
            if let data = try? JSONEncoder().encode(self.cookiePool) {
                self.userDefaults.set(data, forKey: self.poolKey)
            }
        }
    }
    
    public func getNextValidCookie() -> String? {
        var result: String?
        queue.sync {
            result = cookiePool.first(where: { !$0.isExpired })?.cookie
        }
        return result
    }
    
    public func getAllPoolCookies() -> [String] {
        var result: [String] = []
        queue.sync { result = cookiePool.map { $0.cookie } }
        return result
    }
    
    public func markCookieInvalid(_ cookie: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.cookiePool.removeAll { $0.cookie == cookie }
            if let data = try? JSONEncoder().encode(self.cookiePool) {
                self.userDefaults.set(data, forKey: self.poolKey)
            }
        }
    }
    
    public var poolSize: Int {
        var size = 0
        queue.sync { size = cookiePool.count }
        return size
    }
    
    public var hasValidCookie: Bool {
        var hasValid = false
        queue.sync { hasValid = cookiePool.contains { !$0.isExpired } }
        return hasValid
    }
    
    // MARK: - Legacy Support
    
    public var cookieString: String? {
        get { getNextValidCookie() }
        set {
            if let cookie = newValue {
                addToPool(cookie)
            }
        }
    }
    
    public var timestamp: Date? {
        get {
            var ts: Date?
            queue.sync {
                ts = cookiePool.first?.timestamp
            }
            return ts
        }
    }
    
    public var refreshCount: Int {
        get { userDefaults.integer(forKey: refreshCountKey) }
        set { userDefaults.set(newValue, forKey: refreshCountKey) }
    }
    
    public func save(cookie: String) {
        addToPool(cookie)
        refreshCount = 0
    }
    
    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            self?.cookiePool.removeAll()
            if let data = try? JSONEncoder().encode(self?.cookiePool ?? []) {
                self?.userDefaults.set(data, forKey: self?.poolKey ?? "")
            }
        }
        userDefaults.set(0, forKey: refreshCountKey)
    }
    
    public var isExpired: Bool {
        guard let _ = getNextValidCookie() else { return true }
        return false
    }
    
    public var shouldRefresh: Bool {
        return !hasValidCookie
    }
    
    public func incrementRefreshCount() {
        refreshCount += 1
    }
    
    public var shouldAutoRefresh: Bool {
        return refreshCount < 3
    }
}
