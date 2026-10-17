import APIClient
import Domain

/** The list screen's server calls. */
package struct LiveBillsService: BillsService {
    private let api: KiraAPI

    /** Uses the signed-in API client. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** Loads recurring bills and installment schedules owned by the current account. */
    package func bills() async throws -> [RecurringBill] {
        try await api.getBills()
    }
}
