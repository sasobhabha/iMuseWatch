import Foundation
import Security

public final class KeychainVault: @unchecked Sendable {
    public static let shared = KeychainVault()
    public static let presetSdkToken = "mgst_1HUkFVHl3dwahbS6kNKoQIzbizboWJj1TM727KSHN7Y"
    private let service = "dev.puck.iMuseWatch"

    public var macAddress: String {
        if let stored = readString(for: "device_mac"), !stored.isEmpty {
            return stored
        }
        let generated = Self.generatePseudoMac()
        save(string: generated, for: "device_mac")
        return generated
    }

    public var nodeId: String {
        let suffix = macAddress.replacingOccurrences(of: ":", with: "").suffix(6).lowercased()
        return "homelink-\(suffix)"
    }

    public var deviceId: String {
        return "hatch-link:\(macAddress)"
    }

    public func save(string: String, for key: String) {
        guard let data = string.data(using: .utf8) else { return }
        save(data: data, for: key)
    }

    public func readString(for key: String) -> String? {
        guard let data = readData(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func save(data: Data, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    public func readData(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return (status == errSecSuccess) ? (result as? Data) : nil
    }

    public func remove(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    public func hasCredentials() -> Bool {
        return (readString(for: "sdk_token") != nil && !readString(for: "sdk_token")!.isEmpty) ||
               (readString(for: "access_token") != nil && !readString(for: "access_token")!.isEmpty)
    }

    public static func validateSdkToken(_ token: String) -> Bool {
        let clean = token.trimmingCharacters(in: .whitespacesAndNewlines)
        // Meta Muse SDK token pattern: mgst_[A-Za-z0-9_-]{42}[AEIMQUYcgkosw048]
        let pattern = "^mgst_[A-Za-z0-9_-]{42}[AEIMQUYcgkosw048]$"
        return clean.range(of: pattern, options: .regularExpression) != nil
    }

    private static func generatePseudoMac() -> String {
        var bytes = [UInt8](repeating: 0, count: 6)
        _ = SecRandomCopyBytes(kSecRandomDefault, 6, &bytes)
        bytes[0] = (bytes[0] & 0xFC) | 0x02 // locally administered unicast
        return bytes.map { String(format: "%02x", $0) }.joined(separator: ":")
    }
}
