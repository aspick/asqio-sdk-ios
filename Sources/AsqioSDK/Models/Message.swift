import Foundation

/// メッセージの送信者タイプ
public enum SenderType: String, Codable, Sendable {
    case user
    case `operator`
}

/// スレッド内のメッセージ
public struct Message: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let senderType: SenderType
    public let senderId: String
    public let body: String
    public let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case senderType = "sender_type"
        case senderId = "sender_id"
        case body
        case createdAt = "created_at"
    }

    public init(
        id: String,
        senderType: SenderType,
        senderId: String,
        body: String,
        createdAt: Date
    ) {
        self.id = id
        self.senderType = senderType
        self.senderId = senderId
        self.body = body
        self.createdAt = createdAt
    }
}
