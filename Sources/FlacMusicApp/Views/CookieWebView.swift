import SwiftUI
import WebKit

#if os(iOS)
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

                        if title.contains("验证") || title.contains("Challenge") {
                            print("Waiting for challenge to complete...")
                            if self.checkCount < 5 {
                                return
                            }
                        }

                        self.onCookiesReady(webView)
                    }
                }
            }

            func webView(
                _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
            ) {
                print("WebView failed: \(error)")
            }
        }
    }

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

                        print(
                            "[SilentWebView] Page title: \(title), needsChallenge: \(needsChallenge)"
                        )

                        if needsChallenge {
                            self.checkCount += 1
                            if self.checkCount >= self.maxRetries {
                                print(
                                    "[SilentWebView] Challenge after \(self.checkCount) retries, needs manual verification"
                                )
                                self.onNeedsManualVerification?()
                            } else {
                                print(
                                    "[SilentWebView] Challenge detected, waiting... (\(self.checkCount)/\(self.maxRetries))"
                                )
                            }
                            return
                        }

                        print("[SilentWebView] Page OK, extracting cookies")
                        self.onCookiesReady(webView)
                    }
                }
            }

            func webView(
                _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
            ) {
                print("[SilentWebView] Navigation failed: \(error)")
                onNeedsManualVerification?()
            }
        }
    }
#endif
