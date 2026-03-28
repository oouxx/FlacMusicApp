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
        webView.isHidden = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCookiesReady: onCookiesReady)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let onCookiesReady: (WKWebView) -> Void
        
        init(onCookiesReady: @escaping (WKWebView) -> Void) {
            self.onCookiesReady = onCookiesReady
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.onCookiesReady(webView)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed: \(error)")
        }
    }
}
#endif
