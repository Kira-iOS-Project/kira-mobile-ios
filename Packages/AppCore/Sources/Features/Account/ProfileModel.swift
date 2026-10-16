import APIClient
import Domain
import Observation

/**
 Profil (AKN-01): the account, its plan and AI quota, whether the PIN lock is on, and signing out
 (Keluar asks first, then ends the session and clears what the device keeps).
 */
@MainActor
@Observable
package final class ProfileModel {
    package private(set) var phase: ScreenPhase<AccountProfile> = .loading
    package private(set) var isPinLockEnabled = false
    /** The Keluar sheet is up. */
    package var isConfirmingSignOut = false
    package private(set) var isSigningOut = false
    private let service: any AccountService
    private let settings: any SecuritySettings
    private let onSignedOut: @MainActor () -> Void

    package init(
        service: any AccountService, settings: any SecuritySettings, onSignedOut: @escaping @MainActor () -> Void
    ) {
        self.service = service
        self.settings = settings
        self.onSignedOut = onSignedOut
    }

    /** Loads the account, and again each time the screen comes back, keeping what it shows meanwhile. */
    package func load() async {
        isPinLockEnabled = await settings.preferences().isPinLockEnabled
        do {
            phase = .loaded(try await service.profile())
        } catch {
            if phase.value == nil { phase = .failed(accountProblem(error)) }
        }
    }

    /** Keluar: asks for confirmation first. */
    package func askToSignOut() {
        isConfirmingSignOut = true
    }

    /**
     Ends the session on the server, clears the device and leaves. The device signs out even when
     the server cannot be reached: the person asked to leave, and the refresh token expires anyway.
     */
    package func signOut() async {
        isSigningOut = true
        do {
            try await service.signOut()
        } catch {
            /** error ignored: signing out on this device must not depend on the network */
        }
        await settings.clearLocalData()
        isSigningOut = false
        isConfirmingSignOut = false
        onSignedOut()
    }
}
