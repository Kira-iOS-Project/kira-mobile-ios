import Domain
import Testing

@testable import Features

/** The email sheet of Buat Akun, which the flow owns so its address outlives the sheet. */
@MainActor
@Suite("OnboardingFlowModel sign-up sheet")
struct SignUpEmailSheetTests {
    @Test("a failed send closes the sheet for its dialog; Coba Lagi reopens it on the same address and sends")
    func signUpEmailFailure() async {
        let service = FakeOnboardingService(failures: 1)
        let flow = OnboardingFlowModel(service: service, pinSetup: FakePinSetup()) { _ in }
        flow.open(.signUp)
        flow.openSignUpEmail()
        let email = flow.signUpEmailModel()
        email.email = "dinda@email.com"
        await email.submit()
        #expect(!flow.signUpEmail.isOpen)
        #expect(flow.signUpEmail.failure == FakeOnboardingService.problem)
        #expect(email.phase == .editing)
        #expect(flow.path == [.signUp])
        await flow.retrySignUpEmail()
        #expect(flow.signUpEmail.failure == nil && !flow.signUpEmail.isOpen)
        #expect(flow.signUpEmailModel().email == "dinda@email.com")
        #expect(await service.calls == [.requestCode("dinda@email.com"), .requestCode("dinda@email.com")])
        #expect(flow.path == [.signUp])
        flow.signUpSheetGone()
        let delivery = CodeDelivery(resendAfterSeconds: 60)
        #expect(flow.path == [.signUp, .code(email: "dinda@email.com", delivery: delivery)])
    }

    @Test("a send that goes through waits for the sheet's covers, then pushes the code screen exactly once")
    func codeWaitsForTheSheet() async {
        let flow = OnboardingFlowModel(service: FakeOnboardingService(failures: 2), pinSetup: FakePinSetup()) { _ in }
        flow.open(.signUp)
        flow.openSignUpEmail()
        flow.signUpEmailModel().email = "dinda@email.com"
        await flow.signUpEmailModel().submit()
        flow.signUpSheetGone()
        await flow.retrySignUpEmail()
        #expect(flow.signUpEmail.failure != nil && flow.path == [.signUp])
        flow.signUpSheetGone()
        await flow.retrySignUpEmail()
        #expect(!flow.signUpEmail.isOpen && flow.signUpEmail.failure == nil)
        #expect(flow.path == [.signUp])
        flow.signUpSheetGone()
        flow.signUpSheetGone()
        let code = OnboardingScreen.code(email: "dinda@email.com", delivery: CodeDelivery(resendAfterSeconds: 60))
        #expect(flow.path == [.signUp, code])
    }

    @Test("a send that answers after the sheet was closed and is gone pushes the code screen at once")
    func lateAnswerAfterTheSheetIsGone() async {
        let flow = OnboardingFlowModel(service: FakeOnboardingService(), pinSetup: FakePinSetup()) { _ in }
        flow.open(.signUp)
        flow.openSignUpEmail()
        flow.signUpEmail.close()
        flow.signUpSheetGone()
        flow.signUpEmailModel().email = "dinda@email.com"
        await flow.signUpEmailModel().submit()
        #expect(flow.path.last == .code(email: "dinda@email.com", delivery: CodeDelivery(resendAfterSeconds: 60)))
        #expect(flow.path.count == 2)
    }

    @Test("an invalid address stays inline in the open sheet")
    func signUpEmailInvalid() async {
        let service = FakeOnboardingService()
        let flow = OnboardingFlowModel(service: service, pinSetup: FakePinSetup()) { _ in }
        flow.openSignUpEmail()
        let email = flow.signUpEmailModel()
        email.email = "dinda@"
        await email.submit()
        #expect(flow.signUpEmail.isOpen && flow.signUpEmail.failure == nil)
        #expect(email.showsInvalidEmail)
        #expect(await service.calls.isEmpty)
    }

    @Test("Masuk is a page: its failure stays inline and opens no sheet")
    func signInFailureInline() async {
        let flow = OnboardingFlowModel(service: FakeOnboardingService(failures: 1), pinSetup: FakePinSetup()) { _ in }
        flow.open(.signIn)
        let email = flow.makeEmailModel()
        email.email = "dinda@email.com"
        await email.submit()
        #expect(email.phase == .failed(FakeOnboardingService.problem))
        #expect(!flow.signUpEmail.isOpen && flow.signUpEmail.failure == nil)
        await email.submit()
        #expect(flow.path.last == .code(email: "dinda@email.com", delivery: CodeDelivery(resendAfterSeconds: 60)))
    }
}
