import XCTest
@testable import AsqioSDK

final class ModelTests: XCTestCase {

    // MARK: - Message Tests

    func testMessageDecoding() throws {
        let json = """
        {
            "id": "msg-123",
            "sender_type": "user",
            "sender_id": "user-456",
            "body": "テストメッセージ",
            "created_at": "2024-01-15T10:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let message = try decoder.decode(Message.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(message.id, "msg-123")
        XCTAssertEqual(message.senderType, .user)
        XCTAssertEqual(message.senderId, "user-456")
        XCTAssertEqual(message.body, "テストメッセージ")
    }

    func testOperatorMessageDecoding() throws {
        let json = """
        {
            "id": "msg-789",
            "sender_type": "operator",
            "sender_id": "op-001",
            "body": "運営者からの返信です",
            "created_at": "2024-01-15T11:00:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let message = try decoder.decode(Message.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(message.senderType, .operator)
    }

    // MARK: - Topic Tests

    func testTopicDecoding() throws {
        let json = """
        {
            "id": "topic-123",
            "name": "お支払い"
        }
        """

        let decoder = JSONDecoder()
        let topic = try decoder.decode(Topic.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(topic.id, "topic-123")
        XCTAssertEqual(topic.name, "お支払い")
    }

    func testTopicListDecoding() throws {
        let json = """
        {
            "topics": [
                {"id": "topic-1", "name": "アカウント"},
                {"id": "topic-2", "name": "お支払い"}
            ]
        }
        """

        let decoder = JSONDecoder()
        let response = try decoder.decode(TopicListResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(response.topics.count, 2)
        XCTAssertEqual(response.topics[0].name, "アカウント")
        XCTAssertEqual(response.topics[1].name, "お支払い")
    }

    // MARK: - Ticket Tests

    func testTicketDecoding() throws {
        let json = """
        {
            "id": "ticket-123",
            "title": "テストチケット",
            "topic": {"id": "topic-1", "name": "お支払い"},
            "context": {"screen": "payment", "plan": "pro"},
            "device_info": {
                "platform": "ios",
                "os_version": "17.0",
                "app_version": "1.0.0",
                "device_model": "iPhone15,2",
                "locale": "ja_JP",
                "timezone": "Asia/Tokyo"
            },
            "unread": true,
            "created_at": "2024-01-15T10:00:00Z",
            "updated_at": "2024-01-15T10:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let ticket = try decoder.decode(Ticket.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(ticket.id, "ticket-123")
        XCTAssertEqual(ticket.title, "テストチケット")
        XCTAssertEqual(ticket.topic?.id, "topic-1")
        XCTAssertEqual(ticket.topic?.name, "お支払い")
        XCTAssertEqual(ticket.context?["screen"], "payment")
        XCTAssertEqual(ticket.context?["plan"], "pro")
        XCTAssertEqual(ticket.deviceInfo?.platform, "ios")
        XCTAssertEqual(ticket.deviceInfo?.osVersion, "17.0")
        XCTAssertTrue(ticket.unread)
    }

    func testTicketWithNullTitle() throws {
        let json = """
        {
            "id": "ticket-456",
            "title": null,
            "topic": null,
            "context": null,
            "device_info": null,
            "unread": false,
            "created_at": "2024-01-15T10:00:00Z",
            "updated_at": "2024-01-15T10:00:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let ticket = try decoder.decode(Ticket.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(ticket.id, "ticket-456")
        XCTAssertNil(ticket.title)
        XCTAssertNil(ticket.topic)
        XCTAssertNil(ticket.context)
        XCTAssertNil(ticket.deviceInfo)
        XCTAssertFalse(ticket.unread)
    }

    // MARK: - Device Tests

    func testDeviceDecoding() throws {
        let json = """
        {
            "id": "device-123",
            "platform": "ios",
            "push_token": "abc123def456",
            "os_version": "17.0",
            "app_version": "1.0.0",
            "device_model": "iPhone15,2",
            "locale": "ja_JP",
            "timezone": "Asia/Tokyo"
        }
        """

        let decoder = JSONDecoder()
        let device = try decoder.decode(Device.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(device.id, "device-123")
        XCTAssertEqual(device.platform, .ios)
        XCTAssertEqual(device.pushToken, "abc123def456")
        XCTAssertEqual(device.osVersion, "17.0")
    }

    // MARK: - API Error Tests

    func testAPIErrorDecoding() throws {
        let json = """
        {
            "error": "Invalid JWT token",
            "code": "UNAUTHORIZED"
        }
        """

        let decoder = JSONDecoder()
        let errorResponse = try decoder.decode(APIErrorResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(errorResponse.error, "Invalid JWT token")
        XCTAssertEqual(errorResponse.code, .unauthorized)
    }

    func testUnknownAPIErrorCode() throws {
        let json = """
        {
            "error": "Something went wrong",
            "code": "SOME_NEW_ERROR"
        }
        """

        let decoder = JSONDecoder()
        let errorResponse = try decoder.decode(APIErrorResponse.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(errorResponse.code, .unknown)
    }

    // MARK: - Pagination Tests

    func testPaginationMetaDecoding() throws {
        let json = """
        {
            "current_page": 2,
            "total_pages": 5,
            "total_count": 100,
            "per_page": 20
        }
        """

        let decoder = JSONDecoder()
        let meta = try decoder.decode(PaginationMeta.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(meta.currentPage, 2)
        XCTAssertEqual(meta.totalPages, 5)
        XCTAssertEqual(meta.totalCount, 100)
        XCTAssertEqual(meta.perPage, 20)
    }

    // MARK: - DeviceInfo Tests

    func testDeviceInfoCurrent() {
        let deviceInfo = DeviceInfo.current(appVersion: "1.0.0")

        XCTAssertEqual(deviceInfo.platform, .ios)
        XCTAssertEqual(deviceInfo.appVersion, "1.0.0")
        XCTAssertFalse(deviceInfo.osVersion.isEmpty)
        XCTAssertFalse(deviceInfo.locale.isEmpty)
        XCTAssertFalse(deviceInfo.timezone.isEmpty)
    }

    func testDeviceInfoToDictionary() {
        let deviceInfo = DeviceInfo.current(appVersion: "2.0.0")
        let dict = deviceInfo.toDictionary()

        XCTAssertEqual(dict["platform"], "ios")
        XCTAssertEqual(dict["app_version"], "2.0.0")
        XCTAssertNotNil(dict["os_version"])
        XCTAssertNotNil(dict["locale"])
        XCTAssertNotNil(dict["timezone"])
    }

    // MARK: - APIEndpoint Tests

    func testListTopicsEndpoint() {
        let endpoint = APIEndpoint.listTopics

        XCTAssertEqual(endpoint.path, "/api/v1/topics")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertNil(endpoint.queryItems)
        XCTAssertNil(endpoint.body)
    }

    func testCreateTicketWithTopicId() {
        let deviceInfo = DeviceInfo.current(appVersion: "1.0.0")
        let endpoint = APIEndpoint.createTicket(
            message: "テスト",
            title: "件名",
            topicId: "topic-123",
            context: nil,
            deviceInfo: deviceInfo
        )

        XCTAssertEqual(endpoint.path, "/api/v1/tickets")
        XCTAssertEqual(endpoint.method, .post)

        let body = endpoint.body
        XCTAssertNotNil(body)
        XCTAssertEqual(body?["message"] as? String, "テスト")
        XCTAssertEqual(body?["title"] as? String, "件名")
        XCTAssertEqual(body?["topic_id"] as? String, "topic-123")
    }

    func testCreateTicketWithoutTopicId() {
        let deviceInfo = DeviceInfo.current(appVersion: "1.0.0")
        let endpoint = APIEndpoint.createTicket(
            message: "テスト",
            title: nil,
            topicId: nil,
            context: nil,
            deviceInfo: deviceInfo
        )

        let body = endpoint.body
        XCTAssertNotNil(body)
        XCTAssertEqual(body?["message"] as? String, "テスト")
        XCTAssertNil(body?["title"])
        XCTAssertNil(body?["topic_id"])
    }

    // MARK: - Data Extension Tests

    func testDataHexString() {
        let data = Data([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF])
        XCTAssertEqual(data.hexString, "0123456789abcdef")
    }

    func testEmptyDataHexString() {
        let data = Data()
        XCTAssertEqual(data.hexString, "")
    }
}
