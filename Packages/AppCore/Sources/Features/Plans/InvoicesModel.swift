import Domain
import Observation

/** Riwayat Tagihan (AKN-07e): every payment of the subscription. */
@MainActor
@Observable
package final class InvoicesModel {
    /** The invoices; `.empty` when there are none. */
    package private(set) var phase: ScreenPhase<[Invoice]> = .loading

    private let service: any PlansService

    /** The screen for the person's invoices. */
    package init(service: any PlansService) {
        self.service = service
    }

    /** Loads the invoices. */
    package func load() async {
        phase = .loading
        do {
            let invoices = try await service.invoices()
            phase = invoices.isEmpty ? .empty : .loaded(invoices)
        } catch {
            phase = .failed(plansProblem(error))
        }
    }
}
