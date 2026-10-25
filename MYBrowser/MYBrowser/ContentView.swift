//
//  ContentView.swift
//  MYBrowser
//
//  Created by keigo on 2026/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var address = "https://example.com"
    @State private var requestedURL = URL(string: "https://example.com")!
    @State private var addressError: String?

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(true)
                    .help("戻る")

                    Button(action: {}) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(true)
                    .help("進む")

                    Button(action: {}) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("再読み込み")

                    TextField("https://example.com", text: $address)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(openAddress)

                    Label("準備中", systemImage: "circle")
                        .foregroundStyle(.secondary)
                }

                if let addressError {
                    Text(addressError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()

            Divider()

            WebView(url: requestedURL)
        }
        .frame(minWidth: 700, minHeight: 450)
    }

    private func openAddress() {
        guard let url = normalizedURL(from: address) else {
            addressError = "http:// または https:// で始まる有効なURLを入力してください。"
            return
        }

        addressError = nil
        address = url.absoluteString
        requestedURL = url
    }

    private func normalizedURL(from input: String) -> URL? {
        var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        if URLComponents(string: text)?.scheme == nil {
            text = "https://\(text)"
        }

        guard let components = URLComponents(string: text),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              components.host != nil,
              let url = components.url else {
            return nil
        }

        return url
    }
}

#Preview {
    ContentView()
}
