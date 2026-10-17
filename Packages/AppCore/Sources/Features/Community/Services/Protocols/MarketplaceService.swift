import Domain

/**
 What Etalase and Detail Produk need from the API: `GET /community/products` and
 `GET /community/products/{id}`. Each call throws an `AppProblem`.
 */
package protocol MarketplaceService: Sendable {
    /** The curated products in the team's order, of one kind or of every kind (`nil`). */
    func products(kind: ProductKind?) async throws -> [ProductSummary]

    /** One product in full; `COMMUNITY_PRODUCT_NOT_FOUND` when it is gone. */
    func product(id: String) async throws -> Product
}
