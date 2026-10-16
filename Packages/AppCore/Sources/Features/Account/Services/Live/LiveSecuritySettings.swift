import Domain

/**
 Keamanan's settings over the app lock (AKN-03): the PIN is checked and kept by `PinStore`,
 hashed on this device and never logged; the auto-lock and the app-switcher blur are the lock's
 settings in the Keychain.
 */
package struct LiveSecuritySettings: SecuritySettings {
    private let lock: AppLockModel
    private let pins: PinStore

    /** Settings of `lock`, whose PIN `pins` keeps. */
    package init(lock: AppLockModel, pins: PinStore) {
        self.lock = lock
        self.pins = pins
    }

    /** The lock's current settings. */
    package func preferences() async -> SecurityPreferences {
        await MainActor.run {
            SecurityPreferences(
                isPinLockEnabled: lock.hasPin, autoLock: AutoLockDelay(lock.settings.autoLock),
                obscuresAppSwitcher: lock.settings.obscuresInAppSwitcher)
        }
    }

    /** Whether `pin` is the PIN; a wrong one counts towards the pause, as on the lock screen. */
    package func verifyPin(_ pin: String) -> Bool {
        pins.verify(pin) == .correct
    }

    /** Sets `pin` and turns the lock on; a PIN `PinPolicy` refuses throws its `PinProblem`. */
    package func setPin(_ pin: String) async throws {
        try await MainActor.run { try lock.setPin(pin) }
    }

    /** Forgets the PIN: Kira opens without one. */
    package func disablePinLock() async {
        await MainActor.run { lock.forgetPin() }
    }

    /** Kunci Otomatis. */
    package func setAutoLock(_ delay: AutoLockDelay) async {
        await MainActor.run { lock.update { $0.autoLock = AutoLock(delay) } }
    }

    /** Samarkan di Pengalih Aplikasi. */
    package func setObscuresAppSwitcher(_ isOn: Bool) async {
        await MainActor.run { lock.update { $0.obscuresInAppSwitcher = isOn } }
    }

    /** The PIN and the lock's settings go with the account. */
    package func clearLocalData() async {
        await MainActor.run { lock.reset() }
    }
}

extension AutoLockDelay {
    /** The delay the lock keeps as `autoLock`. */
    init(_ autoLock: AutoLock) {
        switch autoLock {
        case .immediately: self = .immediately
        case .oneMinute: self = .oneMinute
        case .fiveMinutes: self = .fiveMinutes
        }
    }
}

extension AutoLock {
    /** The lock's setting for `delay`. */
    init(_ delay: AutoLockDelay) {
        switch delay {
        case .immediately: self = .immediately
        case .oneMinute: self = .oneMinute
        case .fiveMinutes: self = .fiveMinutes
        }
    }
}

/** Onboarding's PIN (ONB-14) set through the app lock, which then guards Kira. */
package struct LockPinSetup: PinSetup {
    private let lock: AppLockModel

    /** Sets the PIN of `lock`. */
    package init(lock: AppLockModel) {
        self.lock = lock
    }

    /** Sets `pin`; a PIN `PinPolicy` refuses throws its `PinProblem`. */
    package func save(pin: String) async throws {
        try await MainActor.run { try lock.setPin(pin) }
    }
}
