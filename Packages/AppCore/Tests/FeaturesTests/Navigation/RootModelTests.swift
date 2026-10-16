import Domain
import Foundation
import Testing

@testable import Features

private let tokens = SessionTokens(accessToken: "a", refreshToken: "r", accessExpiresInSeconds: 900)

@MainActor
private func root(signedIn: Bool, pin: Bool, stage: AccountStage? = nil) async throws -> RootModel {
    let vault = InMemoryVault()
    let session = SessionStore(vault: vault) { _ in .rejected }
    if signedIn { try await session.signIn(tokens, email: "dinda@email.com") }
    let pins = PinStore(vault: vault)
    if pin { try pins.setPin("381449") }
    return RootModel(
        session: session, lock: AppLockModel(pins: pins, vault: vault), checkAccount: { stage }, sleep: { _ in })
}

@MainActor
@Suite("RootModel")
struct RootModelTests {
    @Test("shows the splash, then onboarding for a signed-out person, then the tabs")
    func signedOut() async throws {
        let model = try await root(signedIn: false, pin: false)
        #expect(model.stage == .splash)
        await model.start()
        #expect(model.stage == .onboarding)
        #expect(model.onboardingStart == .intro)
        await model.finishOnboarding(.completed(.debtFree))
        #expect(model.stage == .main)
    }

    @Test("opens the tabs for a signed-in person without a PIN, also when GET /me cannot answer")
    func signedIn() async throws {
        let model = try await root(signedIn: true, pin: false)
        await model.start()
        #expect(model.stage == .main)
    }

    @Test("a ready account hands its Sembunyikan Saldo to the lock, which hides amounts at launch")
    func syncsHiddenBalances() async throws {
        let model = try await root(signedIn: true, pin: false, stage: .ready(hidesBalances: true))
        await model.start()
        #expect(model.stage == .main)
        #expect(model.lock.settings.hidesBalancesOnOpen)
        #expect(model.lock.balancesHidden)
    }

    @Test(
        "a signed-in account that never finished onboarding resumes it where it stopped",
        arguments: [(AccountStage.needsConsent, OnboardingStart.consent), (.needsHealthCheck, .focus)])
    func resumes(stage: AccountStage, start: OnboardingStart) async throws {
        let model = try await root(signedIn: true, pin: false, stage: stage)
        await model.start()
        #expect(model.stage == .onboarding)
        #expect(model.onboardingStart == start)
        await model.finishOnboarding(.completed(.trackSpending))
        #expect(model.stage == .main)
        #expect(model.onboardingStart == .intro)
    }

    @Test("signing in to an account set up halfway on another device resumes onboarding instead of the tabs")
    func signedInHalfway() async throws {
        let model = try await root(signedIn: false, pin: false, stage: .needsHealthCheck)
        await model.start()
        await model.finishOnboarding(.signedIn)
        #expect(model.stage == .onboarding)
        #expect(model.onboardingStart == .focus)
    }

    @Test("signing in to an account set up already opens the tabs")
    func signedInReady() async throws {
        let model = try await root(signedIn: false, pin: false, stage: .ready(hidesBalances: false))
        await model.start()
        await model.finishOnboarding(.signedIn)
        #expect(model.stage == .main)
    }

    @Test("locks first when a PIN is set, and opens the tabs with it")
    func locked() async throws {
        let model = try await root(signedIn: true, pin: true)
        await model.start()
        #expect(model.stage == .locked)
        _ = model.lock.unlock(with: "381449")
        #expect(model.stage == .main)
        await model.start()
        #expect(model.stage == .main)
    }

    @Test("ending the session returns to onboarding from the intro, without PIN or session")
    func endSession() async throws {
        let model = try await root(signedIn: true, pin: true)
        await model.start()
        model.navigation.open(.profile)
        await model.endSession()
        #expect(model.stage == .onboarding)
        #expect(model.onboardingStart == .intro)
        #expect(!model.session.hasSession)
        #expect(!model.lock.hasPin)
        #expect(model.navigation.homePath.isEmpty)
    }

    @Test("a refused refresh token returns to onboarding")
    func refusedRefresh() async throws {
        let vault = InMemoryVault()
        let session = SessionStore(vault: vault) { _ in .rejected }
        try await session.signIn(tokens, email: "dinda@email.com")
        let model = RootModel(
            session: session, lock: AppLockModel(pins: PinStore(vault: vault), vault: vault), sleep: { _ in })
        await model.start()
        #expect(model.stage == .main)
        #expect(await session.renewedBearerToken(replacing: "a") == nil)
        #expect(model.stage == .onboarding)
    }

    @Test("waits out the splash by default")
    func defaultSleep() async {
        let vault = InMemoryVault()
        let model = RootModel(
            session: SessionStore(vault: vault) { _ in .rejected },
            lock: AppLockModel(pins: PinStore(vault: vault), vault: vault))
        await model.start()
        #expect(model.stage == .onboarding)
    }
}
