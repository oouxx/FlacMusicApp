import Combine
import SwiftUI
import WebKit

public struct ContentView: View {

    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var apiService = MusicAPIService.shared

    @State private var appState: AppState = .launching
    @State private var launchOpacity: Double = 0
    @State private var selectedTab: Tab = .search
    @State private var silentRefreshTrigger: Bool = false
    @State private var showVerificationSheet: Bool = false

    public init() {}

    // MARK: - Body

    public var body: some View {
        ZStack {
            mainContent
                .opacity(appState == .ready ? 1 : 0)

            if appState == .launching || appState == .loadingCookie {
                launchScreen
                    .opacity(launchOpacity)
                    .zIndex(10)
            }

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
        await MainActor.run { appState = .loadingCookie }
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
                    .environmentObject(apiService)
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

                SettingsView()
                    .tabItem { Label("设置", systemImage: "gearshape") }
                    .tag(Tab.settings)
            }
            PlayerView()
        }
    }

    // MARK: - Launch Screen

    private var launchScreen: some View {
        ZStack {
            #if os(iOS)
                Color(.systemBackground)
            #else
                Color(NSColor.windowBackgroundColor).opacity(0.05)
            #endif

            if appState == .loadingCookie {
                #if os(iOS)
                    VStack(spacing: 0) {
                        VStack(spacing: 10) {
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
                                    .frame(width: 72, height: 72)
                                    .shadow(color: .purple.opacity(0.4), radius: 16, y: 6)

                                Image(systemName: "music.note")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundStyle(.white)
                            }

                            Text("FlacMusic")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))

                            Text("完成验证后自动进入")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                        CookieWebView { webView in
                            MusicAPIService.shared.updateCookies(from: webView)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                enterMainInterface()
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                #endif
            } else {
                VStack(spacing: 24) {
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

                    ProgressView()
                        .scaleEffect(0.85)
                        .opacity(0.5)
                }
            }
        }
    }

    // MARK: - Silent Refresh

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
        case launching
        case loadingCookie
        case needsManualVerification
        case ready
    }

    enum Tab {
        case search, downloads, settings
    }
}
