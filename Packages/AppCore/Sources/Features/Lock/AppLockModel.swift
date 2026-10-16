import Domain
import Foundation
import Observation

/**
 The app lock (AKN-02, AKN-03): whether Kira is locked, its settings, whether amounts are hidden
 and whether the app switcher sees a blurred screen. With a PIN set, Kira locks at launch and when
 it returns from the background after the Kunci Otomatis interval. Amounts start hidden on every
 open when "Sembunyikan Saldo saat Membuka" is on, until the eye is tapped.
 */
@MainActor @Observable
package final class AppLockModel {
    /** Whether the lock screen covers Kira. */
    package private(set) var isLocked = false
    /** Whether a PIN is set. */
    package private(set) var hasPin: Bool
    /** The lock's settings. */
    package private(set) var settings: LockSettings
    /** Whether amounts show as Rp•••••• now. */
    package private(set) var balancesHidden: Bool
    /** Whether Kira is in the app switcher with the blur setting on. */
    package private(set) var isObscured = false

    @ObservationIgnored private let pins: PinStore
    @ObservationIgnored private let vault: any SecretVault
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private var backgroundedAt: Date?

    /** The lock of the PIN in `pins` and the settings in `vault`, timed by `now`. */
    package init(pins: PinStore, vault: any SecretVault, now: @escaping @Sendable () -> Date = Date.init) {
        self.pins = pins
        self.vault = vault
        self.now = now
        let stored = (try? vault.data(for: .lockSettings))
            .flatMap { try? JSONDecoder().decode(LockSettings.self, from: $0) }
        settings = stored ?? LockSettings()
        hasPin = pins.hasPin
        balancesHidden = (stored ?? LockSettings()).hidesBalancesOnOpen
    }

    /** Kira opens: locked when a PIN is set, amounts hidden when the setting says so. */
    package func launch() {
        isLocked = hasPin
        balancesHidden = settings.hidesBalancesOnOpen
    }

    /** Follows the scene: blurs in the app switcher, and locks after the auto-lock interval. */
    package func scenePresenceChanged(to presence: ScenePresence) {
        isObscured = presence != .active && settings.obscuresInAppSwitcher
        switch presence {
        case .background:
            if backgroundedAt == nil { backgroundedAt = now() }
        case .active:
            guard let since = backgroundedAt else { return }
            backgroundedAt = nil
            if hasPin, now().timeIntervalSince(since) >= settings.autoLock.interval { launch() }
        case .inactive:
            break
        }
    }

    /** Checks `pin` on the lock screen; the right one opens Kira. */
    package func unlock(with pin: String) -> PinCheck {
        let check = pins.verify(pin)
        if check == .correct { isLocked = false }
        return check
    }

    /** The end of the current wrong-PIN pause, or nil. */
    package func pausedUntil() -> Date? { pins.pausedUntil() }

    /** Sets a new PIN (ONB-14, Ganti PIN, Lupa PIN) and opens Kira. */
    package func setPin(_ pin: String) throws(PinProblem) {
        try pins.setPin(pin)
        hasPin = true
        isLocked = false
    }

    /** Turns the PIN off after checking it (AKN-03: turning the lock off asks for the PIN). */
    package func removePin(confirmingWith pin: String) -> PinCheck {
        let check = pins.verify(pin)
        if check == .correct {
            pins.removePin()
            hasPin = false
        }
        return check
    }

    /** Shows or hides amounts until the next open (the eye on Beranda). */
    package func toggleBalances() { balancesHidden.toggle() }

    /** Changes the settings and keeps them. */
    package func update(_ change: (inout LockSettings) -> Void) {
        change(&settings)
        if let data = try? JSONEncoder().encode(settings) { try? vault.set(data, for: .lockSettings) }
    }

    /** Signing out: the PIN and the settings belong to the account, so both go. */
    package func reset() {
        pins.removePin()
        try? vault.remove(.lockSettings)
        settings = LockSettings()
        hasPin = false
        isLocked = false
        balancesHidden = false
    }
}
