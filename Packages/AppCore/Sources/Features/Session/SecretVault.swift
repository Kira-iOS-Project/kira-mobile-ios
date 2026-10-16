import Foundation
import os

/**
 The device's secret storage (AGENTS.md Rule 13): the app implements it with the Keychain
 (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`), the tests and previews with `InMemoryVault`.
 Nothing in it is ever written to the app's preferences, a log or the server.
 */
package protocol SecretVault: Sendable {
    /** The data stored under `key`, or nil when there is none. */
    func data(for key: VaultKey) throws -> Data?
    /** Stores `data` under `key`, replacing what was there. */
    func set(_ data: Data, for key: VaultKey) throws
    /** Removes what is stored under `key`; removing nothing is no error. */
    func remove(_ key: VaultKey) throws
}

/** The items Kira keeps in the vault, each its own Keychain item. */
package enum VaultKey: String, CaseIterable, Sendable {
    /** The session's refresh token. */
    case refreshToken = "session.refresh-token"
    /** The signed-in account's email, for the lock screen's greeting and PIN recovery. */
    case accountEmail = "session.account-email"
    /** The PIN's salt and hash, and the wrong tries so far (`PinRecord`). */
    case pin = "lock.pin"
    /** The lock's settings (`LockSettings`). */
    case lockSettings = "lock.settings"
}

/** A vault in memory: for tests and previews, never for the app. */
package final class InMemoryVault: SecretVault {
    private let items: OSAllocatedUnfairLock<[VaultKey: Data]>

    /** A vault holding `items`. */
    package init(_ items: [VaultKey: Data] = [:]) {
        self.items = OSAllocatedUnfairLock(initialState: items)
    }

    /** The data stored under `key`. */
    package func data(for key: VaultKey) -> Data? {
        items.withLock { $0[key] }
    }

    /** Stores `data` under `key`. */
    package func set(_ data: Data, for key: VaultKey) {
        items.withLock { $0[key] = data }
    }

    /** Removes the item under `key`. */
    package func remove(_ key: VaultKey) {
        _ = items.withLock { $0.removeValue(forKey: key) }
    }
}
