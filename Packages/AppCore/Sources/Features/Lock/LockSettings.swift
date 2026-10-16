import Foundation

/** The lock's settings (AKN-03 Keamanan, ONB-14), kept in the vault. */
package struct LockSettings: Codable, Equatable, Sendable {
    /** How long Kira may stay in the background before it asks for the PIN again. */
    package var autoLock: AutoLock = .immediately
    /** Whether amounts start hidden (Rp••••••) each time Kira opens. */
    package var hidesBalancesOnOpen = false
    /** Whether the app switcher shows Kira blurred. */
    package var obscuresInAppSwitcher = true

    /** The defaults: lock at once, balances shown, blurred in the app switcher. */
    package init() {}
}

/** Kunci Otomatis: Segera, 1 menit, 5 menit. */
package enum AutoLock: String, CaseIterable, Codable, Sendable {
    case immediately
    case oneMinute
    case fiveMinutes

    /** The time in the background after which Kira locks. */
    package var interval: TimeInterval {
        switch self {
        case .immediately: 0
        case .oneMinute: 60
        case .fiveMinutes: 300
        }
    }
}

/** Where the app's scene is, as the app reports it from SwiftUI's scene phase. */
package enum ScenePresence: Sendable {
    case active
    case inactive
    case background
}
