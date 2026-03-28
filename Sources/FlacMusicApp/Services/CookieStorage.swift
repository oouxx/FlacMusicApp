import Foundation

public final class CookieStorage {
    public static let shared = CookieStorage()
    
    private let userDefaults = UserDefaults.standard
    private let cookieKey = "flacmusic_cookie"
    private let timestampKey = "flacmusic_cookie_timestamp"
    private let refreshCountKey = "flacmusic_refresh_count"
    
    private let expirationInterval: TimeInterval = 3600
    
    private init() {}
    
    public var cookieString: String? {
        get { userDefaults.string(forKey: cookieKey) }
        set { userDefaults.set(newValue, forKey: cookieKey) }
    }
    
    public var timestamp: Date? {
        get {
            guard let interval = userDefaults.object(forKey: timestampKey) as? TimeInterval else { return nil }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            userDefaults.set(newValue?.timeIntervalSince1970, forKey: timestampKey)
        }
    }
    
    public var refreshCount: Int {
        get { userDefaults.integer(forKey: refreshCountKey) }
        set { userDefaults.set(newValue, forKey: refreshCountKey) }
    }
    
    public func save(cookie: String) {
        cookieString = cookie
        timestamp = Date()
        refreshCount = 0
    }
    
    public func clear() {
        cookieString = nil
        timestamp = nil
        refreshCount = 0
    }
    
    public var isExpired: Bool {
        guard let ts = timestamp else { return true }
        return Date().timeIntervalSince(ts) > expirationInterval
    }
    
    public var shouldRefresh: Bool {
        guard timestamp != nil else { return true }
        return isExpired
    }
    
    public func incrementRefreshCount() {
        refreshCount += 1
    }
    
    public var shouldAutoRefresh: Bool {
        return refreshCount < 3
    }
}
