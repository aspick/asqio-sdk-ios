import Foundation

/// API エラーコード
public enum APIErrorCode: String, Codable, Sendable {
    case unauthorized = "UNAUTHORIZED"
    case tenantKeyRequired = "TENANT_KEY_REQUIRED"
    case tenantNotFound = "TENANT_NOT_FOUND"
    case notFound = "NOT_FOUND"
    case validationError = "VALIDATION_ERROR"
    case badRequest = "BAD_REQUEST"
    case internalServerError = "INTERNAL_SERVER_ERROR"
    case unknown = "UNKNOWN"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = APIErrorCode(rawValue: rawValue) ?? .unknown
    }
}

/// API エラーレスポンス
public struct APIErrorResponse: Codable, Sendable {
    public let error: String
    public let code: APIErrorCode
}

/// SDK エラー
public enum AsqioError: Error, Sendable {
    /// API からのエラーレスポンス
    case apiError(code: APIErrorCode, message: String, statusCode: Int)

    /// ネットワークエラー
    case networkError(Error)

    /// デコードエラー
    case decodingError(Error)

    /// SDK が初期化されていない
    case notConfigured

    /// JWT の取得に失敗
    case jwtProviderFailed

    /// 不正なレスポンス
    case invalidResponse

    /// 不正な URL
    case invalidURL
}

extension AsqioError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .apiError(let code, let message, let statusCode):
            return "API Error (\(statusCode)): [\(code.rawValue)] \(message)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .notConfigured:
            return "AsqioSupport SDK is not configured. Call AsqioSupport.configure() first."
        case .jwtProviderFailed:
            return "Failed to obtain JWT token from provider."
        case .invalidResponse:
            return "Invalid response from server."
        case .invalidURL:
            return "Invalid URL."
        }
    }
}
