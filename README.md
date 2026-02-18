# asqio SDK iOS

カスタマーサポート用サービス asqio の iOS/macOS 向けの SDK です。アプリ内でユーザーが問い合わせ（チケット）を作成し、運営者とメッセージをやり取りできる機能を提供します。

## 要件

- iOS 16.0+ / macOS 13.0+
- Swift 5.9+
- 外部依存なし（Foundation + SwiftUI のみ）

## インストール

### Swift Package Manager

`Package.swift` の `dependencies` に追加してください。

```swift
dependencies: [
    .package(url: "https://github.com/aspick/asqio-sdk-ios.git", from: "1.0.0")
]
```

または Xcode のメニューから **File > Add Package Dependencies...** を選択し、リポジトリ URL を入力してください。

## 使い方

### 1. SDK の初期化

アプリ起動時に `AsqioSupport.configure()` を呼び出して SDK を初期化します。

```swift
import AsqioSDK

AsqioSupport.configure(
    tenantKey: "your-tenant-key",
    jwtProvider: {
        // 現在の JWT トークンを返す
        return await authService.getToken()
    }
)
```

### 2. チケット一覧画面の表示

`ticketListView()` で SwiftUI の View を取得できます。

```swift
NavigationStack {
    AsqioSupport.shared.ticketListView()
}
```

コンテキスト情報を付与してチケットを作成することもできます。

```swift
AsqioSupport.shared.ticketListView(context: ["source": "settings"])
```

### 3. プッシュ通知の登録

APNs デバイストークンを登録して、プッシュ通知を受け取れるようにします。

```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    Task {
        try await AsqioSupport.shared.registerForPushNotifications(token: deviceToken)
    }
}
```

### 4. 未読数の取得

未読チケット数を取得してバッジ表示などに利用できます。

```swift
let count = try await AsqioSupport.shared.getUnreadCount()
```

## ライセンス

[MIT](LICENSE)
