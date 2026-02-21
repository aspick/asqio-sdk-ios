import Foundation

/// 問い合わせチケット（スレッド）
public struct Ticket: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let title: String?
    public let topic: Topic?
    public let context: [String: String]?
    public let deviceInfo: TicketDeviceInfo?
    public let unread: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public let messages: [Message]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case topic
        case context
        case deviceInfo = "device_info"
        case unread
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case messages
    }

    public init(
        id: String,
        title: String?,
        topic: Topic? = nil,
        context: [String: String]?,
        deviceInfo: TicketDeviceInfo?,
        unread: Bool,
        createdAt: Date,
        updatedAt: Date,
        messages: [Message]? = nil
    ) {
        self.id = id
        self.title = title
        self.topic = topic
        self.context = context
        self.deviceInfo = deviceInfo
        self.unread = unread
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
    }
}

/// チケット作成時に保存される端末情報
public struct TicketDeviceInfo: Codable, Sendable, Equatable {
    public let platform: String?
    public let osVersion: String?
    public let appVersion: String?
    public let deviceModel: String?
    public let locale: String?
    public let timezone: String?

    enum CodingKeys: String, CodingKey {
        case platform
        case osVersion = "os_version"
        case appVersion = "app_version"
        case deviceModel = "device_model"
        case locale
        case timezone
    }
}
