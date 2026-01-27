# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

asqio-sdk-ios は iOS/macOS 向けのカスタマーサポート SDK です。アプリ内でユーザーが問い合わせ（チケット）を作成し、運営者とメッセージをやり取りできる機能を提供します。

- **パッケージ名**: AsqioSDK
- **対応プラットフォーム**: iOS 16.0+, macOS 13.0+
- **Swift バージョン**: 5.9+
- **外部依存**: なし（Foundation + SwiftUI のみ）

## Build & Test Commands

```bash
# ビルド
swift build

# テスト実行
swift test

# 単一テストファイルの実行
swift test --filter AsqioSDKTests.ModelTests

# 単一テストケースの実行
swift test --filter ModelTests/testMessageDecoding
```

## Architecture

### レイヤー構成

```
SwiftUI Views + ViewModels (@MainActor)
        ↓
Services Layer (TicketService, MessageService, DeviceService) - すべて actor
        ↓
APIClient (actor) - URLSession ベースの HTTP クライアント
        ↓
Models (Codable, Sendable)
```

### エントリーポイント

`AsqioSupport.swift` がパブリック API のエントリーポイント。シングルトンパターン（`AsqioSupport.shared`）で提供。

```swift
// SDK 初期化
AsqioSupport.configure(
    tenantKey: "tenant-123",
    jwtProvider: { await getJWT() }
)

// UI 表示
AsqioSupport.shared.ticketListView(context: ["source": "settings"])

// Push 登録
try await AsqioSupport.shared.registerForPushNotifications(token: deviceToken)

// 未読数取得
let count = try await AsqioSupport.shared.getUnreadCount()
```

### スレッドセーフティ

- 全サービスは **actor** として実装（APIClient, TicketService, MessageService, DeviceService）
- 全モデルは **Sendable** に準拠
- UI 操作は **@MainActor** で保護
- Swift Concurrency（async/await）を全面採用

### API 通信フロー

1. View → ViewModel（@MainActor）がユーザー操作を受け取る
2. ViewModel → Service（actor）を呼び出し
3. Service → APIClient（actor）でリクエスト実行
4. APIClient が JWT を `jwtProvider` から取得し、Authorization ヘッダーに付与
5. レスポンスを Codable モデルにデコード（ISO8601 日付形式）

## Key Files

| ファイル | 役割 |
|---------|------|
| `Sources/AsqioSDK/AsqioSupport.swift` | パブリック API エントリーポイント |
| `Sources/AsqioSDK/Networking/APIClient.swift` | HTTP クライアント（actor） |
| `Sources/AsqioSDK/Networking/APIEndpoint.swift` | API エンドポイント定義 |
| `Sources/AsqioSDK/Services/*.swift` | ビジネスロジック層 |
| `Sources/AsqioSDK/Views/TicketListView.swift` | チケット一覧画面（メイン UI） |

## Conventions

- 日本語 UI テキスト、日本語コメント
- すべての public 型は `Sendable` に準拠
- JSON キーはスネークケース（`device_info`, `sender_type`）
- API レスポンスは `PaginationMeta` でページネーション対応
- エラーは `AsqioError` 型に集約

## Backend API Reference

バックエンドの API 仕様は `asqio-backend` リポジトリの `contracts/openapi/openapi.yaml` を参照。
