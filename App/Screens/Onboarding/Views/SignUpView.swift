/**
 Buat Akun (ONB-05): Kuku, the promise "Simpan Catatanmu dengan Aman", one way to sign up (email,
 no password) and the links to the Terms and the Privacy Policy. "Daftar dengan Email" opens a
 sheet for the address, which the board leaves out; the code then goes there. A request that fails
 closes the sheet for the failure dialog, whose Coba Lagi opens it again on the same address. A send
 that went through closes the sheet, and Kode Verifikasi is pushed only once its cover is down. No help button.
 "Aku Sudah Punya Akun" is the outlined block button of Intro, not the board's quiet link (the
 owner's choice, 2026-10-16).
 */
import Features
import SwiftUI

struct SignUpView: View {
    @Bindable var flow: OnboardingFlowModel
    let onOpen: (AppRoute) -> Void

    var body: some View {
        OnboardingPage {
            header
            Spacer(minLength: KiraSpacing.space4)
            VStack(spacing: 18) {
                KiraMascot(.calm, size: 148)
                VStack(spacing: 10) {
                    Text("onboarding.signUp.overline").onboardingOverline()
                    OnboardingHeading(text: "onboarding.signUp.title")
                    Text("onboarding.signUp.lead").onboardingLead().frame(maxWidth: 320)
                }
                .multilineTextAlignment(.center)
            }
            Spacer(minLength: KiraSpacing.space4)
            KiraNotice(.privacy, message: "onboarding.signUp.notice")
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("onboarding.signUp.email", action: flow.openSignUpEmail).block()
                KiraButton("onboarding.intro.haveAccount", variant: .secondary) { flow.open(.signIn) }.block()
            }
            KiraLinkText("onboarding.signUp.terms") { onOpen(Self.route(for: $0)) }
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .onboardingBackdrop(leaf: .twig)
        .kiraSheet(
            $flow.signUpEmail, title: "onboarding.signUp.sheet.title", subtitle: "onboarding.signUp.sheet.subtitle",
            failureTitle: "onboarding.signUp.sheet.failed", onRetry: { Task { await flow.retrySignUpEmail() } },
            onGone: flow.signUpSheetGone, content: {
                EmailForm(model: flow.signUpEmailModel(), submitLabel: "onboarding.signUp.sheet.send")
                    .padding(.bottom, KiraSpacing.space2)
            })
    }

    private var header: some View {
        ZStack {
            KiraLogo(.wordmark, size: 26)
            KiraIconButton.back("onboarding.back") { flow.back() }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: KiraSize.tap)
    }

    /** The Terms link is `kira://terms`; any other link in the sentence is the Privacy Policy. */
    private static func route(for url: URL) -> AppRoute {
        url.host() == "terms" ? .terms : .privacyPolicy
    }
}
