import APIClient
import Domain

/** Tagihan & Cicilan's reads through the signed-in API client. */
package struct LiveBillService: BillService {
    private let api: KiraAPI

    /** Uses the same signed-in API client as the other finance screens. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /api/bills`. */
    package func bills() async throws -> BillOverview {
        try await api.listBills()
    }
}
