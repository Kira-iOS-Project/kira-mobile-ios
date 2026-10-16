/**
 The app lock and privacy settings kept on this device only (AKN-03): whether the PIN locks Kira,
 how soon it locks after leaving, and whether the app switcher shows a blurred screen. The PIN
 itself never leaves the device and is never part of this value.
 */
package struct SecurityPreferences: Equatable, Sendable {
    /** Kunci dengan PIN: Kira asks for the PIN when it opens. */
    package let isPinLockEnabled: Bool
    /** Kunci Otomatis. */
    package let autoLock: AutoLockDelay
    /** Samarkan di Pengalih Aplikasi. */
    package let obscuresAppSwitcher: Bool

    /** Settings with every value given. */
    package init(isPinLockEnabled: Bool, autoLock: AutoLockDelay, obscuresAppSwitcher: Bool) {
        self.isPinLockEnabled = isPinLockEnabled
        self.autoLock = autoLock
        self.obscuresAppSwitcher = obscuresAppSwitcher
    }
}

/** How long Kira may stay in the background before it asks for the PIN again. */
package enum AutoLockDelay: String, CaseIterable, Codable, Sendable {
    /** Segera: as soon as Kira leaves the screen. */
    case immediately
    /** After 1 minute away. */
    case oneMinute
    /** After 5 minutes away. */
    case fiveMinutes

    /** The delay in seconds: 0, 60 or 300. */
    package var seconds: Int {
        switch self {
        case .immediately: 0
        case .oneMinute: 60
        case .fiveMinutes: 300
        }
    }
}
