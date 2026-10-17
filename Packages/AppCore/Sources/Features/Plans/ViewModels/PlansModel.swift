import Domain
import Observation

/** Paket Kira (AKN-06, AKN-06d): the plans with the period the person picked. */
@MainActor
@Observable
package final class PlansModel {
    /** The catalog once loaded. */
    package private(set) var phase: ScreenPhase<PlanCatalog> = .loading
    /** Bulanan or Tahunan: which prices the cards show. */
    package var period: BillingPeriod

    private let service: any PlansService

    /** The screen, showing `period`'s prices first. */
    package init(service: any PlansService, period: BillingPeriod = .monthly) {
        self.service = service
        self.period = period
    }

    /** Loads the plans. */
    package func load() async {
        phase = .loading
        do {
            phase = .loaded(try await service.plans())
        } catch {
            phase = .failed(plansProblem(error))
        }
    }
}
