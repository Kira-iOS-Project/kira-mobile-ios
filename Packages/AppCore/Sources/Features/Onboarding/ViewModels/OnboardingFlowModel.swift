import Domain
import Observation

/**
 The order of onboarding (Alur Masuk & Onboarding): the intro pages, Buat Akun or Masuk, the code,
 then for a new account Persetujuan Data, Pilih Fokus, the six health-check steps, the result and
 Kunci Kira. An account already set up goes straight to Beranda after its code. The flow builds
 each screen's model and moves the path when that model is done.
 */
@MainActor @Observable
package final class OnboardingFlowModel {
    /** The screens pushed over the intro pages. */
    package var path: [OnboardingScreen] = []
    /** The email sheet of Buat Akun: open, or closed on a failed request with its dialog. */
    package var signUpEmail = SheetSubmission()
    /** Where the flow started. */
    package let start: OnboardingStart
    /** The focus saved on Pilih Fokus. */
    package private(set) var focus = Focus.trackSpending
    @ObservationIgnored private var quiz: HealthCheckModel?
    @ObservationIgnored private var signUpEntry: EmailEntryModel?
    private let service: any OnboardingService
    private let pinSetup: any PinSetup
    private let onFinished: (OnboardingOutcome) -> Void

    /** A flow from `start` calling `service` and `pinSetup`, ending with `onFinished`. */
    package init(
        service: any OnboardingService, pinSetup: any PinSetup, start: OnboardingStart = .intro,
        onFinished: @escaping (OnboardingOutcome) -> Void
    ) {
        self.start = start
        if start == .signIn { path = [.signIn] }
        self.service = service
        self.pinSetup = pinSetup
        self.onFinished = onFinished
    }

    /** Pushes `screen` ("Lewati" and "Mulai Pakai Kira" push Buat Akun; "Aku Sudah Punya Akun", Masuk). */
    package func open(_ screen: OnboardingScreen) {
        path.append(screen)
    }

    /** Whether the person came through Masuk: the code screen's back button names it. */
    package var signsIn: Bool { path.contains(.signIn) }

    /** Whether the quiz was opened again from the score: the result ends with "Selesai". */
    package var isRecheck: Bool { start == .healthCheck }

    /** Back, and "Ganti Email" on the code screen; back from the first step of a recheck closes it. */
    package func back() {
        if !path.isEmpty {
            path.removeLast()
        } else if isRecheck {
            onFinished(.closed)
        }
    }

    /** The model of Masuk, and of the email sheet of Buat Akun. */
    package func makeEmailModel() -> EmailEntryModel {
        EmailEntryModel(service: service) { [weak self] in self?.codeSent(to: $0, delivery: $1) }
    }

    /** The model of the Buat Akun email sheet, kept while the sheet closes so its address stays. */
    package func signUpEmailModel() -> EmailEntryModel {
        if let signUpEntry { return signUpEntry }
        let model = EmailEntryModel(
            service: service, onFailed: { [weak self] in self?.signUpEmail.fail($0) },
            onSent: { [weak self] in self?.codeSent(to: $0, delivery: $1) })
        signUpEntry = model
        return model
    }

    /** "Daftar dengan Email": opens the sheet. */
    package func openSignUpEmail() {
        signUpEmail.open()
    }

    /** Coba Lagi on the sheet's failure: the sheet opens again on the same address and sends again. */
    package func retrySignUpEmail() async {
        signUpEmail.open()
        await signUpEmailModel().submit()
    }

    /** The model of Kode Verifikasi for the code sent to `email`. */
    package func makeCodeModel(email: String, delivery: CodeDelivery) -> CodeVerificationModel {
        CodeVerificationModel(email: email, delivery: delivery, service: service) { [weak self] in
            self?.verified($0)
        }
    }

    /** The model of Persetujuan Data. */
    package func makeConsentModel() -> ConsentModel {
        ConsentModel(service: service) { [weak self] in self?.open(.focus) }
    }

    /** The model of Pilih Fokus. */
    package func makeFocusModel() -> FocusModel {
        FocusModel(service: service) { [weak self] in self?.focusSaved($0) }
    }

    /** The one model every health-check step shares. */
    package func healthCheckModel() -> HealthCheckModel {
        if let quiz { return quiz }
        let model = HealthCheckModel(service: service) { [weak self] in self?.open(.result($0)) }
        quiz = model
        return model
    }

    /** "Lanjut", "Lewati" or "Isi Nanti" on `step`: the next step. */
    package func next(after step: HealthCheckStep) {
        if let next = step.next { open(.healthCheck(next)) }
    }

    /** The model of Hasil Cek Kesehatan. */
    package func makeResultModel(report: ScoreReport) -> HealthCheckResultModel {
        HealthCheckResultModel(report: report) { [weak self] in self?.resultDone() }
    }

    /** The model of Kunci Kira. */
    package func makePinModel() -> PinSetupModel {
        PinSetupModel(service: service, pinSetup: pinSetup) { [weak self] in self?.finish() }
    }

    private func codeSent(to email: String, delivery: CodeDelivery) {
        signUpEmail.close()
        open(.code(email: email, delivery: delivery))
    }

    private func verified(_ result: SignInResult) {
        if result.needsOnboarding {
            open(.consent)
        } else {
            onFinished(.signedIn)
        }
    }

    private func focusSaved(_ focus: Focus) {
        self.focus = focus
        open(.healthCheck(.income))
    }

    private func resultDone() {
        if isRecheck {
            onFinished(.rechecked)
        } else {
            open(.pin)
        }
    }

    private func finish() {
        onFinished(.completed(focus))
    }
}
