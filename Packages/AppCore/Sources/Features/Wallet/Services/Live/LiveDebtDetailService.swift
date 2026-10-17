import APIClient
import Domain

/** Detail Utang's call over the generated API client. */
package struct LiveDebtDetailService: DebtDetailService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /debts/{id}`. */
    package func debt(id: String) async throws -> DebtDetail {
        try await api.getDebt(id: id)
    }
}
