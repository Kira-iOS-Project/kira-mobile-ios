import APIClient
import Domain
import Observation

/**
 Etalase (KOM-06): the curated products, filtered by kind with the chips (Semua, Kursus,
 Konsultasi, E-Book, Event). The list keeps the team's order; a kind with no product is empty.
 */
@MainActor
@Observable
package final class MarketplaceModel {
    /** The products of the chosen kind, loading until the API answers. */
    package private(set) var phase: ScreenPhase<[ProductSummary]> = .loading
    /** The chosen kind, or nil for "Semua". */
    package private(set) var kind: ProductKind?

    @ObservationIgnored private let service: any MarketplaceService
    /** Counts the loads, so an answer for a kind no longer chosen never replaces the newer one. */
    @ObservationIgnored private var generation = 0

    /** A model that loads through `service`, showing every kind. */
    package init(service: any MarketplaceService) {
        self.service = service
    }

    /** Loads the products of the chosen kind, or loads them again after a failure. */
    package func load() async {
        generation += 1
        let current = generation
        phase = .loading
        let next: ScreenPhase<[ProductSummary]>
        do {
            let products = try await service.products(kind: kind)
            next = products.isEmpty ? .empty : .loaded(products)
        } catch {
            next = .failed(error as? AppProblem ?? AppProblem())
        }
        if current == generation { phase = next }
    }

    /** A chip tap: shows `kind` (nil for "Semua"); the chip already chosen does nothing. */
    package func select(_ kind: ProductKind?) async {
        guard kind != self.kind else { return }
        self.kind = kind
        await load()
    }
}
