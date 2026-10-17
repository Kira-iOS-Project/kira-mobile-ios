import Domain
import Observation

/**
 Kode Verifikasi (ONB-07, ONB-07b): six boxes for the code sent by email. The sixth digit verifies
 at once; "Kirim ulang kode dalam 0:42" counts down from the server's `resendAfterSeconds`, then
 offers a new code, which cancels the old one.
 */
@MainActor @Observable
package final class CodeVerificationModel {
    /** What the last request was, so its failure dialog names it. */
    package enum Request: Sendable {
        /** Verifikasi, or the sixth digit. */
        case verify
        /** Kirim Ulang Kode. */
        case resend
    }

    /** Waits one tick of the countdown; tests pass one that returns at once. */
    package typealias Sleep = @Sendable (Duration) async throws -> Void

    /** Digits in the code the server emails. */
    package static let codeLength = 6

    /** The address the code went to. */
    package let email: String
    /** The digits typed or pasted so far. */
    package var code = "" {
        didSet { if phase.problem != nil, !code.isEmpty { phase = .editing } }
    }
    /** Seconds before another code may be asked for; 0 offers "Kirim Ulang Kode". */
    package private(set) var secondsUntilResend: Int
    /** Changes each time a countdown starts, so the view restarts its task. */
    package private(set) var countdownRun = 0
    /** Editing, verifying or failed. */
    package private(set) var phase = SubmitPhase.editing
    /** The request a failure belongs to: Verifikasi or Kirim Ulang Kode. */
    package private(set) var failedRequest = Request.verify
    /** Whether "Kode Baru Terkirim" shows, after a new code went out. */
    package var showsCodeResent = false
    private let service: any OnboardingService
    private let sleep: Sleep
    private let onVerified: (SignInResult) -> Void

    /** A model for the code sent to `email` with `delivery`; `onVerified` runs once it is right. */
    package init(
        email: String, delivery: CodeDelivery, service: any OnboardingService,
        sleep: @escaping Sleep = { try await Task.sleep(for: $0) },
        onVerified: @escaping (SignInResult) -> Void
    ) {
        self.email = email
        secondsUntilResend = max(delivery.resendAfterSeconds, 0)
        self.service = service
        self.sleep = sleep
        self.onVerified = onVerified
    }

    /** Whether the boxes hold six digits and nothing else (a paste is trimmed to its digits first). */
    package var isComplete: Bool {
        code.count == Self.codeLength && DigitCode.digits(in: code, length: Self.codeLength) == code
    }

    /** Counts down to 0 a second at a time; stops early when its task is cancelled. */
    package func runCountdown() async {
        while secondsUntilResend > 0 {
            do { try await sleep(.seconds(1)) } catch { return }
            secondsUntilResend -= 1
        }
    }

    /** Verifies as soon as the sixth digit is in. */
    package func verifyIfComplete() async {
        if isComplete { await verify() }
    }

    /** Sends the code; a wrong or expired one empties the boxes and says why. */
    package func verify() async {
        guard isComplete, !phase.isSubmitting else { return }
        phase = .submitting
        do {
            let result = try await service.verify(email: email, code: code)
            phase = .editing
            onVerified(result)
        } catch {
            code = ""
            failedRequest = .verify
            phase = .failure(error)
        }
    }

    /**
     Asks for a new code once the countdown is over, starts the countdown again and says so ("Kode
     Baru Terkirim"); a refusal shows its own dialog ("Belum Bisa Mengirim Kode").
     */
    package func resend() async {
        guard secondsUntilResend == 0, !phase.isSubmitting else { return }
        phase = .submitting
        do {
            let delivery = try await service.requestCode(email: email)
            code = ""
            phase = .editing
            secondsUntilResend = max(delivery.resendAfterSeconds, 0)
            countdownRun += 1
            showsCodeResent = true
        } catch {
            failedRequest = .resend
            phase = .failure(error)
        }
    }
}
