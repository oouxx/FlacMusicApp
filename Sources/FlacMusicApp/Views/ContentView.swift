import SwiftUI
import WebKit

public struct ContentView: View {
    
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var downloadManager = DownloadManager.shared
    @State private var selectedTab: Tab = .search
    @State private var cookiesLoaded = false
    
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
                cookieFetcherView
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 560)
        #endif
    }
    
    @ViewBuilder
    private var cookieFetcherView: some View {
        #if os(iOS)
        CookieWebView { webView in
            MusicAPIService.shared.updateCookies(from: webView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                cookiesLoaded = true
            }
        }
        .frame(width: 1, height: 1)
        .opacity(0)
        #else
        Color.clear
            .onAppear {
                cookiesLoaded = true
            }
        #endif
    }
    
    enum Tab {
        case search, downloads
    }
}
