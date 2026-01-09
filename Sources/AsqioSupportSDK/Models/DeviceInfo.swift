import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 端末情報を自動収集するヘルパー
public struct DeviceInfo: Sendable {
    public let platform: Platform
    public let osVersion: String
    public let appVersion: String
    public let deviceModel: String
    public let locale: String
    public let timezone: String

    /// 現在の端末情報を収集
    public static func current(appVersion: String? = nil) -> DeviceInfo {
        let resolvedAppVersion = appVersion
            ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "unknown"

        return DeviceInfo(
            platform: .ios,
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            appVersion: resolvedAppVersion,
            deviceModel: Self.getDeviceModel(),
            locale: Locale.current.identifier,
            timezone: TimeZone.current.identifier
        )
    }

    private static func getDeviceModel() -> String {
        #if canImport(UIKit) && !targetEnvironment(simulator)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
        #else
        return "Simulator"
        #endif
    }

    /// API リクエスト用の辞書に変換
    func toDictionary() -> [String: String] {
        [
            "platform": platform.rawValue,
            "os_version": osVersion,
            "app_version": appVersion,
            "device_model": deviceModel,
            "locale": locale,
            "timezone": timezone
        ]
    }
}
