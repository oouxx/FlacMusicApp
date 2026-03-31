import Combine
import SwiftUI
import WebKit

public struct ContentView: View {

    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var apiService = MusicAPIService.shared
    @State private var selectedTab: Tab = .search
    @State private var cookiesLoaded = false
    @State private var showCookieReloader = false
    @State private var silentRefreshTrigger = false
    @State private var showManualVerification = false

    public init() {}

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    SearchView()
                        .environmentObject(searchVM)
                        .environmentObject(downloadManager)
                        .tabItem {
                            Label("搜索", systemImage: "magnifyingglass")
                        }
                        .tag(Tab.search)

                    DownloadsView()
                        .environmentObject(downloadManager)
                        .tabItem {
                            Label("下载", systemImage: "arrow.down.circle")
                        }
                        .tag(Tab.downloads)
                        .badge(
                            downloadManager.tasks.filter {
                                if case .downloading = $0.state { return true }
                                return false
                            }.count)
                }

                PlayerView()
            }

            // 首次加载：显示可见 WebView 让用户完成验证
            if !cookiesLoaded {
                cookieFetcherView(isInitialLoad: true)
            }

            // 后台静默刷新
            if silentRefreshTrigger && !showManualVerification {
                silentCookieFetcherView
            }

            // 静默刷新遇到验证页，升级为可见 WebView
            if showManualVerification {
                cookieFetcherView(isInitialLoad: false)
            }
        }
        .onChange(of: apiService.cookieNeedsRefresh) { _, newValue in
            if newValue && cookiesLoaded {
                silentRefreshTrigger = true
            }
        }
        .onChange(of: apiService.isCookieValid) { _, newValue in
            if newValue {
                silentRefreshTrigger = false
                showManualVerification = false
                if !searchVM.query.isEmpty {
                    Task {
                        await searchVM.search(query: searchVM.query, reset: true)
                    }
                }
            }
        }
        #if os(macOS)
            .frame(minWidth: 800, minHeight: 560)
        #endif
    }

    // 可见 WebView（首次 or 静默失败后升级）
    @ViewBuilder
    private func cookieFetcherView(isInitialLoad: Bool) -> some View {
        CookieWebView { webView in
            MusicAPIService.shared.updateCookies(from: webView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                if isInitialLoad {
                    cookiesLoaded = true
                } else {
                    showManualVerification = false
                    silentRefreshTrigger = false
                    MusicAPIService.shared.isRefreshingCookie = false
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }

    // 静默 WebView（后台不可见）
    private var silentCookieFetcherView: some View {
        SilentCookieWebView(
            onCookiesReady: { webView in
                MusicAPIService.shared.updateCookies(from: webView)
                DispatchQueue.main.async {
                    silentRefreshTrigger = false
                    MusicAPIService.shared.isRefreshingCookie = false
                }
            },
            onNeedsManualVerification: {
                // 静默刷新遇到验证页，升级为可见 WebView
                print("[ContentView] Silent refresh hit challenge, showing manual verification")
                silentRefreshTrigger = false
                showManualVerification = true
            }
        )
        .frame(width: 0, height: 0)
    }

    enum Tab {
        case search, downloads
    }
}
