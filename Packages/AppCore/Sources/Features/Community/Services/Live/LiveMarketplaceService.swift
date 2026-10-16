import APIClient
import Domain

/** Etalase's calls over the API client. */
package struct LiveMarketplaceService: MarketplaceService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /community/products?kind=`. */
    package func products(kind: ProductKind?) async throws -> [ProductSummary] {
        try await api.listCommunityProducts(kind: kind)
    }

    /** `GET /community/products/{id}`. */
    package func product(id: String) async throws -> Product {
        try await api.getCommunityProduct(id: id)
    }
}
