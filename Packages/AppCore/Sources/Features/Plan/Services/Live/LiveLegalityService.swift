import APIClient
import Domain

/** Cek Legalitas over the API client. */
package struct LiveLegalityService: LegalityService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /legality`. */
    package func search(_ query: String) async throws -> LegalitySearch {
        try await api.searchLegality(query)
    }
}
