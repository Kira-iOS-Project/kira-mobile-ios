import Foundation
import Observation

/**
 The app's root (ONB-01 onwards): the splash while Kira starts, then onboarding and sign-in for a
 signed-out person, the lock screen when a PIN is set, and the main shell.
 */
@MainActor @Observable
package final class RootModel {
    /** What the root shows. */
    package enum Stage: Equatable, Sendable {
        /** ONB-01 Splash. */
        case splash
        /** Onboarding and sign-in (ONB-02 to ONB-14). */
        case onboarding
        /** AKN-02 Kira Terkunci. */
        case locked
        /** The tabs. */
        case main
    }

    /** How long the splash shows at least. */
    package static let splashDuration: Duration = .milliseconds(1200)

    /** The main shell's navigation. */
    package let navigation = NavigationModel()
    /** The app lock. */
    package let lock: AppLockModel
    /** The session. */
    package let session: SessionStore

    private var isStarting = true
    private var isSignedIn = false
    @ObservationIgnored private let sleep: @Sendable (Duration) async -> Void

    /** A root over `session` and `lock`; `sleep` waits out the splash. */
    package init(
        session: SessionStore, lock: AppLockModel,
        sleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.session = session
        self.lock = lock
        self.sleep = sleep
    }

    /** What to show now. */
    package var stage: Stage {
        if isStarting { return .splash }
        if !isSignedIn { return .onboarding }
        return lock.isLocked ? .locked : .main
    }

    /** Shows the splash, then routes by the stored session and the lock. */
    package func start() async {
        guard isStarting else { return }
        await sleep(Self.splashDuration)
        isSignedIn = session.hasSession
        if isSignedIn { lock.launch() }
        isStarting = false
    }

    /** Onboarding or sign-in finished with a session: the tabs open on Beranda. */
    package func finishOnboarding() {
        isSignedIn = true
        navigation.reset()
    }

    /** The session ended (sign-out, account deleted, refresh refused): back to onboarding. */
    package func endSession() async {
        await session.signOut()
        lock.reset()
        navigation.reset()
        isSignedIn = false
    }
}
