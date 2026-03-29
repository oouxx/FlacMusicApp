import SwiftUI
import WebKit
import Combine

public struct ContentView: View {
    
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var apiService = MusicAPIService.shared
    @State private var selectedTab: Tab = .search
    @State private var cookiesLoaded = false
    @State private var showCookieReloader = false
    @State private var silentRefreshTrigger = false
    
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
                        .badge(downloadManager.tasks.filter {
                            if case .downloading = $0.state { return true }
                            return false
                        }.count)
                }
                
                PlayerView()
            }
            
            if !cookiesLoaded {
                cookieFetcherView(isInitialLoad: true)
            }
            
            if silentRefreshTrigger {
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
    
    @ViewBuilder
    private func cookieFetcherView(isInitialLoad: Bool) -> some View {
        SilentCookieWebView { webView in
            MusicAPIService.shared.updateCookies(from: webView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                if isInitialLoad {
                    cookiesLoaded = true
                } else {
                    silentRefreshTrigger = false
                    MusicAPIService.shared.isRefreshingCookie = false
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }
    
    enum Tab {
        case search, downloads
    }
}
