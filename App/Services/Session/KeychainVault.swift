/**
 The app's `SecretVault`: one generic-password Keychain item per `VaultKey`, readable after the
 first unlock and never synced or restored to another device (AGENTS.md Rule 13).
 */
import Features
import Foundation
import Security

/** The Keychain behind the session and the app lock. */
nonisolated struct KeychainVault: SecretVault {
    /** The error a failed Keychain call throws: its status, in the system's OSStatus domain. */
    private static func failure(_ status: OSStatus) -> NSError {
        NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }

    /** The items' service, one per app. */
    private let service = "com.kira.finance.vault"

    func data(for key: VaultKey) throws -> Data? {
        var query = baseQuery(key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw Self.failure(status) }
        return result as? Data
    }

    func set(_ data: Data, for key: VaultKey) throws {
        let attributes: [String: CFTypeRef] = [
            kSecValueData as String: data as CFData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        let status = SecItemUpdate(baseQuery(key) as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            let added = baseQuery(key).merging(attributes) { _, new in new }
            let addStatus = SecItemAdd(added as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw Self.failure(addStatus) }
            return
        }
        guard status == errSecSuccess else { throw Self.failure(status) }
    }

    func remove(_ key: VaultKey) throws {
        let status = SecItemDelete(baseQuery(key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw Self.failure(status) }
    }

    private func baseQuery(_ key: VaultKey) -> [String: CFTypeRef] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as CFString,
            kSecAttrAccount as String: key.rawValue as CFString,
            kSecUseDataProtectionKeychain as String: kCFBooleanTrue,
        ]
    }
}
