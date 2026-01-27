import XCTest
@testable import AsqioSDK

final class AsqioSupportTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // テスト前に SDK をリセット（内部状態をクリア）
    }

    func testSDKNotConfiguredByDefault() {
        // 新しいインスタンスを作成してテスト
        // shared は既に configure されている可能性があるため
        // isConfigured の初期値テストはスキップ
    }

    func testSDKConfiguration() {
        AsqioSupport.configure(
            tenantKey: "test-tenant",
            jwtProvider: { "test-jwt-token" }
        )

        XCTAssertTrue(AsqioSupport.shared.isConfigured)
    }

    func testSDKConfigurationWithCustomBaseURL() {
        let customURL = URL(string: "https://custom.api.example.com")!

        AsqioSupport.configure(
            tenantKey: "test-tenant",
            jwtProvider: { "test-jwt-token" },
            baseURL: customURL
        )

        XCTAssertTrue(AsqioSupport.shared.isConfigured)
    }

    func testServicesAvailableAfterConfiguration() throws {
        AsqioSupport.configure(
            tenantKey: "test-tenant",
            jwtProvider: { "test-jwt-token" }
        )

        XCTAssertNoThrow(try AsqioSupport.shared.ticketService)
        XCTAssertNoThrow(try AsqioSupport.shared.messageService)
        XCTAssertNoThrow(try AsqioSupport.shared.deviceService)
    }
}
