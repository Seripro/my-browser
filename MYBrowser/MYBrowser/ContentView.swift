//
//  ContentView.swift
//  MYBrowser
//
//  Created by keigo on 2026/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var address = ""

    var body: some View {
        VStack(spacing: 0) {
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

                Label("準備中", systemImage: "circle")
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider()

            WebView()
        }
        .frame(minWidth: 700, minHeight: 450)
    }
}

#Preview {
    ContentView()
}
