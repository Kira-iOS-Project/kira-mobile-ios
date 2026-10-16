import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** The auth API's two calls, answering with what the test set. */
private struct RecoveryAPI: PinRecoveryService {
    var sendError: (any Error)?
    var verifyError: (any Error)?

    func sendCode(to _: String) throws -> Int {
        if let sendError { throw sendError }
        return 60
    }

    func verify(code: String, email _: String) throws -> SessionTokens {
        if let verifyError { throw verifyError }
        return SessionTokens(accessToken: "a", refreshToken: "r-\(code)", accessExpiresInSeconds: 900)
    }
}

private let invalid = AppProblem(code: "AUTH_CODE_INVALID")

/** The model under test with the session and the lock it changes. */
@MainActor
private struct Harness {
    let model: PinRecoveryModel
    let session: SessionStore
    let lock: AppLockModel

    init(_ api: RecoveryAPI = RecoveryAPI(), clock: TestClock = TestClock()) {
        let vault = InMemoryVault()
        session = SessionStore(vault: vault, now: clock.now) { _ in .rejected }
        lock = AppLockModel(pins: PinStore(vault: vault, now: clock.now), vault: vault, now: clock.now)
        model = PinRecoveryModel(email: "dinda@email.com", service: api, session: session, lock: lock, now: clock.now)
    }
}

@MainActor
@Suite("PinRecoveryModel")
struct PinRecoveryModelTests {
    @Test("sends the code and counts down to the next send")
    func sendsCode() async {
        let clock = TestClock()
        let model = Harness(clock: clock).model
        #expect(model.phase == .sending)
        #expect(model.secondsUntilResend(at: clock.now()) == 0)
        await model.sendCode()
        #expect(model.phase == .enteringCode)
        #expect(model.email == "dinda@email.com")
        #expect(model.secondsUntilResend(at: clock.now().addingTimeInterval(17.5)) == 43)
        #expect(model.secondsUntilResend(at: clock.now().addingTimeInterval(90)) == 0)
    }

    @Test("shows the API's problem, or the generic one for any other failure")
    func sendFails() async {
        let model = Harness(RecoveryAPI(sendError: invalid)).model
        await model.sendCode()
        #expect(model.problem == invalid)
        let other = Harness(RecoveryAPI(sendError: URLError(.timedOut))).model
        await other.sendCode()
        #expect(other.problem == AppProblem())
        #expect(other.phase == .enteringCode)
    }

    @Test("keeps only six digits of what is typed or pasted")
    func digitsOnly() {
        let model = Harness().model
        model.code = "Kode kamu: 381 449 7"
        model.newPin = "90-27-16"
        #expect(model.code == "381449")
        #expect(model.newPin == "902716")
    }

    @Test("the right code renews the session, then the new PIN opens Kira")
    func recovers() async {
        let harness = Harness()
        let model = harness.model
        let session = harness.session
        let lock = harness.lock
        await model.verifyCode()
        #expect(model.phase == .sending)
        await model.sendCode()
        model.savePin()
        model.code = "381449"
        await model.verifyCode()
        #expect(model.phase == .choosingPin)
        #expect(session.hasSession)
        #expect(await session.bearerToken() == "a")
        model.newPin = "111111"
        model.savePin()
        #expect(model.pinProblem == .tooSimple)
        #expect(model.newPin.isEmpty)
        model.newPin = "902716"
        model.savePin()
        #expect(model.phase == .finished)
        #expect(model.pinProblem == nil)
        #expect(lock.hasPin)
        #expect(!lock.isLocked)
    }

    @Test("a wrong code clears the boxes and shows the problem")
    func wrongCode() async {
        let harness = Harness(RecoveryAPI(verifyError: invalid))
        let model = harness.model
        let session = harness.session
        await model.sendCode()
        model.code = "381449"
        await model.verifyCode()
        #expect(model.phase == .enteringCode)
        #expect(model.problem == invalid)
        #expect(model.code.isEmpty)
        #expect(!session.hasSession)
    }

    @Test("reads the clock by default")
    func defaultClock() async {
        let vault = InMemoryVault()
        let model = PinRecoveryModel(
            email: "dinda@email.com", service: RecoveryAPI(), session: SessionStore(vault: vault) { _ in .rejected },
            lock: AppLockModel(pins: PinStore(vault: vault), vault: vault))
        await model.sendCode()
        #expect(model.secondsUntilResend(at: .distantPast) > 0)
    }
}
