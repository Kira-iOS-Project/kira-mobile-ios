/**
 Persetujuan Data (ONB-08, ONB-08b): "Datamu, Keputusanmu", a switch per purpose (the core one
 locked on, tagged Wajib), the promise about specific personal data, and what reaches the AI in an
 accordion, closed at first. Only back and the main action: no help or close button.
 */
import Features
import SwiftUI

struct ConsentView: View {
    let flow: OnboardingFlowModel
    let onOpen: (AppRoute) -> Void
    @State private var model: ConsentModel

    init(flow: OnboardingFlowModel, onOpen: @escaping (AppRoute) -> Void) {
        self.flow = flow
        self.onOpen = onOpen
        _model = State(initialValue: flow.makeConsentModel())
    }

    var body: some View {
        OnboardingPage {
            KiraNavBar("onboarding.consent.title", leading: .back("onboarding.back") { flow.back() })
            VStack(spacing: KiraSpacing.space4) {
                KiraIllustration(.padlock, size: 112)
                VStack(spacing: KiraSpacing.space2) {
                    Text("onboarding.consent.overline").onboardingOverline()
                    OnboardingHeading(text: "onboarding.consent.heading")
                    Text("onboarding.consent.lead").onboardingLead().frame(maxWidth: 330)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space1)
            ConsentPurposes(model: model)
            KiraAccordion("onboarding.consent.ai.title", subtitle: "onboarding.consent.ai.subtitle", icon: .sparkle) {
                VStack(alignment: .leading, spacing: 6) {
                    ConsentBullet(text: "onboarding.consent.ai.account")
                    ConsentBullet(text: "onboarding.consent.ai.receipt")
                }
            }
            Spacer(minLength: 0)
            VStack(spacing: KiraSpacing.space2) {
                if let problem = model.phase.problem { ProblemMessage(problem: problem) }
                KiraButton("onboarding.consent.agree") { Task { await model.submit() } }
                    .block()
                    .disabled(model.phase.isSubmitting)
                KiraButton("onboarding.consent.policy", variant: .secondary) { onOpen(.privacyPolicy) }.block()
            }
            .onboardingFoot()
        }
        .onboardingBackdrop(leaf: .pandan)
    }
}

/** "Tujuan Pemakaian Data": the locked core purpose, then the two the person may turn off. */
private struct ConsentPurposes: View {
    @Bindable var model: ConsentModel

    var body: some View {
        KiraListGroup("onboarding.consent.purposes", footer: "onboarding.consent.footer") {
            KiraListRow(Text("onboarding.consent.core"), leading: .icon(.chart), trailing: .toggle(.constant(true))) {
                KiraTag("onboarding.consent.required", tone: .pandan, icon: .lock)
            }
            .subtitle(Text("onboarding.consent.core.subtitle"))
            .disabled(true)
            KiraListRow(
                Text("onboarding.consent.aiRow"), leading: .icon(.sparkle), trailing: .toggle($model.aiProcessing)
            )
            .subtitle(Text("onboarding.consent.aiRow.subtitle"))
            KiraListRow(
                Text("onboarding.consent.weekly"), leading: .icon(.chart), trailing: .toggle($model.weeklySummary)
            )
            .subtitle(Text("onboarding.consent.weekly.subtitle"))
        }
    }
}

/** One line of the AI accordion, with its bullet. */
private struct ConsentBullet: View {
    let text: LocalizedStringResource

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("onboarding.consent.bullet").accessibilityHidden(true)
            Text(text)
        }
        .font(.subheadline).kiraLineHeight(20, size: 15)
        .foregroundStyle(.ink)
        .padding(.leading, 4)
    }
}
