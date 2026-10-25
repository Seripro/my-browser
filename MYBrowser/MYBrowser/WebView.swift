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
    let onLoadingChange: (Bool) -> Void
    let onURLChange: (URL) -> Void
    let onLoadError: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onNavigationStateChange: onNavigationStateChange,
            onLoadingChange: onLoadingChange,
            onURLChange: onURLChange,
            onLoadError: onLoadError
        )
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.startObserving(webView)
        load(url, in: webView, coordinator: context.coordinator)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let coordinator = context.coordinator
        coordinator.onNavigationStateChange = onNavigationStateChange
        coordinator.onLoadingChange = onLoadingChange
        coordinator.onURLChange = onURLChange
        coordinator.onLoadError = onLoadError

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

    final class Coordinator: NSObject, WKNavigationDelegate {
        var loadedURL: URL?
        var executedCommand: NavigationCommand?
        var onNavigationStateChange: (Bool, Bool) -> Void
        var onLoadingChange: (Bool) -> Void
        var onURLChange: (URL) -> Void
        var onLoadError: (String) -> Void
        private var observations: [NSKeyValueObservation] = []

        init(
            onNavigationStateChange: @escaping (Bool, Bool) -> Void,
            onLoadingChange: @escaping (Bool) -> Void,
            onURLChange: @escaping (URL) -> Void,
            onLoadError: @escaping (String) -> Void
        ) {
            self.onNavigationStateChange = onNavigationStateChange
            self.onLoadingChange = onLoadingChange
            self.onURLChange = onURLChange
            self.onLoadError = onLoadError
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

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            publishLoadingState(true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            publishLoadingState(false)
            if let url = webView.url {
                publishURL(url)
            }
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            publishLoadError(error)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            publishLoadError(error)
        }

        private func publishLoadingState(_ isLoading: Bool) {
            DispatchQueue.main.async { [weak self] in
                self?.onLoadingChange(isLoading)
            }
        }

        private func publishURL(_ url: URL) {
            DispatchQueue.main.async { [weak self] in
                self?.onURLChange(url)
            }
        }

        private func publishLoadError(_ error: Error) {
            DispatchQueue.main.async { [weak self] in
                self?.onLoadingChange(false)
                self?.onLoadError(error.localizedDescription)
            }
        }
    }
}
