import APIClient
import Domain
import Observation

/** Traktir Kira (AKN-07f, AKN-07g): months of Kira Plus for Beasiswa Kira, simulated. */
@MainActor
@Observable
package final class TreatModel {
    /** Kira Plus's monthly price, once loaded. */
    package private(set) var phase: ScreenPhase<Int> = .loading
    /** 1, 3 or 6 months; 3 until the person picks. */
    package var months = 3
    /** Whether the request is on its way. */
    package private(set) var isSending = false
    /** The gift once sent: the thank-you dialog shows. */
    package var gift: TreatGift?
    /** The problem of a refused gift. */
    package private(set) var sendProblem: AppProblem?

    private let service: any PlansService

    /** The screen. */
    package init(service: any PlansService) {
        self.service = service
    }

    /** What the gift costs: Kira Plus's monthly price times the months. */
    package var total: Int { (phase.value ?? 0) * months }

    /** Loads Kira Plus's price. */
    package func load() async {
        phase = .loading
        do {
            if let plus = try await service.plans().terms(for: .plus) {
                phase = .loaded(plus.monthlyPrice)
            } else {
                phase = .empty
            }
        } catch {
            phase = .failed(plansProblem(error))
        }
    }

    /** Sends the gift (simulated; the board asks for no method, so QRIS). */
    package func send() async {
        isSending = true
        sendProblem = nil
        do {
            gift = try await service.treat(months: months, paymentMethod: .qris)
        } catch {
            sendProblem = plansProblem(error)
        }
        isSending = false
    }
}
