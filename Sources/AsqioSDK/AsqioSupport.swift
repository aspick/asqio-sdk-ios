import SwiftUI

/// asqio サポート SDK
///
/// ## 使用方法
///
/// 1. SDK を初期化
/// ```swift
/// AsqioSupport.configure(
///     tenantKey: "your-tenant-key",
///     jwtProvider: {
///         // 現在の JWT トークンを返す
///         return await authService.getToken()
///     }
/// )
/// ```
///
/// 2. チケット一覧画面を表示
/// ```swift
/// NavigationStack {
///     AsqioSupport.shared.ticketListView()
/// }
/// ```
///
/// 3. Push トークンを登録（APNs）
/// ```swift
/// func application(_ application: UIApplication,
///                  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
///     Task {
///         try await AsqioSupport.shared.registerForPushNotifications(token: deviceToken)
///     }
/// }
/// ```
///
/// 3b. Push トークンを登録（FCM）
/// ```swift
/// Messaging.messaging().token { token, error in
///     guard let token else { return }
///     Task {
///         try await AsqioSupport.shared.registerForPushNotifications(fcmToken: token)
///     }
/// }
/// ```
///
/// 4. 未読数を取得
/// ```swift
/// let count = try await AsqioSupport.shared.getUnreadCount()
/// ```
public final class AsqioSupport: @unchecked Sendable {
    /// 共有インスタンス
    public static let shared = AsqioSupport()

    private var configuration: AsqioConfiguration?
    private var apiClient: APIClient?
    private var _ticketService: TicketService?
    private var _messageService: MessageService?
    private var _deviceService: DeviceService?

    private let lock = NSLock()

    private init() {}

    // MARK: - Configuration

    /// SDK を初期化
    /// - Parameters:
    ///   - tenantKey: テナントキー
    ///   - jwtProvider: JWT トークンを提供するクロージャ
    ///   - baseURL: ベース URL（省略時はデフォルト）
    public static func configure(
        tenantKey: String,
        jwtProvider: @escaping JWTProvider,
        baseURL: URL = AsqioConfiguration.defaultBaseURL
    ) {
        let config = AsqioConfiguration(
            tenantKey: tenantKey,
            jwtProvider: jwtProvider,
            baseURL: baseURL
        )
        shared.setConfiguration(config)
    }

    private func setConfiguration(_ config: AsqioConfiguration) {
        lock.lock()
        defer { lock.unlock() }

        self.configuration = config
        self.apiClient = APIClient(
            baseURL: config.baseURL,
            tenantKey: config.tenantKey,
            jwtProvider: config.jwtProvider
        )
        self._ticketService = TicketService(client: apiClient!)
        self._messageService = MessageService(client: apiClient!)
        self._deviceService = DeviceService(client: apiClient!)
    }

    /// SDK が初期化済みかどうか
    public var isConfigured: Bool {
        lock.lock()
        defer { lock.unlock() }
        return configuration != nil
    }

    // MARK: - Services

    /// チケットサービス
    public var ticketService: TicketService {
        get throws {
            lock.lock()
            defer { lock.unlock() }
            guard let service = _ticketService else {
                throw AsqioError.notConfigured
            }
            return service
        }
    }

    /// メッセージサービス
    public var messageService: MessageService {
        get throws {
            lock.lock()
            defer { lock.unlock() }
            guard let service = _messageService else {
                throw AsqioError.notConfigured
            }
            return service
        }
    }

    /// デバイスサービス
    public var deviceService: DeviceService {
        get throws {
            lock.lock()
            defer { lock.unlock() }
            guard let service = _deviceService else {
                throw AsqioError.notConfigured
            }
            return service
        }
    }

    // MARK: - Views

    /// チケット一覧画面を取得
    /// - Parameter context: 新規チケット作成時に付与するコンテキスト
    /// - Returns: チケット一覧の SwiftUI View
    @MainActor
    public func ticketListView(context: [String: String]? = nil) -> some View {
        guard let ticketService = try? ticketService,
              let messageService = try? messageService else {
            return AnyView(
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("SDK が初期化されていません")
                        .font(.headline)
                    Text("AsqioSupport.configure() を呼び出してください")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            )
        }

        let view = TicketListView(
            ticketService: ticketService,
            messageService: messageService,
            context: context
        )

        return AnyView(view)
    }

    // MARK: - Push Notifications

    /// APNs トークンでデバイスを登録
    /// - Parameter token: APNs から取得したデバイストークン（Data）
    /// - Returns: 登録されたデバイス情報
    @discardableResult
    public func registerForPushNotifications(token: Data) async throws -> Device {
        let service = try deviceService
        return try await service.registerDevice(pushToken: token.hexString, tokenType: .apns)
    }

    /// FCM トークンでデバイスを登録
    /// - Parameter fcmToken: Firebase Cloud Messaging から取得したトークン（String）
    /// - Returns: 登録されたデバイス情報
    @discardableResult
    public func registerForPushNotifications(fcmToken: String) async throws -> Device {
        let service = try deviceService
        return try await service.registerDevice(pushToken: fcmToken, tokenType: .fcm)
    }

    // MARK: - Unread Count

    /// 未読チケット数を取得
    /// - Returns: 未読チケット数
    public func getUnreadCount() async throws -> Int {
        let service = try ticketService
        return try await service.getUnreadCount()
    }
}

// MARK: - Public Type Exports

// Models are already public
// Services are accessed through AsqioSupport.shared
