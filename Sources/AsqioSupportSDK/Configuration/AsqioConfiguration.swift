import Foundation

/// SDK 設定
public struct AsqioConfiguration: Sendable {
    /// テナントキー
    public let tenantKey: String

    /// ベース URL
    public let baseURL: URL

    /// JWT プロバイダ
    public let jwtProvider: JWTProvider

    /// デフォルトのベース URL
    public static let defaultBaseURL = URL(string: "https://api.asqio.example.com")!

    /// 設定を作成
    /// - Parameters:
    ///   - tenantKey: テナントキー
    ///   - jwtProvider: JWT トークンを提供するクロージャ
    ///   - baseURL: ベース URL（省略時はデフォルト）
    public init(
        tenantKey: String,
        jwtProvider: @escaping JWTProvider,
        baseURL: URL = defaultBaseURL
    ) {
        self.tenantKey = tenantKey
        self.jwtProvider = jwtProvider
        self.baseURL = baseURL
    }
}
