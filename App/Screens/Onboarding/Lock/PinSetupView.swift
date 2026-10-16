/**
 Kunci Kira (ONB-14, ONB-14b): a six-digit PIN in boxes like the email code, on the number pad,
 dots unless "Tahan untuk Lihat" is held; a repeated digit is refused. "Sembunyikan Saldo" masks
 every amount when Kira opens. "Buat PIN" keeps the PIN on this device and says so in a dialog;
 "Nanti Saja" goes on without a lock (Keamanan offers it again).
 */
import Features
import SwiftUI

struct PinSetupView: View {
    let flow: OnboardingFlowModel
    @State private var model: PinSetupModel

    init(flow: OnboardingFlowModel) {
        self.flow = flow
        _model = State(initialValue: flow.makePinModel())
    }

    var body: some View {
        OnboardingPage {
            KiraNavBar("onboarding.pin.title", leading: .back("onboarding.back") { flow.back() })
            VStack(spacing: KiraSpacing.space4) {
                KiraIllustration(.padlock, size: 128)
                VStack(spacing: KiraSpacing.space2) {
                    OnboardingHeading(text: "onboarding.pin.heading")
                    Text("onboarding.pin.lead").onboardingLead().frame(maxWidth: 320)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.vertical, KiraSpacing.space2)
            PinForm(model: model)
            Spacer(minLength: 0)
            if let problem = model.phase.problem { ProblemMessage(problem: problem) }
            KiraButtonPair(
                secondary: KiraButton("ds.later", variant: .secondary) { Task { await model.skip() } },
                primary: KiraButton("onboarding.pin.create") { Task { await model.createPin() } })
                .disabled(model.phase.isSubmitting)
        }
        .onboardingBackdrop(leaf: .pandan)
        .kiraDialog(isPresented: $model.showsSuccess) {
            KiraDialog(
                "onboarding.pin.success.title", message: "onboarding.pin.success.body", art: .illustration(.shield),
                primary: KiraButton("onboarding.pin.success.start") { model.start() })
        }
    }
}

/** The PIN boxes with their hint or the refusal, and the balance switch. */
private struct PinForm: View {
    @Bindable var model: PinSetupModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraCodeField("onboarding.pin.field", code: $model.pin, kind: .pin)
                .hint("onboarding.pin.hint")
                .error(model.showsWeakPin ? "onboarding.pin.weak" : nil)
            KiraListGroup {
                KiraListRow(Text("onboarding.pin.hideBalances"), leading: .icon(.eyeOff), trailing: .toggle($model.hidesBalances))
                    .subtitle(Text("onboarding.pin.hideBalances.subtitle"))
            }
        }
    }
}
