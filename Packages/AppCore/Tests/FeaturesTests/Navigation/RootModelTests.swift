import Foundation
import Testing

@testable import Features

private let tokens = SessionTokens(accessToken: "a", refreshToken: "r", accessExpiresInSeconds: 900)

@MainActor
private func root(signedIn: Bool, pin: Bool) async throws -> RootModel {
    let vault = InMemoryVault()
    let session = SessionStore(vault: vault) { _ in .rejected }
    if signedIn { try await session.signIn(tokens, email: "dinda@email.com") }
    let pins = PinStore(vault: vault)
    if pin { try pins.setPin("381449") }
    return RootModel(session: session, lock: AppLockModel(pins: pins, vault: vault)) { _ in }
}

@MainActor
@Suite("RootModel")
struct RootModelTests {
    @Test("shows the splash, then onboarding for a signed-out person")
    func signedOut() async throws {
        let model = try await root(signedIn: false, pin: false)
        #expect(model.stage == .splash)
        await model.start()
        #expect(model.stage == .onboarding)
        model.finishOnboarding()
        #expect(model.stage == .main)
    }

    @Test("opens the tabs for a signed-in person without a PIN")
    func signedIn() async throws {
        let model = try await root(signedIn: true, pin: false)
        await model.start()
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

    @Test("ending the session returns to onboarding without PIN or session")
    func endSession() async throws {
        let model = try await root(signedIn: true, pin: true)
        await model.start()
        model.navigation.open(.profile)
        await model.endSession()
        #expect(model.stage == .onboarding)
        #expect(!model.session.hasSession)
        #expect(!model.lock.hasPin)
        #expect(model.navigation.homePath.isEmpty)
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
