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
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed: \(error)")
        }
    }
}
#endif
