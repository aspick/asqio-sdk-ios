import Foundation

/// JWT トークンを提供するクロージャ型
public typealias JWTProvider = @Sendable () async throws -> String

/// API クライアント
actor APIClient {
    private let baseURL: URL
    private let tenantKey: String
    private let jwtProvider: JWTProvider
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, tenantKey: String, jwtProvider: @escaping JWTProvider) {
        self.baseURL = baseURL
        self.tenantKey = tenantKey
        self.jwtProvider = jwtProvider
        self.session = URLSession.shared

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    /// API リクエストを実行
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try await buildRequest(for: endpoint)
        let (data, response) = try await performRequest(request)
        return try handleResponse(data: data, response: response)
    }

    /// レスポンスなしの API リクエストを実行
    func requestVoid(_ endpoint: APIEndpoint) async throws {
        let request = try await buildRequest(for: endpoint)
        let (data, response) = try await performRequest(request)
        try handleVoidResponse(data: data, response: response)
    }

    // MARK: - Private

    private func buildRequest(for endpoint: APIEndpoint) async throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw AsqioError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // ヘッダ設定
        let jwt: String
        do {
            jwt = try await jwtProvider()
        } catch {
            throw AsqioError.jwtProviderFailed
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.setValue(tenantKey, forHTTPHeaderField: "X-Tenant-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // ボディ設定
        if let body = endpoint.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw AsqioError.networkError(error)
        }
    }

    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AsqioError.invalidResponse
        }

        let statusCode = httpResponse.statusCode

        if (200..<300).contains(statusCode) {
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw AsqioError.decodingError(error)
            }
        } else {
            throw try parseErrorResponse(data: data, statusCode: statusCode)
        }
    }

    private func handleVoidResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AsqioError.invalidResponse
        }

        let statusCode = httpResponse.statusCode

        if !(200..<300).contains(statusCode) {
            throw try parseErrorResponse(data: data, statusCode: statusCode)
        }
    }

    private func parseErrorResponse(data: Data, statusCode: Int) throws -> AsqioError {
        do {
            let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
            return .apiError(code: errorResponse.code, message: errorResponse.error, statusCode: statusCode)
        } catch {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            return .apiError(code: .unknown, message: message, statusCode: statusCode)
        }
    }
}
