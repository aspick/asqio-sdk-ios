import Foundation

/// メッセージ一覧結果
public struct MessageListResult: Sendable {
    public let messages: [Message]
    public let meta: PaginationMeta
}

/// メッセージ操作サービス
public actor MessageService {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    /// メッセージ一覧を取得
    /// - Parameters:
    ///   - ticketId: チケット ID
    ///   - page: ページ番号（1から開始）
    ///   - perPage: 1ページあたりの件数
    /// - Returns: メッセージ一覧とページネーション情報
    public func listMessages(
        ticketId: String,
        page: Int = 1,
        perPage: Int = 50
    ) async throws -> MessageListResult {
        let response: MessageListResponse = try await client.request(
            .listMessages(ticketId: ticketId, page: page, perPage: perPage)
        )
        return MessageListResult(messages: response.messages, meta: response.meta)
    }

    /// メッセージを投稿
    /// - Parameters:
    ///   - ticketId: チケット ID
    ///   - body: メッセージ本文
    /// - Returns: 投稿されたメッセージ
    public func postMessage(ticketId: String, body: String) async throws -> Message {
        return try await client.request(.postMessage(ticketId: ticketId, body: body))
    }
}
