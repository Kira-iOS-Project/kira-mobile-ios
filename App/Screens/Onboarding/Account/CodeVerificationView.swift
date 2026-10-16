/**
 Kode Verifikasi (ONB-07, ONB-07b): "Cek Emailmu", six boxes the keyboard can fill from Mail, a
 calm countdown before another code, and the warning never to share the code. The sixth digit
 verifies at once; back and "Ganti Email" return to where the email was typed. "Ganti Email" is
 the outlined block button of Intro, not the board's quiet link (the owner's choice, 2026-10-16).
 */
import APIClient
import Features
import SwiftUI

struct CodeVerificationView: View {
    let flow: OnboardingFlowModel
    @State private var model: CodeVerificationModel

    init(flow: OnboardingFlowModel, model: CodeVerificationModel) {
        self.flow = flow
        _model = State(initialValue: model)
    }

    var body: some View {
        OnboardingPage {
            KiraNavBar("onboarding.code.title", leading: .back(backLabel) { flow.back() })
            Spacer(minLength: KiraSpacing.space4)
            VStack(spacing: 26) {
                VStack(spacing: 18) {
                    KiraIllustration(.letter, size: 136)
                    VStack(spacing: KiraSpacing.space2) {
                        OnboardingHeading(text: "onboarding.code.heading")
                        Text("onboarding.code.sentTo \(Text(model.email).fontWeight(.semibold).foregroundStyle(.ink))")
                            .onboardingLead()
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: 300)
                    }
                    .multilineTextAlignment(.center)
                }
                CodeEntry(model: model)
            }
            .padding(.bottom, KiraSpacing.space6)
            Spacer(minLength: 0)
            KiraNotice(.safe, message: "onboarding.code.notice")
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("onboarding.code.verify") { Task { await model.verify() } }
                    .block()
                    .disabled(!model.isComplete || model.phase.isSubmitting)
                KiraButton("onboarding.code.changeEmail", variant: .secondary) { flow.back() }.block()
            }
        }
        .onboardingBackdrop(leaf: .twig)
        .task(id: model.countdownRun) { await model.runCountdown() }
        .task(id: model.code) { await model.verifyIfComplete() }
    }

    private var backLabel: LocalizedStringResource {
        flow.signsIn ? "onboarding.code.backToSignIn" : "onboarding.code.backToSignUp"
    }
}

/** The six boxes, the problem if any, and the countdown or the resend link. */
private struct CodeEntry: View {
    @Bindable var model: CodeVerificationModel

    var body: some View {
        VStack(spacing: 14) {
            KiraCodeField("onboarding.code.field", code: $model.code, kind: .code)
                .error(model.phase.problem.map(\.message))
            if let problem = model.phase.problem, problem.knownCode == nil {
                Text(problem.reference).font(.caption.monospaced()).foregroundStyle(.inkMuted)
            }
            if model.secondsUntilResend > 0 {
                Text("onboarding.code.resendIn \(countdown)")
                    .font(.subheadline.monospacedDigit()).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.inkMuted)
            } else {
                KiraLink("onboarding.code.resend") { Task { await model.resend() } }
            }
        }
    }

    /**
     "0:42": the board writes minutes and seconds with a colon, which the Indonesian locale would
     make a dot, so the style keeps its own locale (`Text(_:format:)` would put the screen's back).
     */
    private var countdown: String {
        Duration.seconds(model.secondsUntilResend)
            .formatted(.time(pattern: .minuteSecond).locale(Locale(identifier: "en_US_POSIX")))
    }
}
