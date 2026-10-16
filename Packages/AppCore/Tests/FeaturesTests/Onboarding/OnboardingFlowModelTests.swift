import Domain
import Testing

@testable import Features

@MainActor
@Suite("OnboardingFlowModel")
struct OnboardingFlowModelTests {
    private func flow(
        _ service: FakeOnboardingService = FakeOnboardingService(),
        onFinished: @escaping (OnboardingOutcome) -> Void = { _ in }
    ) -> OnboardingFlowModel {
        OnboardingFlowModel(service: service, pinSetup: FakePinSetup(), onFinished: onFinished)
    }

    @Test("a new account goes from its code through consent, focus and six steps to the result and the lock")
    func newAccount() async {
        var outcome: OnboardingOutcome?
        let flow = flow { outcome = $0 }
        flow.open(.signUp)
        flow.showsSignUpEmail = true
        let email = flow.makeEmailModel()
        email.email = "dinda@email.com"
        await email.submit()
        #expect(!flow.showsSignUpEmail)
        let delivery = CodeDelivery(expiresInSeconds: 600, resendAfterSeconds: 60)
        #expect(flow.path == [.signUp, .code(email: "dinda@email.com", delivery: delivery)])
        let code = flow.makeCodeModel(email: "dinda@email.com", delivery: delivery)
        code.code = "381449"
        await code.verify()
        await flow.makeConsentModel().submit()
        let focus = flow.makeFocusModel()
        focus.selection = .debtFree
        await focus.submit()
        #expect(flow.focus == .debtFree)
        #expect(flow.path.suffix(3) == [.consent, .focus, .healthCheck(.income)])
        for step in HealthCheckStep.allCases { flow.next(after: step) }
        #expect(flow.path.last == .healthCheck(.protection))
        let quiz = flow.healthCheckModel()
        #expect(flow.healthCheckModel() === quiz)
        await flow.healthCheckModel().submit()
        #expect(flow.path.last == .result(FakeOnboardingService.report))
        flow.makeResultModel(report: FakeOnboardingService.report).continueToLock()
        #expect(flow.path.last == .pin)
        await flow.makePinModel().skip()
        #expect(outcome == .completed(.debtFree))
    }

    @Test("an account already set up signs in straight to Beranda")
    func signedIn() async {
        var outcome: OnboardingOutcome?
        let flow = flow(FakeOnboardingService(needsOnboarding: false)) { outcome = $0 }
        let code = flow.makeCodeModel(
            email: "a@b.co", delivery: CodeDelivery(expiresInSeconds: 1, resendAfterSeconds: 1))
        code.code = "381449"
        await code.verify()
        #expect(outcome == .signedIn)
        #expect(flow.path.isEmpty)
    }

    @Test("back pops one screen and does nothing on the intro")
    func back() {
        let flow = flow()
        flow.back()
        flow.open(.signIn)
        #expect(flow.signsIn)
        flow.back()
        #expect(!flow.signsIn)
        #expect(flow.path.isEmpty)
    }

    @Test(
        "a flow starts at the intro, or at the screen onboarding resumes at, or at the quiz redone",
        arguments: [
            (OnboardingStart.intro, OnboardingScreen?.none), (.consent, .consent), (.focus, .focus),
            (.healthCheck, .healthCheck(.income)),
        ])
    func start(start: OnboardingStart, root: OnboardingScreen?) {
        let flow = OnboardingFlowModel(service: FakeOnboardingService(), pinSetup: FakePinSetup(), start: start) { _ in
        }
        #expect(flow.start == start && flow.start.rootScreen == root)
        #expect(flow.isRecheck == (start == .healthCheck))
    }

    @Test("after a session ended the flow opens on Masuk over the intro, and back reaches the intro")
    func startsAtSignIn() {
        let flow = OnboardingFlowModel(service: FakeOnboardingService(), pinSetup: FakePinSetup(), start: .signIn) {
            _ in
        }
        #expect(flow.start.rootScreen == nil)
        #expect(flow.path == [.signIn])
        #expect(flow.signsIn)
        flow.back()
        #expect(flow.path.isEmpty)
    }

    @Test("a recheck ends at its result with new answers, and back from its first step closes it")
    func recheck() async {
        var outcomes: [OnboardingOutcome] = []
        let flow = OnboardingFlowModel(
            service: FakeOnboardingService(), pinSetup: FakePinSetup(), start: .healthCheck,
            onFinished: { outcomes.append($0) })
        await flow.healthCheckModel().submit()
        flow.makeResultModel(report: FakeOnboardingService.report).continueToLock()
        #expect(!flow.path.contains(.pin))
        flow.path.removeAll()
        flow.back()
        #expect(outcomes == [.rechecked, .closed])
    }

    @Test("back at the first screen of a resumed onboarding stays there")
    func resumedBack() {
        var outcomes: [OnboardingOutcome] = []
        let flow = OnboardingFlowModel(
            service: FakeOnboardingService(), pinSetup: FakePinSetup(), start: .consent,
            onFinished: { outcomes.append($0) })
        flow.back()
        #expect(outcomes.isEmpty && flow.path.isEmpty)
    }
}
