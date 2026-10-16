import APIClient
import Domain
import Observation

/** Metode Pembayaran (AKN-07d): QRIS or App Store, saved with Simpan. */
@MainActor
@Observable
package final class PaymentMethodModel {
    /** Where saving stands. */
    package enum Phase: Sendable {
        /** Choosing. */
        case ready
        /** Sent. */
        case saving
        /** Saved: the screen closes. */
        case saved
        /** Refused, with the API's problem. */
        case failed(AppProblem)
    }

    /** The method checked. */
    package var paymentMethod: PaymentMethod
    /** Where saving stands. */
    package private(set) var phase = Phase.ready

    private let service: any PlansService

    /** The screen with the subscription's current method checked (QRIS when it has none). */
    package init(current: PaymentMethod?, service: any PlansService) {
        paymentMethod = current ?? .qris
        self.service = service
    }

    /** Saves the checked method. */
    package func save() async {
        phase = .saving
        do {
            _ = try await service.setPaymentMethod(paymentMethod)
            phase = .saved
        } catch {
            phase = .failed(plansProblem(error))
        }
    }
}
