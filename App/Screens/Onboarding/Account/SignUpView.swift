/**
 Buat Akun (ONB-05): Kuku, the promise "Simpan Catatanmu dengan Aman", one way to sign up (email,
 no password) and the links to the Terms and the Privacy Policy. "Daftar dengan Email" opens a
 sheet for the address, which the board leaves out; the code then goes there. No help button.
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
            KiraButton("onboarding.signUp.email") { flow.showsSignUpEmail = true }.block()
            VStack(spacing: 2) {
                KiraButton("onboarding.intro.haveAccount", variant: .quiet, size: .small) { flow.open(.signIn) }
                KiraLinkText("onboarding.signUp.terms") { onOpen(Self.route(for: $0)) }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .padding(.top, -4)
        }
        .onboardingBackdrop(leaf: .twig)
        .kiraSheet(
            isPresented: $flow.showsSignUpEmail, title: "onboarding.signUp.sheet.title",
            subtitle: "onboarding.signUp.sheet.subtitle"
        ) {
            SignUpEmailSheet(flow: flow)
        }
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

/** The email sheet of Buat Akun: the same field and hint as Masuk, then "Kirim Kode". */
private struct SignUpEmailSheet: View {
    @State private var model: EmailEntryModel

    init(flow: OnboardingFlowModel) {
        _model = State(initialValue: flow.makeEmailModel())
    }

    var body: some View {
        EmailForm(model: model, submitLabel: "onboarding.signUp.sheet.send")
            .padding(.bottom, KiraSpacing.space2)
    }
}
