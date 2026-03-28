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
        VStack {
            if !cookiesLoaded {
                CookieWebView { webView in
                    MusicAPIService.shared.updateCookies(from: webView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        cookiesLoaded = true
                    }
                }
                .frame(width: 300, height: 400)
            }
        }
        #elseif os(macOS)
        VStack(spacing: 16) {
            if !cookiesLoaded {
                Text("正在加载音乐服务...")
                    .font(.headline)
                
                MacCookieWebView { webView in
                    MusicAPIService.shared.updateCookies(from: webView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        cookiesLoaded = true
                    }
                }
                .frame(width: 600, height: 400)
                .cornerRadius(8)
                
                Text("如果出现验证页面，请手动完成验证")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("跳过") {
                    cookiesLoaded = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
    }
    
    enum Tab {
        case search, downloads
    }
}
