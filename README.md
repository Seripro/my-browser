# MYBrowser

SwiftUIとWebKitで作った、macOS向けの学習用ミニブラウザです。

ブラウザの画面やナビゲーション操作はSwiftUIで実装し、Webページの取得・HTML/CSS/JavaScriptの処理・描画はmacOS標準の`WKWebView`へ任せています。

## できること

- URLを入力してWebページを開く
- `example.com`のように入力した場合、`https://`を自動で補う
- ページ内リンクを開く
- 戻る、進む、再読み込み
- 読み込み中・完了・失敗の表示
- 表示中ページのURLをURL欄へ反映

## 動作環境

- macOS 14以降
- Xcode

外部ライブラリは使用していません。

## 起動方法

1. `MYBrowser/MYBrowser.xcodeproj`をXcodeで開く。
2. 画面上部の実行先で「My Mac」を選ぶ。
3. `⌘R`を押して起動する。
4. URL欄に、たとえば`apple.com`を入力してEnterを押す。

## 仕組み

```text
URL入力・操作ボタン（SwiftUI / ContentView）
             │
             ▼
SwiftUIとWebKitの橋渡し（WebView）
             │
             ▼
Webページの表示・履歴管理（WKWebView）
```

- `ContentView.swift`: URL欄、ボタン、読み込み状態、エラーを表示する。
- `WebView.swift`: `WKWebView`をSwiftUIに埋め込み、履歴や読み込みイベントを受け取る。
- `MYBrowser.entitlements`: App Sandbox内からWebサイトへ接続するためのネットワーク許可。

詳しい解説は[docs/browser-mechanism.md](docs/browser-mechanism.md)を参照してください。

## 学習のポイント

このアプリは独自のブラウザエンジンを作るものではありません。

- アプリ側: URL入力、ボタン、画面状態の管理
- WebKit側: 通信、HTML/CSS/JavaScriptの処理、ページ描画、履歴

という役割分担を理解するための最小構成です。

## 対象外の機能

- タブ
- ブックマークと履歴の保存
- ダウンロード管理
- 拡張機能
- 広告ブロック
- 複数ウィンドウ
