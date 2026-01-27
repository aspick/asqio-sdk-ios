import Foundation

/// プラットフォーム種別
public enum Platform: String, Codable, Sendable {
    case ios
    case android
    case web
}

/// Push トークン種別
public enum TokenType: String, Codable, Sendable {
    case apns
    case fcm
}

/// 登録済みデバイス情報
public struct Device: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let platform: Platform
    public let pushToken: String
    public let osVersion: String?
    public let appVersion: String?
    public let deviceModel: String?
    public let locale: String?
    public let timezone: String?

    enum CodingKeys: String, CodingKey {
        case id
        case platform
        case pushToken = "push_token"
        case osVersion = "os_version"
        case appVersion = "app_version"
        case deviceModel = "device_model"
        case locale
        case timezone
    }

    public init(
        id: String,
        platform: Platform,
        pushToken: String,
        osVersion: String?,
        appVersion: String?,
        deviceModel: String?,
        locale: String?,
        timezone: String?
    ) {
        self.id = id
        self.platform = platform
        self.pushToken = pushToken
        self.osVersion = osVersion
        self.appVersion = appVersion
        self.deviceModel = deviceModel
        self.locale = locale
        self.timezone = timezone
    }
}
