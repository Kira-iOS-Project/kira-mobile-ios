/**
 The entry of Masuk & Onboarding: the intro pages, then whatever the flow pushes (Buat Akun or
 Masuk, the code, and for a new account consent, focus, the six health-check steps, the result and
 Kunci Kira). `onFinished` tells the root which Beranda to open; `onOpen` opens the Terms and the
 Privacy Policy. The root shows SplashView while it restores a session, before this.
 */
import Features
import SwiftUI

struct OnboardingFlow: View {
    @State private var flow: OnboardingFlowModel
    private let onOpen: (AppRoute) -> Void

    init(
        service: any OnboardingService, pinSetup: any PinSetup, start: OnboardingStart = .intro,
        onFinished: @escaping (OnboardingOutcome) -> Void, onOpen: @escaping (AppRoute) -> Void = { _ in }
    ) {
        _flow = State(
            initialValue: OnboardingFlowModel(
                service: service, pinSetup: pinSetup, start: start, onFinished: onFinished))
        self.onOpen = onOpen
    }

    var body: some View {
        NavigationStack(path: $flow.path) {
            root.navigationDestination(for: OnboardingScreen.self) { screen in destination(screen) }
        }
    }

    /** The intro pages, or the screen onboarding resumes at (or the quiz's first step, redone). */
    @ViewBuilder private var root: some View {
        if let screen = flow.start.rootScreen {
            destination(screen)
        } else {
            IntroView(flow: flow)
        }
    }

    @ViewBuilder private func destination(_ screen: OnboardingScreen) -> some View {
        switch screen {
        case .signUp: SignUpView(flow: flow, onOpen: onOpen)
        case .signIn: SignInView(flow: flow)
        case .code(let email, let delivery):
            CodeVerificationView(flow: flow, model: flow.makeCodeModel(email: email, delivery: delivery))
        case .consent: ConsentView(flow: flow, onOpen: onOpen)
        case .focus: FocusView(flow: flow)
        case .healthCheck(let step): healthCheck(step)
        case .result(let report): HealthCheckResultView(flow: flow, report: report)
        case .pin: PinSetupView(flow: flow)
        }
    }

    @ViewBuilder private func healthCheck(_ step: HealthCheckStep) -> some View {
        switch step {
        case .debts: DebtStepView(flow: flow, model: flow.healthCheckModel())
        case .protection: ProtectionStepView(flow: flow, model: flow.healthCheckModel())
        case .income, .expenses, .savings, .assets:
            AmountStepView(step: step, flow: flow, model: flow.healthCheckModel())
        }
    }
}

#if DEBUG
    #Preview {
        OnboardingFlow(service: PreviewOnboardingService(), pinSetup: PreviewPinSetup()) { _ in }
    }
#endif
