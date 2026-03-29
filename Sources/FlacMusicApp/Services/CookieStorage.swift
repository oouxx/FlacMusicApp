import Foundation

public final class CookieStorage: @unchecked Sendable {
    public static let shared = CookieStorage()
    
    private let userDefaults = UserDefaults.standard
    private let cookieKey = "flacmusic_cookie"
    private let timestampKey = "flacmusic_cookie_timestamp"
    
    private init() {}
    
    public var cookie: String? {
        get { userDefaults.string(forKey: cookieKey) }
        set { 
            userDefaults.set(newValue, forKey: cookieKey)
            userDefaults.set(Date(), forKey: timestampKey)
        }
    }
    
    public var timestamp: Date? {
        userDefaults.object(forKey: timestampKey) as? Date
    }
    
    public func save(_ cookie: String) {
        self.cookie = cookie
    }
    
    public func clear() {
        userDefaults.removeObject(forKey: cookieKey)
        userDefaults.removeObject(forKey: timestampKey)
    }
    
    public func getNextValidCookie() -> String? {
        cookie
    }
    
    public func markCookieInvalid(_ cookie: String) {
        if self.cookie == cookie {
            clear()
        }
    }
    
    public var hasValidCookie: Bool {
        cookie != nil && !cookie!.isEmpty
    }
}
