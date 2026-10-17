import APIClient
import Domain

/** Portofolio Manual's calls over the API client. */
package struct LivePortfolioService: PortfolioService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /assets`. */
    package func portfolio() async throws -> Portfolio {
        try await api.listAssets()
    }

    /** `POST /assets`. */
    package func addAsset(_ input: AssetInput) async throws -> Asset {
        try await api.createAsset(input)
    }

    /** `PATCH /assets/{id}`. */
    package func updateAsset(id: String, _ input: AssetInput) async throws -> Asset {
        try await api.updateAsset(id: id, input)
    }
}
