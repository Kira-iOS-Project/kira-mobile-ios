import Domain
import Testing

@testable import Features

@MainActor
@Suite("CodeVerificationModel")
struct CodeVerificationModelTests {
    private func model(
        _ service: FakeOnboardingService, resendAfter: Int = 3, onVerified: @escaping (SignInResult) -> Void = { _ in }
    ) -> CodeVerificationModel {
        CodeVerificationModel(
            email: "dinda@email.com", delivery: CodeDelivery(resendAfterSeconds: resendAfter),
            service: service, sleep: { _ in }, onVerified: onVerified)
    }

    @Test("counts down from resendAfterSeconds to 0")
    func countdown() async {
        let model = model(FakeOnboardingService())
        #expect(model.secondsUntilResend == 3)
        await model.runCountdown()
        #expect(model.secondsUntilResend == 0)
    }

    @Test("a cancelled countdown stops where it is, with the real clock")
    func cancelled() async {
        let model = CodeVerificationModel(
            email: "a@b.co", delivery: CodeDelivery(resendAfterSeconds: 60),
            service: FakeOnboardingService()
        ) { _ in }
        let task = Task { await model.runCountdown() }
        task.cancel()
        await task.value
        #expect(model.secondsUntilResend == 60)
    }

    @Test("the sixth digit verifies at once and hands on the result")
    func autoVerify() async {
        let service = FakeOnboardingService(needsOnboarding: false)
        var result: SignInResult?
        let model = model(service) { result = $0 }
        model.code = "38144"
        await model.verifyIfComplete()
        model.code = "Kode: 381 449"
        await model.verifyIfComplete()
        #expect(await service.calls.isEmpty)
        model.code = "381449"
        await model.verifyIfComplete()
        #expect(await service.calls == [.verify("dinda@email.com", "381449")])
        #expect(result == SignInResult(needsOnboarding: false))
        #expect(model.phase == .editing)
    }

    @Test("a wrong code empties the boxes and shows the problem until a digit is typed")
    func wrongCode() async {
        let model = model(FakeOnboardingService(failures: 1)) { _ in Issue.record("verified") }
        model.code = "000000"
        await model.verify()
        #expect(model.code.isEmpty)
        #expect(model.phase == .failed(FakeOnboardingService.problem))
        model.code = "1"
        #expect(model.phase == .editing)
    }

    @Test("resend waits for the countdown, then sends a new code and starts it again")
    func resend() async {
        let service = FakeOnboardingService(resendAfter: 60)
        let model = model(service)
        await model.resend()
        #expect(await service.calls.isEmpty)
        await model.runCountdown()
        model.code = "12"
        await model.resend()
        #expect(await service.calls == [.requestCode("dinda@email.com")])
        #expect(model.code.isEmpty)
        #expect(model.secondsUntilResend == 60)
        #expect(model.countdownRun == 1)
    }

    @Test("a refused resend keeps the countdown at 0 and shows the problem")
    func resendFails() async {
        let model = model(FakeOnboardingService(failures: 1), resendAfter: 0)
        await model.resend()
        #expect(model.phase == .failed(FakeOnboardingService.problem))
        #expect(model.secondsUntilResend == 0)
    }
}
