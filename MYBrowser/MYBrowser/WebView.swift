//
//  WebView.swift
//  MYBrowser
//

import SwiftUI
import WebKit

/// SwiftUIの画面に、AppKitのWKWebViewを埋め込むための橋渡し役です。
struct WebView: NSViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        load(url, in: webView, coordinator: context.coordinator)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedURL != url else { return }
        load(url, in: webView, coordinator: context.coordinator)
    }

    private func load(_ url: URL, in webView: WKWebView, coordinator: Coordinator) {
        coordinator.loadedURL = url
        webView.load(URLRequest(url: url))
    }

    final class Coordinator {
        var loadedURL: URL?
    }
}
