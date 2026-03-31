import Combine
import SwiftUI
import WebKit

public struct ContentView: View {

    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var apiService = MusicAPIService.shared

    @State private var selectedTab: Tab = .search

    // 启动状态
    @State private var appState: AppState = .launching
    @State private var launchOpacity: Double = 1.0

    // Cookie 相关
    @State private var silentRefreshTrigger = false
    @State private var showVerificationSheet = false

    public init() {}

    // MARK: - Body

    public var body: some View {
        ZStack {
            // 主界面（始终在后面渲染，避免切换卡顿）
            mainContent
                .opacity(appState == .ready ? 1 : 0)

            // 启动屏：有缓存 Cookie 时短暂显示，无 Cookie 时显示加载
            if appState == .launching || appState == .loadingCookie {
                launchScreen
                    .opacity(launchOpacity)
                    .zIndex(10)
            }

            // 后台静默刷新（0 大小，不可见）
            if silentRefreshTrigger && !showVerificationSheet {
                silentCookieFetcherView
            }
        }
        .sheet(isPresented: $showVerificationSheet) {
            #if os(iOS)
            CookieVerificationSheet {
                showVerificationSheet = false
                MusicAPIService.shared.isRefreshingCookie = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            #endif
        }
        .onChange(of: apiService.cookieNeedsRefresh) { _, newValue in
            if newValue && appState == .ready {
                silentRefreshTrigger = true
            }
        }
        .onChange(of: apiService.isCookieValid) { _, newValue in
            if newValue {
                silentRefreshTrigger = false
                showVerificationSheet = false
                if appState != .ready {
                    enterMainInterface()
                }
                if !searchVM.query.isEmpty {
                    Task { await searchVM.search(query: searchVM.query, reset: true) }
                }
            }
        }
        .task {
            await handleLaunch()
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 560)
        #endif
    }

    // MARK: - Launch Logic

    private func handleLaunch() async {
        // 有本地 Cookie → 乐观进入主界面，后台验证
        if CookieStorage.shared.hasValidCookie {
            // 短暂显示启动屏再淡出，避免闪烁
            try? await Task.sleep(for: .milliseconds(300))
            enterMainInterface()

            // 后台心跳验证，失败了再弹 sheet
            MusicAPIService.shared.validateCookieIfNeeded()
        } else {
            // 无 Cookie → 切换到加载状态，展示 WebView
            await MainActor.run {
                appState = .loadingCookie
            }
        }
    }

    private func enterMainInterface() {
        withAnimation(.easeOut(duration: 0.35)) {
            launchOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            appState = .ready
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                SearchView()
                    .environmentObject(searchVM)
                    .environmentObject(downloadManager)
                    .tabItem { Label("搜索", systemImage: "magnifyingglass") }
                    .tag(Tab.search)

                DownloadsView()
                    .environmentObject(downloadManager)
                    .tabItem { Label("下载", systemImage: "arrow.down.circle") }
                    .tag(Tab.downloads)
                    .badge(
                        downloadManager.tasks.filter {
                            if case .downloading = $0.state { return true }
                            return false
                        }.count
                    )
            }
            PlayerView()
        }
        // Cookie 过期时底部弹 sheet，不打断用户
        .onChange(of: apiService.cookieNeedsRefresh) { _, newValue in
            if newValue && appState == .ready && !silentRefreshTrigger {
                // 先走静默刷新，实在不行再弹 sheet
            }
        }
    }

    // MARK: - Launch Screen

    private var launchScreen: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                // App Icon 区域
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.24, green: 0.07, blue: 0.47),
                                    Color(red: 0.49, green: 0.19, blue: 1.0),
                                    Color(red: 0.77, green: 0.30, blue: 1.0),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .purple.opacity(0.4), radius: 20, y: 8)

                    Image(systemName: "music.note")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 6) {
                    Text("FlacMusic")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                    Text("无损音乐")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // 状态提示
                if appState == .loadingCookie {
                    VStack(spacing: 12) {
                        // 内嵌一个不可见的 WebView 在后台加载
                        #if os(iOS)
                        hiddenCookieLoader
                        #endif

                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.85)
                            Text("正在获取访问权限...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    // 有 Cookie，短暂过渡
                    ProgressView()
                        .scaleEffect(0.85)
                        .opacity(0.5)
                }
            }
        }
    }

    // MARK: - Hidden Cookie Loader（嵌在启动屏里，0 大小）

    #if os(iOS)
    private var hiddenCookieLoader: some View {
        SilentCookieWebView(
            onCookiesReady: { webView in
                MusicAPIService.shared.updateCookies(from: webView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    enterMainInterface()
                }
            },
            onNeedsManualVerification: {
                // 静默加载遇到验证，切换到可见 WebView
                appState = .needsManualVerification
                enterMainInterface()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showVerificationSheet = true
                }
            }
        )
        .frame(width: 0, height: 0)
        .hidden()
    }
    #endif

    // MARK: - Silent Refresh（后台，主界面已显示时用）

    private var silentCookieFetcherView: some View {
        #if os(iOS)
        SilentCookieWebView(
            onCookiesReady: { webView in
                MusicAPIService.shared.updateCookies(from: webView)
                DispatchQueue.main.async {
                    silentRefreshTrigger = false
                    MusicAPIService.shared.isRefreshingCookie = false
                }
            },
            onNeedsManualVerification: {
                silentRefreshTrigger = false
                showVerificationSheet = true
            }
        )
        .frame(width: 0, height: 0)
        #else
        EmptyView()
        #endif
    }

    // MARK: - Types

    enum AppState {
        case launching              // 启动中，检查本地 Cookie
        case loadingCookie          // 无 Cookie，WebView 后台加载中
        case needsManualVerification // 需要用户手动验证
        case ready                  // 主界面就绪
    }

    enum Tab {
        case search, downloads
    }
}
