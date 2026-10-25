//
//  WebView.swift
//  MYBrowser
//

import SwiftUI
import WebKit

enum NavigationCommand: Equatable {
    case back(UUID)
    case forward(UUID)
    case reload(UUID)
}

/// SwiftUIの画面に、AppKitのWKWebViewを埋め込むための橋渡し役です。
struct WebView: NSViewRepresentable {
    let url: URL
    let command: NavigationCommand?
    let onNavigationStateChange: (Bool, Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onNavigationStateChange: onNavigationStateChange)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        context.coordinator.startObserving(webView)
        load(url, in: webView, coordinator: context.coordinator)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let coordinator = context.coordinator
        coordinator.onNavigationStateChange = onNavigationStateChange

        if coordinator.loadedURL != url {
            load(url, in: webView, coordinator: coordinator)
        }

        guard coordinator.executedCommand != command else { return }
        coordinator.executedCommand = command

        switch command {
        case .back:
            webView.goBack()
        case .forward:
            webView.goForward()
        case .reload:
            webView.reload()
        case nil:
            break
        }
    }

    private func load(_ url: URL, in webView: WKWebView, coordinator: Coordinator) {
        coordinator.loadedURL = url
        webView.load(URLRequest(url: url))
    }

    final class Coordinator {
        var loadedURL: URL?
        var executedCommand: NavigationCommand?
        var onNavigationStateChange: (Bool, Bool) -> Void
        private var observations: [NSKeyValueObservation] = []

        init(onNavigationStateChange: @escaping (Bool, Bool) -> Void) {
            self.onNavigationStateChange = onNavigationStateChange
        }

        func startObserving(_ webView: WKWebView) {
            observations = [
                webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self, weak webView] _, _ in
                    self?.publishNavigationState(for: webView)
                },
                webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self, weak webView] _, _ in
                    self?.publishNavigationState(for: webView)
                }
            ]
        }

        private func publishNavigationState(for webView: WKWebView?) {
            guard let webView else { return }
            DispatchQueue.main.async { [weak self, weak webView] in
                guard let self, let webView else { return }
                self.onNavigationStateChange(webView.canGoBack, webView.canGoForward)
            }
        }
    }
}
