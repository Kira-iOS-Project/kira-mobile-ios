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
    /** Whether the email sheet of Buat Akun is open. */
    package var showsSignUpEmail = false
    /** The focus saved on Pilih Fokus. */
    package private(set) var focus = Focus.trackSpending
    @ObservationIgnored private var quiz: HealthCheckModel?
    private let service: any OnboardingService
    private let pinSetup: any PinSetup
    private let onFinished: (OnboardingOutcome) -> Void

    /** A flow calling `service` and `pinSetup`, ending with `onFinished`. */
    package init(
        service: any OnboardingService, pinSetup: any PinSetup, onFinished: @escaping (OnboardingOutcome) -> Void
    ) {
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

    /** Back, and "Ganti Email" on the code screen. */
    package func back() {
        if !path.isEmpty { path.removeLast() }
    }

    /** The model of Masuk, and of the email sheet of Buat Akun. */
    package func makeEmailModel() -> EmailEntryModel {
        EmailEntryModel(service: service) { [weak self] in self?.codeSent(to: $0, delivery: $1) }
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
        HealthCheckResultModel(report: report) { [weak self] in self?.open(.pin) }
    }

    /** The model of Kunci Kira. */
    package func makePinModel() -> PinSetupModel {
        PinSetupModel(service: service, pinSetup: pinSetup) { [weak self] in self?.finish() }
    }

    private func codeSent(to email: String, delivery: CodeDelivery) {
        showsSignUpEmail = false
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

    private func finish() {
        onFinished(.completed(focus))
    }
}
