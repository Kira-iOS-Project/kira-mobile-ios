import APIClient
import Domain

/** KIR-121's adapter from the edit service to the generated Finance API. */
package struct LiveBillEditService: BillEditService {
    private let api: KiraAPI

    /** Uses the session-bound Kira API client. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** Reads the selected bill. */
    package func bill(id: String) async throws -> RecurringBill {
        try await api.getBill(id: id)
    }

    /** Sends the validated future-schedule fields. */
    package func updateBill(id: String, update: BillScheduleUpdate) async throws -> RecurringBill {
        try await api.updateBill(id: id, update: update)
    }
}
