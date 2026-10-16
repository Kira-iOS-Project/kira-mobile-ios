import Domain
import Testing

@testable import Features

@MainActor
@Suite("EmailEntryModel")
struct EmailEntryModelTests {
    @Test("a malformed email is refused without a request, until it is edited")
    func invalid() async {
        let service = FakeOnboardingService()
        let model = EmailEntryModel(email: "dinda@", service: service) { _, _ in Issue.record("sent") }
        await model.submit()
        #expect(model.showsInvalidEmail)
        #expect(await service.calls.isEmpty)
        model.email = "dinda@email.com"
        #expect(!model.showsInvalidEmail)
        model.email = "dinda@email.co"
        #expect(!model.showsInvalidEmail)
    }

    @Test("a valid email asks for a code with the normalized address and hands on the delivery")
    func sends() async {
        let service = FakeOnboardingService(resendAfter: 42)
        var sent: (String, CodeDelivery)?
        let model = EmailEntryModel(email: " Dinda@Email.com ", service: service) { sent = ($0, $1) }
        await model.submit()
        #expect(await service.calls == [.requestCode("dinda@email.com")])
        #expect(sent?.0 == "dinda@email.com")
        #expect(sent?.1.resendAfterSeconds == 42)
        #expect(model.phase == .editing)
    }

    @Test("a refusal shows the API's problem and nothing is handed on")
    func fails() async {
        let service = FakeOnboardingService(failures: 1)
        let model = EmailEntryModel(email: "dinda@email.com", service: service) { _, _ in Issue.record("sent") }
        await model.submit()
        #expect(model.phase == .failed(FakeOnboardingService.problem))
    }
}
