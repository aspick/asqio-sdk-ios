import Foundation

/// HTTP メソッド
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// API エンドポイント定義
enum APIEndpoint {
    // MARK: - Tickets
    case listTickets(page: Int, perPage: Int)
    case createTicket(message: String, title: String?, context: [String: String]?, deviceInfo: DeviceInfo)
    case getTicket(id: String)
    case markAsRead(ticketId: String)
    case unreadCount

    // MARK: - Messages
    case listMessages(ticketId: String, page: Int, perPage: Int)
    case postMessage(ticketId: String, body: String)

    // MARK: - Devices
    case registerDevice(pushToken: String, tokenType: TokenType, deviceInfo: DeviceInfo)
    case updateDevice(id: String, pushToken: String, deviceInfo: DeviceInfo)
    case unregisterDevice(id: String)

    /// パス
    var path: String {
        switch self {
        case .listTickets, .createTicket:
            return "/api/v1/tickets"
        case .getTicket(let id):
            return "/api/v1/tickets/\(id)"
        case .markAsRead(let ticketId):
            return "/api/v1/tickets/\(ticketId)/read"
        case .unreadCount:
            return "/api/v1/unread_count"
        case .listMessages(let ticketId, _, _):
            return "/api/v1/tickets/\(ticketId)/messages"
        case .postMessage(let ticketId, _):
            return "/api/v1/tickets/\(ticketId)/messages"
        case .registerDevice:
            return "/api/v1/devices"
        case .updateDevice(let id, _, _):
            return "/api/v1/devices/\(id)"
        case .unregisterDevice(let id):
            return "/api/v1/devices/\(id)"
        }
    }

    /// HTTP メソッド
    var method: HTTPMethod {
        switch self {
        case .listTickets, .getTicket, .unreadCount, .listMessages:
            return .get
        case .createTicket, .markAsRead, .postMessage, .registerDevice:
            return .post
        case .updateDevice:
            return .put
        case .unregisterDevice:
            return .delete
        }
    }

    /// クエリパラメータ
    var queryItems: [URLQueryItem]? {
        switch self {
        case .listTickets(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage))
            ]
        case .listMessages(_, let page, let perPage):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPage))
            ]
        default:
            return nil
        }
    }

    /// リクエストボディ
    var body: [String: Any]? {
        switch self {
        case .createTicket(let message, let title, let context, let deviceInfo):
            var body: [String: Any] = [
                "message": message
            ]
            body.merge(deviceInfo.toDictionary()) { _, new in new }
            if let title = title {
                body["title"] = title
            }
            if let context = context {
                body["context"] = context
            }
            return body

        case .postMessage(_, let messageBody):
            return [
                "message": [
                    "body": messageBody
                ]
            ]

        case .registerDevice(let pushToken, let tokenType, let deviceInfo):
            var device: [String: Any] = [
                "platform": Platform.ios.rawValue,
                "push_token": pushToken,
                "token_type": tokenType.rawValue
            ]
            device.merge(deviceInfo.toDictionary().filter { $0.key != "platform" }) { _, new in new }
            return ["device": device]

        case .updateDevice(_, let pushToken, let deviceInfo):
            var device: [String: Any] = [
                "push_token": pushToken
            ]
            device.merge(deviceInfo.toDictionary().filter { $0.key != "platform" }) { _, new in new }
            return ["device": device]

        default:
            return nil
        }
    }
}
