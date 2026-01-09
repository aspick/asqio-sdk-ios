import Foundation

/// チケット操作結果
public struct TicketListResult: Sendable {
    public let tickets: [Ticket]
    public let meta: PaginationMeta
}

/// チケット操作サービス
public actor TicketService {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    /// チケット一覧を取得
    /// - Parameters:
    ///   - page: ページ番号（1から開始）
    ///   - perPage: 1ページあたりの件数
    /// - Returns: チケット一覧とページネーション情報
    public func listTickets(page: Int = 1, perPage: Int = 20) async throws -> TicketListResult {
        let response: TicketListResponse = try await client.request(
            .listTickets(page: page, perPage: perPage)
        )
        return TicketListResult(tickets: response.tickets, meta: response.meta)
    }

    /// 新規チケットを作成
    /// - Parameters:
    ///   - message: 初回メッセージ
    ///   - title: タイトル（省略時は初回メッセージから自動生成）
    ///   - context: コンテキスト（key-value）
    ///   - deviceInfo: 端末情報
    /// - Returns: 作成されたチケット
    public func createTicket(
        message: String,
        title: String? = nil,
        context: [String: String]? = nil,
        deviceInfo: DeviceInfo = .current()
    ) async throws -> Ticket {
        return try await client.request(
            .createTicket(message: message, title: title, context: context, deviceInfo: deviceInfo)
        )
    }

    /// チケット詳細を取得
    /// - Parameter id: チケット ID
    /// - Returns: チケット詳細（メッセージ含む）
    public func getTicket(id: String) async throws -> Ticket {
        return try await client.request(.getTicket(id: id))
    }

    /// チケットを既読にする
    /// - Parameter ticketId: チケット ID
    public func markAsRead(ticketId: String) async throws {
        try await client.requestVoid(.markAsRead(ticketId: ticketId))
    }

    /// 未読チケット数を取得
    /// - Returns: 未読チケット数
    public func getUnreadCount() async throws -> Int {
        let response: UnreadCountResponse = try await client.request(.unreadCount)
        return response.unreadCount
    }
}
