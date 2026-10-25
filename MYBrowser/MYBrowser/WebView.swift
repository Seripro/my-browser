//
//  WebView.swift
//  MYBrowser
//

import SwiftUI
import WebKit

/// SwiftUIの画面に、AppKitのWKWebViewを埋め込むための橋渡し役です。
struct WebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()

        if let url = URL(string: "https://example.com") {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // 今回はSwiftUI側から更新する状態がないため、何もしません。
    }
}
