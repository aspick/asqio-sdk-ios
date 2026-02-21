import Foundation

/// ページネーションメタデータ
public struct PaginationMeta: Codable, Sendable {
    public let currentPage: Int
    public let totalPages: Int
    public let totalCount: Int
    public let perPage: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
        case perPage = "per_page"
    }
}

/// チケット一覧レスポンス
struct TicketListResponse: Codable {
    let tickets: [Ticket]
    let meta: PaginationMeta
}

/// トピック一覧レスポンス
struct TopicListResponse: Codable {
    let topics: [Topic]
}

/// メッセージ一覧レスポンス
struct MessageListResponse: Codable {
    let messages: [Message]
    let meta: PaginationMeta
}

/// 未読数レスポンス
struct UnreadCountResponse: Codable {
    let unreadCount: Int

    enum CodingKeys: String, CodingKey {
        case unreadCount = "unread_count"
    }
}
