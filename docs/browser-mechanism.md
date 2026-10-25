# このミニブラウザの仕組み

## まず全体像

このアプリは、Webページを自力で描くプログラムではない。画面の操作部分をSwiftUIで作り、macOS標準の`WKWebView`にページ表示を任せている。

```text
あなた
  │ URLを入力してEnterを押す
  ▼
ContentView（操作画面）
  │ URLを確認して「このページを開いて」と伝える
  ▼
WebView（SwiftUIとWebKitの橋渡し）
  │
  ▼
WKWebView（macOS標準のWeb表示機能）
  │ ネットワーク通信、HTML/CSS/JavaScriptの処理、描画
  ▼
Webページが画面に表示される
```

## 登場するファイル

| ファイル | 担当 |
| --- | --- |
| `MYBrowserApp.swift` | アプリの開始地点。ウィンドウを作り、`ContentView`を表示する。 |
| `ContentView.swift` | URL欄、戻る・進む・再読み込みボタン、読み込み状態を表示する。 |
| `WebView.swift` | SwiftUIと`WKWebView`をつなぐ。WebKitからの通知も受け取る。 |
| `MYBrowser.entitlements` | アプリが外部のWebサイトへ通信するためのmacOSの許可設定。 |

## URLを開くまで

例として、URL欄に`apple.com`と入力してEnterを押す場合を追う。

1. `ContentView`のURL欄が、入力した文字列`apple.com`を受け取る。
2. `normalizedURL`がURLを確認する。
   - スキームがないため、`https://apple.com`に補う。
   - `http`または`https`以外なら、エラーにして開かない。
3. `ContentView`が開くべきURLを`WebView`へ渡す。
4. `WebView`が`WKWebView.load(URLRequest(...))`を呼ぶ。
5. `WKWebView`がWebサーバーに通信し、ページを取得して描画する。

アプリ側がHTMLを読んで画面を組み立てているわけではない。HTML、CSS、JavaScriptの解釈と描画は`WKWebView`の仕事である。

## SwiftUIとWKWebViewをつなぐ理由

SwiftUIは、ボタンや文字入力欄のようなアプリの画面を作るための仕組みである。一方、`WKWebView`は以前からあるmacOSの画面部品（AppKitの`NSView`）である。

そのままではSwiftUIの画面へ置けないため、`WebView.swift`で`NSViewRepresentable`を使う。

```text
SwiftUIのContentView
        │
        │ NSViewRepresentable
        ▼
WebView
        │
        ▼
AppKitのWKWebView
```

`makeNSView`は最初に`WKWebView`を作る場所、`updateNSView`はSwiftUI側の状態が変わったときにWebViewへ操作を伝える場所である。

## 戻る・進む・再読み込みの仕組み

履歴そのものは`WKWebView`が持っている。

```text
ページA → ページB → ページC
                     ↑ 今ここ
```

- 戻るボタン: `WKWebView.goBack()`
- 進むボタン: `WKWebView.goForward()`
- 再読み込みボタン: `WKWebView.reload()`

また、`WKWebView.canGoBack`と`WKWebView.canGoForward`を監視している。戻れる履歴がないときは、SwiftUI側で戻るボタンを無効にする。

## 読み込み状態とURL欄が変わる仕組み

`WKWebView`は、ページ移動中にイベントを通知する。`WebView.swift`の`Coordinator`が`WKNavigationDelegate`として受け取る。

```text
読み込み開始
  └─ didStartProvisionalNavigation
       └─ 「読み込み中」を表示

読み込み完了
  └─ didFinish
       ├─ 「読み込み完了」を表示
       └─ 実際に表示しているURLをURL欄へ反映

読み込み失敗
  └─ didFail... 
       └─ エラーメッセージを表示
```

この通知があるため、ページ内のリンクをクリックした場合でも、URL欄を正しいリンク先へ更新できる。

## なぜネットワーク通信の許可が必要か

macOSアプリは、App Sandbox（アプリを隔離する仕組み）を有効にできる。隔離されたアプリは、初期状態では自由に外部通信できない。

`MYBrowser.entitlements`の`com.apple.security.network.client`は、「このアプリがWebサイトへ接続してよい」という許可である。これがないと、コードが正しくてもWebページを取得できない。

## 責務の分担

| 担当 | このアプリが行うこと | WebKitが行うこと |
| --- | --- | --- |
| 画面 | URL欄、ボタン、状態表示 | Webページの見た目を描画 |
| URL | 入力を確認し、`https://`を補う | 指定されたURLへ通信 |
| 履歴 | ボタンを押したことを伝える | 履歴を保持し、戻る・進むを実行 |
| 読み込み状態 | 通知を受けて表示を更新 | 読み込み開始・完了・失敗を通知 |

## 次にコードを読む順番

1. `MYBrowserApp.swift`を読む。アプリの入口を確認する。
2. `ContentView.swift`を読む。ボタンとURL欄がどの状態を変えるかを見る。
3. `WebView.swift`を読む。`WKWebView`を作る場所と、イベントを受け取る場所を見る。
4. 実行中にURLを開き、コードの流れと画面の変化を対応づける。

最も大事なポイントは、**アプリは「操作用のUI」と「状態の同期」を担当し、WebKitは「Webページの処理と表示」を担当する**、という分担である。
