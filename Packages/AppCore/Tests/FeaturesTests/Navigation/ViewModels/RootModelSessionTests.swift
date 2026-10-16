import Domain
import Foundation
import Testing

@testable import Features

/** How the root behaves when a session ends under it: at launch, mid-onboarding, again and again. */
@MainActor
@Suite("RootModel session end")
struct RootModelSessionTests {
    @Test("a session the API refuses at launch stays signed out, on Masuk, instead of opening the tabs")
    func expiredAtLaunch() async throws {
        let vault = InMemoryVault()
        let session = SessionStore(vault: vault) { _ in .rejected }
        try await session.signIn(rootTokens, email: "dinda@email.com")
        let model = RootModel(
            session: session, lock: AppLockModel(pins: PinStore(vault: vault), vault: vault),
            checkAccount: {
                _ = await session.renewedBearerToken(replacing: "a")
                return nil
            },
            sleep: { _ in })

        await model.start()

        #expect(model.stage == .onboarding)
        #expect(model.onboardingStart == .signIn)
        #expect(!session.hasSession)
    }

    @Test("finishing onboarding after the session ended stays in onboarding")
    func finishWithoutSession() async throws {
        let model = try await root(signedIn: false, pin: false, stage: .ready(hidesBalances: false))
        await model.start()
        await model.finishOnboarding(.signedIn)
        #expect(model.stage == .onboarding)
    }

    @Test("every ended session starts onboarding over, even from the same screen")
    func freshFlowAfterEveryEnd() async throws {
        let model = try await root(signedIn: true, pin: false)
        await model.start()
        let first = model.onboardingGeneration
        await model.endSession(to: .signIn)
        let second = model.onboardingGeneration
        await model.endSession(to: .signIn)
        #expect(second > first)
        #expect(model.onboardingGeneration > second)
        #expect(model.onboardingStart == .signIn)
    }
}
