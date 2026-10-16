/**
 The app lock and privacy settings kept on this device only (AKN-03): whether the PIN locks Kira,
 how soon it locks after leaving, and whether the app switcher shows a blurred screen. The PIN
 itself never leaves the device and is never part of this value.
 */
package struct SecurityPreferences: Equatable, Sendable {
    package let isPinLockEnabled: Bool
    package let autoLock: AutoLockDelay
    package let obscuresAppSwitcher: Bool

    package init(isPinLockEnabled: Bool, autoLock: AutoLockDelay, obscuresAppSwitcher: Bool) {
        self.isPinLockEnabled = isPinLockEnabled
        self.autoLock = autoLock
        self.obscuresAppSwitcher = obscuresAppSwitcher
    }
}

/** How long Kira may stay in the background before it asks for the PIN again. */
package enum AutoLockDelay: String, CaseIterable, Codable, Sendable {
    case immediately
    case oneMinute
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
