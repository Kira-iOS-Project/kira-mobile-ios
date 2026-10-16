import Domain

/** The screens of onboarding after the three intro pages, as the flow's navigation path holds them. */
package enum OnboardingScreen: Hashable, Sendable {
    /** Buat Akun (ONB-05). */
    case signUp
    /** Masuk (ONB-06). */
    case signIn
    /** Kode Verifikasi (ONB-07, ONB-07b) for the code sent to `email`. */
    case code(email: String, delivery: CodeDelivery)
    /** Persetujuan Data (ONB-08). */
    case consent
    /** Pilih Fokus (ONB-09). */
    case focus
    /** One step of the health check. */
    case healthCheck(HealthCheckStep)
    /** Hasil Cek Kesehatan (ONB-13). */
    case result(ScoreReport)
    /** Kunci Kira (ONB-14). */
    case pin
}

/** How onboarding ended, for the root to open the right Beranda. */
package enum OnboardingOutcome: Hashable, Sendable {
    /** An account that was already set up signed in: its Beranda, restored from the server. */
    case signedIn
    /** A new account finished onboarding with the focus it chose. */
    case completed(Focus)
    /** The health check, opened again from the score, sent new answers. */
    case rechecked
    /** The health check, opened again from the score, was left without new answers. */
    case closed
}

/** Where a flow starts: the intro, or a later screen when onboarding resumes or the quiz is redone. */
package enum OnboardingStart: Hashable, Sendable {
    /** The three intro pages, then Buat Akun or Masuk. */
    case intro
    /** Signed in without consents: Persetujuan Data. */
    case consent
    /** Consents given, no health check yet: Pilih Fokus. */
    case focus
    /** "Cek Ulang" from the score: the six steps and the result, without Kunci Kira. */
    case healthCheck
    /** The session ended (a refresh the API refused): Masuk, over the intro pages, so Back reaches them. */
    case signIn

    /** The screen at the bottom of the stack, nil for the intro pages. */
    package var rootScreen: OnboardingScreen? {
        switch self {
        case .intro, .signIn: nil
        case .consent: .consent
        case .focus: .focus
        case .healthCheck: .healthCheck(.income)
        }
    }
}
