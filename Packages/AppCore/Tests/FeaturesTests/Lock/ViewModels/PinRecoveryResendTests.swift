import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** An auth API whose code request waits until the test lets it answer, counting the requests. */
private actor HeldCodeAPI: PinRecoveryService {
    private(set) var sends = 0
    private var held: [CheckedContinuation<Void, Never>] = []

    func sendCode(to _: String) async -> Int {
        sends += 1
        await withCheckedContinuation { held.append($0) }
        return 60
    }

    func verify(code _: String, email _: String) -> SessionTokens {
        SessionTokens(accessToken: "a", refreshToken: "r", accessExpiresInSeconds: 900)
    }

    /** Answers every request that is waiting. */
    func answer() {
        for request in held { request.resume() }
        held = []
    }
}

@MainActor
@Suite("PinRecoveryModel resend")
struct PinRecoveryResendTests {
    private func model(_ api: some PinRecoveryService, clock: TestClock) -> PinRecoveryModel {
        let vault = InMemoryVault()
        let session = SessionStore(vault: vault, now: clock.now) { _ in .rejected }
        let lock = AppLockModel(pins: PinStore(vault: vault, now: clock.now), vault: vault, now: clock.now)
        return PinRecoveryModel(email: "dinda@email.com", service: api, session: session, lock: lock, now: clock.now)
    }

    @Test("Kirim Ulang Kode tapped while the first code is on its way sends nothing more")
    func onceInFlight() async {
        let api = HeldCodeAPI()
        let model = model(api, clock: TestClock())
        let first = Task { await model.start() }
        while await api.sends == 0 { await Task.yield() }
        await model.sendCode()
        #expect(await api.sends == 1)
        await api.answer()
        await first.value
        #expect(model.phase == .enteringCode)
        #expect(model.problem == nil)
    }

    @Test("no second code before the API's wait has passed; one after it")
    func waitsForTheCooldown() async {
        let api = HeldCodeAPI()
        let clock = TestClock()
        let model = model(api, clock: clock)
        async let first: Void = model.start()
        while await api.sends == 0 { await Task.yield() }
        await api.answer()
        await first
        clock.advance(30)
        await model.sendCode()
        #expect(await api.sends == 1)
        clock.advance(30)
        async let again: Void = model.sendCode()
        while await api.sends == 1 { await Task.yield() }
        await api.answer()
        await again
        #expect(await api.sends == 2)
    }
}
