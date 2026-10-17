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

    /** Where onboarding starts: the intro, Masuk after a session ended, or where an account left it. */
    package private(set) var onboardingStart = OnboardingStart.intro {
        didSet { onboardingGeneration += 1 }
    }
    /**
     Changes whenever onboarding must start over (a new start, or a session that ended), so the root
     builds a fresh flow instead of keeping one whose session is gone.
     */
    package private(set) var onboardingGeneration = 0
    private var isStarting = true
    private var isSignedIn = false
    @ObservationIgnored private let sleep: @Sendable (Duration) async -> Void
    @ObservationIgnored private let checkAccount: @Sendable () async -> AccountStage?
    @ObservationIgnored private let forgetUser: @MainActor () -> Void

    /** A root over `session` and `lock`; `sleep` waits out the splash. */
    /**
     A root over `session` and `lock`; `checkAccount` reads `GET /me` (nil when the API is out of
     reach); `sleep` waits out the splash; `forgetUser` drops what the app holds in memory for the
     person (the risk quiz's draft answers) when the session ends.
     */
    package init(
        session: SessionStore, lock: AppLockModel,
        checkAccount: @escaping @Sendable () async -> AccountStage? = { nil },
        sleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) },
        forgetUser: @escaping @MainActor () -> Void = {}
    ) {
        self.session = session
        self.lock = lock
        self.checkAccount = checkAccount
        self.sleep = sleep
        self.forgetUser = forgetUser
    }

    /** What to show now. */
    package var stage: Stage {
        if isStarting { return .splash }
        if !isSignedIn { return .onboarding }
        return lock.isLocked ? .locked : .main
    }

    /**
     Shows the splash, then routes by the stored session and the lock. From then on, a refresh
     token the API refuses ends the session here.
     */
    package func start() async {
        guard isStarting else { return }
        await session.setSessionEndedHandler { [weak self] in await self?.endSession(to: .signIn) }
        await sleep(Self.splashDuration)
        if session.hasSession {
            let stage = await checkAccount()
            /** A refresh refused during the check has ended the session: stay signed out. */
            isSignedIn = session.hasSession && apply(stage)
            if isSignedIn { lock.launch() }
        }
        isStarting = false
    }

    /**
     Onboarding or sign-in finished with a session: the tabs open on Beranda. An account that
     signed in without finishing onboarding on another device resumes it instead.
     */
    package func finishOnboarding(_ outcome: OnboardingOutcome) async {
        if outcome == .signedIn, !apply(await checkAccount()) { return }
        guard session.hasSession else { return }
        isSignedIn = true
        onboardingStart = .intro
        navigation.reset()
    }

    /**
     Follows what `GET /me` said: where onboarding resumes, or the account's "Sembunyikan Saldo"
     for the lock. True when the tabs may open, also when the API was out of reach.
     */
    private func apply(_ stage: AccountStage?) -> Bool {
        switch stage {
        case .needsConsent:
            onboardingStart = .consent
            return false
        case .needsHealthCheck:
            onboardingStart = .focus
            return false
        case .ready(let hidesBalances):
            lock.update { $0.hidesBalancesOnOpen = hidesBalances }
            return true
        case nil:
            return true
        }
    }

    /**
     The session ended: back to onboarding, at the intro after Keluar or a deleted account, at Masuk
     when the API refused the refresh token.
     */
    package func endSession(to start: OnboardingStart = .intro) async {
        await session.signOut()
        lock.reset()
        navigation.reset()
        forgetUser()
        onboardingStart = start
        isSignedIn = false
    }
}
