import SwiftUI
import WebKit

#if os(iOS)

// MARK: - 首次启动用（全屏，带启动动画）
struct CookieWebView: UIViewRepresentable {
    let onCookiesReady: (WKWebView) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: "https://flac.music.hi.cn") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCookiesReady: onCookiesReady)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onCookiesReady: (WKWebView) -> Void
        var checkCount = 0

        init(onCookiesReady: @escaping (WKWebView) -> Void) {
            self.onCookiesReady = onCookiesReady
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            checkCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self else { return }
                webView.evaluateJavaScript("document.title") { result, _ in
                    let title = result as? String ?? ""
                    if (title.contains("验证") || title.contains("Challenge"))
                        && self.checkCount < 5 {
                        return
                    }
                    self.onCookiesReady(webView)
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[CookieWebView] failed: \(error)")
        }
    }
}

// MARK: - 后台静默刷新用（隐藏）
struct SilentCookieWebView: UIViewRepresentable {
    let onCookiesReady: (WKWebView) -> Void
    let onNeedsManualVerification: (() -> Void)?

    init(
        onCookiesReady: @escaping (WKWebView) -> Void,
        onNeedsManualVerification: (() -> Void)? = nil
    ) {
        self.onCookiesReady = onCookiesReady
        self.onNeedsManualVerification = onNeedsManualVerification
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isHidden = true
        if let url = URL(string: "https://flac.music.hi.cn") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onCookiesReady: onCookiesReady,
            onNeedsManualVerification: onNeedsManualVerification
        )
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onCookiesReady: (WKWebView) -> Void
        let onNeedsManualVerification: (() -> Void)?
        var checkCount = 0
        let maxRetries = 3

        init(
            onCookiesReady: @escaping (WKWebView) -> Void,
            onNeedsManualVerification: (() -> Void)?
        ) {
            self.onCookiesReady = onCookiesReady
            self.onNeedsManualVerification = onNeedsManualVerification
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                webView.evaluateJavaScript("document.title") { result, _ in
                    let title = result as? String ?? ""
                    let needsChallenge = title.contains("验证") || title.contains("Challenge")
                    if needsChallenge {
                        self.checkCount += 1
                        if self.checkCount >= self.maxRetries {
                            print("[SilentWebView] Challenge after \(self.checkCount) retries")
                            self.onNeedsManualVerification?()
                        }
                        return
                    }
                    self.onCookiesReady(webView)
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[SilentWebView] failed: \(error)")
            onNeedsManualVerification?()
        }
    }
}

// MARK: - Cookie 过期时底部弹出的验证 Sheet
struct CookieVerificationSheet: View {
    let onDismiss: () -> Void
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                CookieWebView { webView in
                    MusicAPIService.shared.updateCookies(from: webView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onDismiss()
                    }
                }
                .ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("正在加载验证页面...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
                }
            }
            .navigationTitle("身份验证")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("稍后再说") { onDismiss() }
                }
            }
            .onAppear {
                // 1.5 秒后隐藏 loading，让 WebView 显示
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { isLoading = false }
                }
            }
        }
    }
}

#endif
