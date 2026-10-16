import CryptoKit
import Domain
import Foundation

/**
 The app lock's PIN, kept on the device only (ONB-14, AKN-02): a random salt and the SHA-256 of
 salt and PIN, in the vault. Five wrong tries in a row pause the lock for 30 seconds; the count and
 the pause are stored too, so quitting the app does not reset them.
 */
package final class PinStore: Sendable {
    /** Wrong tries allowed before the pause. */
    package static let allowedAttempts = 5
    /** How long the lock pauses after the last allowed wrong try. */
    package static let pause: TimeInterval = 30

    private let vault: any SecretVault
    private let now: @Sendable () -> Date
    private let makeSalt: @Sendable () -> Data

    /** A PIN store in `vault`, timed by `now`, salting with `makeSalt` (16 random bytes). */
    package init(
        vault: any SecretVault, now: @escaping @Sendable () -> Date = Date.init,
        makeSalt: @escaping @Sendable () -> Data = { Data(SymmetricKey(size: .bits128).withUnsafeBytes { Data($0) }) }
    ) {
        self.vault = vault
        self.now = now
        self.makeSalt = makeSalt
    }

    /** Whether a PIN is set. */
    package var hasPin: Bool { record() != nil }

    /** Sets `pin`, replacing any PIN, after `PinPolicy` accepts it. */
    package func setPin(_ pin: String) throws(PinProblem) {
        if let problem = PinPolicy.problem(with: pin) { throw problem }
        let salt = makeSalt()
        save(PinRecord(salt: salt, hash: Self.hash(pin, salt: salt), failedAttempts: 0, pausedUntil: nil))
    }

    /** Removes the PIN: Kira opens without one. */
    package func removePin() {
        try? vault.remove(.pin)
    }

    /** The end of the current pause, or nil when the lock takes a PIN now. */
    package func pausedUntil() -> Date? {
        guard let until = record()?.pausedUntil, until > now() else { return nil }
        return until
    }

    /** Checks `pin`, counting a wrong one. Without a PIN set, every PIN is wrong. */
    package func verify(_ pin: String) -> PinCheck {
        guard var record = record() else { return .wrong(remainingAttempts: 0) }
        if let until = pausedUntil() { return .paused(until: until) }
        guard Self.hash(pin, salt: record.salt) != record.hash else {
            record.failedAttempts = 0
            record.pausedUntil = nil
            save(record)
            return .correct
        }
        record.failedAttempts += 1
        let remaining = Self.allowedAttempts - record.failedAttempts
        guard remaining <= 0 else {
            save(record)
            return .wrong(remainingAttempts: remaining)
        }
        let until = now().addingTimeInterval(Self.pause)
        record.failedAttempts = 0
        record.pausedUntil = until
        save(record)
        return .paused(until: until)
    }

    private func record() -> PinRecord? {
        guard let data = try? vault.data(for: .pin) else { return nil }
        return try? JSONDecoder().decode(PinRecord.self, from: data)
    }

    private func save(_ record: PinRecord) {
        guard let data = try? JSONEncoder().encode(record) else { return }
        try? vault.set(data, for: .pin)
    }

    private static func hash(_ pin: String, salt: Data) -> Data {
        Data(SHA256.hash(data: salt + Data(pin.utf8)))
    }
}

/** What checking a PIN found. */
package enum PinCheck: Equatable, Sendable {
    /** The PIN is right. */
    case correct
    /** The PIN is wrong; `remainingAttempts` more tries before the pause. */
    case wrong(remainingAttempts: Int)
    /** Too many wrong tries: the lock takes no PIN until `until`. */
    case paused(until: Date)
}

/** The stored PIN: never the PIN itself. */
struct PinRecord: Codable, Equatable {
    var salt: Data
    var hash: Data
    var failedAttempts: Int
    var pausedUntil: Date?
}
