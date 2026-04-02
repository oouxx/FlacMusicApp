import SwiftUI
import WebKit

#if os(iOS)

// MARK: - 共用 Cookie 校验逻辑
private func hasRequiredCookies(_ cookies: [HTTPCookie]) -> Bool {
    let dict = Dictionary(uniqueKeysWithValues: cookies.map { ($0.name, $0.value) })
    let session = dict["sl-session"] ?? ""
    let jwt = dict["sl_jwt_session"] ?? ""
    print("[CookieCheck] sl-session=\(session.isEmpty ? "❌" : "✅") sl_jwt_session=\(jwt.isEmpty ? "❌" : "✅")")
    // sl_jwt_sign 有时为空值，不强制要求
    // sl-challenge-server 存在说明还在验证中，必须等 sl_jwt_session 出现才算完成
    return !session.isEmpty && !jwt.isEmpty
}

// MARK: - 首次启动 / 验证 Sheet 用（全屏可见，无限等待用户完成验证）
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
        private var isCompleted = false
        private let pollInterval: TimeInterval = 0.5

        init(onCookiesReady: @escaping (WKWebView) -> Void) {
            self.onCookiesReady = onCookiesReady
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 每次页面加载完重新开始轮询
            isCompleted = false
            poll(webView: webView)
        }

        private func poll(webView: WKWebView) {
            guard !isCompleted else { return }

            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies {
                [weak self] cookies in
                guard let self, !self.isCompleted else { return }

                if hasRequiredCookies(cookies) {
                    print("[CookieWebView] ✅ Cookies ready, proceeding")
                    self.isCompleted = true
                    DispatchQueue.main.async {
                        self.onCookiesReady(webView)
                    }
                    return
                }

                // 未就绪，0.5 秒后继续轮询，无超时限制
                DispatchQueue.main.asyncAfter(deadline: .now() + self.pollInterval) {
                    [weak self] in
                    self?.poll(webView: webView)
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[CookieWebView] Navigation failed: \(error.localizedDescription)")
            // 失败后 2 秒重新加载，继续等待
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self, !self.isCompleted else { return }
                if let url = URL(string: "https://flac.music.hi.cn") {
                    webView.load(URLRequest(url: url))
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("[CookieWebView] Provisional failed: \(error.localizedDescription)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self, !self.isCompleted else { return }
                if let url = URL(string: "https://flac.music.hi.cn") {
                    webView.load(URLRequest(url: url))
                }
            }
        }
    }
}

// MARK: - 后台静默刷新用（隐藏，有超时上限）
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

        private var isCompleted = false
        private var pollCount = 0
        private let maxPolls = 20           // 最多 10 秒（20 × 0.5s）
        private let pollInterval: TimeInterval = 0.5

        init(
            onCookiesReady: @escaping (WKWebView) -> Void,
            onNeedsManualVerification: (() -> Void)?
        ) {
            self.onCookiesReady = onCookiesReady
            self.onNeedsManualVerification = onNeedsManualVerification
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            pollCount = 0
            isCompleted = false
            poll(webView: webView)
        }

        private func poll(webView: WKWebView) {
            guard !isCompleted else { return }

            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies {
                [weak self] cookies in
                guard let self, !self.isCompleted else { return }

                if hasRequiredCookies(cookies) {
                    print("[SilentWebView] ✅ Cookies ready")
                    self.isCompleted = true
                    DispatchQueue.main.async {
                        self.onCookiesReady(webView)
                    }
                    return
                }

                self.pollCount += 1
                print("[SilentWebView] Poll \(self.pollCount)/\(self.maxPolls)")

                if self.pollCount >= self.maxPolls {
                    // 10 秒内拿不到说明遇到了需要人工交互的验证
                    print("[SilentWebView] Timeout → needs manual verification")
                    self.isCompleted = true
                    DispatchQueue.main.async {
                        self.onNeedsManualVerification?()
                    }
                    return
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + self.pollInterval) {
                    [weak self] in
                    self?.poll(webView: webView)
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            guard !isCompleted else { return }
            isCompleted = true
            print("[SilentWebView] Navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async { self.onNeedsManualVerification?() }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            guard !isCompleted else { return }
            isCompleted = true
            print("[SilentWebView] Provisional failed: \(error.localizedDescription)")
            DispatchQueue.main.async { self.onNeedsManualVerification?() }
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { isLoading = false }
                }
            }
        }
    }
}

#endif
