/**
 Masuk (ONB-06): Kuku welcomes the person back; the code goes to their email, no password. The
 address is checked before sending, and the answer never tells whether an account exists.
 */
import Features
import SwiftUI

struct SignInView: View {
    let flow: OnboardingFlowModel
    @State private var model: EmailEntryModel

    init(flow: OnboardingFlowModel) {
        self.flow = flow
        _model = State(initialValue: flow.makeEmailModel())
    }

    var body: some View {
        OnboardingPage {
            KiraNavBar("onboarding.signIn.title", leading: .back("onboarding.back") { flow.back() })
            Spacer(minLength: KiraSpacing.space4)
            VStack(spacing: 18) {
                VStack(spacing: KiraSpacing.space1) {
                    KiraMascot(.calm, size: 148)
                    KiraHandNote("onboarding.signIn.note")
                }
                VStack(spacing: 10) {
                    OnboardingHeading(text: "onboarding.signIn.heading")
                    Text("onboarding.signIn.lead").onboardingLead().frame(maxWidth: 320)
                }
                .multilineTextAlignment(.center)
            }
            Spacer(minLength: KiraSpacing.space4)
            EmailForm(model: model, submitLabel: "onboarding.signIn.send")
        }
        .onboardingBackdrop(leaf: .pandan)
    }
}
