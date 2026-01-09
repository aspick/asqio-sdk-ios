import Foundation

/// デバイス登録サービス
public actor DeviceService {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    /// デバイスを登録（Push 通知用）
    /// - Parameters:
    ///   - pushToken: APNs トークン（Data を16進数文字列に変換したもの）
    ///   - tokenType: トークン種別（iOS では通常 .apns）
    ///   - deviceInfo: 端末情報
    /// - Returns: 登録されたデバイス情報
    public func registerDevice(
        pushToken: String,
        tokenType: TokenType = .apns,
        deviceInfo: DeviceInfo = .current()
    ) async throws -> Device {
        return try await client.request(
            .registerDevice(pushToken: pushToken, tokenType: tokenType, deviceInfo: deviceInfo)
        )
    }

    /// デバイス情報を更新
    /// - Parameters:
    ///   - id: デバイス ID
    ///   - pushToken: 新しい Push トークン
    ///   - deviceInfo: 端末情報
    /// - Returns: 更新されたデバイス情報
    public func updateDevice(
        id: String,
        pushToken: String,
        deviceInfo: DeviceInfo = .current()
    ) async throws -> Device {
        return try await client.request(
            .updateDevice(id: id, pushToken: pushToken, deviceInfo: deviceInfo)
        )
    }

    /// デバイス登録を解除
    /// - Parameter id: デバイス ID
    public func unregisterDevice(id: String) async throws {
        try await client.requestVoid(.unregisterDevice(id: id))
    }
}

// MARK: - Data Extension for Push Token

public extension Data {
    /// Push トークンを16進数文字列に変換
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
