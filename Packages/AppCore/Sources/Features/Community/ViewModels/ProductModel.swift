import APIClient
import Domain
import Observation

/**
 Detail Produk (KOM-07, KOM-07b to KOM-07d): one product, its seller, price and contents, the
 disclosures, and the seller's page. One screen for the four kinds.
 */
@MainActor
@Observable
package final class ProductModel {
    /** The product the screen was opened for. */
    package let id: String
    /** The product, loading until the API answers; empty when it is no longer in Etalase. */
    package private(set) var phase: ScreenPhase<Product> = .loading

    @ObservationIgnored private let service: any MarketplaceService

    /** A model of product `id`, loaded through `service`. */
    package init(id: String, service: any MarketplaceService) {
        self.id = id
        self.service = service
    }

    /** Loads the product, or loads it again after a failure. */
    package func load() async {
        phase = .loading
        do {
            phase = .loaded(try await service.product(id: id))
        } catch let problem as AppProblem where Self.isGone(problem.knownCode) {
            /** Gone for good: a retry cannot bring it back, so the screen offers the way back. */
            phase = .empty
        } catch {
            /** Leaving the screen cancels the load: it stays loading, and loads again on return. */
            guard !Task.isCancelled else { return }
            phase = .failed(AppProblem(error))
        }
    }
}
