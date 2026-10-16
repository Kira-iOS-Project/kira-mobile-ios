import Domain
import Observation

/**
 Masuk (ONB-06) and the email of Buat Akun (ONB-05): the person types an email, the model checks
 its shape and asks for a code. The answer is the same whether or not an account exists.
 */
@MainActor @Observable
package final class EmailEntryModel {
    /** The email as typed. */
    package var email: String {
        didSet { if showsInvalidEmail { showsInvalidEmail = false } }
    }
    /** Whether the email failed the shape check on the last try. */
    package private(set) var showsInvalidEmail = false
    /** Editing, sending or failed. */
    package private(set) var phase = SubmitPhase.editing
    private let service: any OnboardingService
    private let onSent: (String, CodeDelivery) -> Void

    /** A model starting from `email`; `onSent` gets the normalized email and the delivery. */
    package init(
        email: String = "", service: any OnboardingService, onSent: @escaping (String, CodeDelivery) -> Void
    ) {
        self.email = email
        self.service = service
        self.onSent = onSent
    }

    /** Checks the email and, when it looks right, asks for a code. */
    package func submit() async {
        guard !phase.isSubmitting else { return }
        guard EmailAddress.isValid(email) else {
            showsInvalidEmail = true
            return
        }
        let address = EmailAddress.normalized(email)
        phase = .submitting
        do {
            let delivery = try await service.requestCode(email: address)
            phase = .editing
            onSent(address, delivery)
        } catch {
            phase = .failure(error)
        }
    }
}
