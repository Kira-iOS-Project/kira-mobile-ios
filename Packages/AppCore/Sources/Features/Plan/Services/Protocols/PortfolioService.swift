import Domain

/**
 What Portofolio Manual needs from the API (REN-10, REN-11): the portfolio, a new asset, and an
 asset's new figures. Each call throws an `AppProblem`; a missing asset is `ASSET_NOT_FOUND`.
 */
package protocol PortfolioService: Sendable {
    /** `GET /assets`: the assets, their total and the Utang terhadap Aset indicator. */
    func portfolio() async throws -> Portfolio
    /** `POST /assets`: keeps a new asset. */
    func addAsset(_ input: AssetInput) async throws -> Asset
    /** `PATCH /assets/{id}`: the asset of `id` with new figures. */
    func updateAsset(id: String, _ input: AssetInput) async throws -> Asset
}
