import APIClient
import Domain

/** Tambah and Ubah Tagihan's writes over the API client. */
package struct LiveBillEditorService: BillEditorService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `POST /bills`. */
    package func createBill(_ draft: BillDraft) async throws -> String {
        try await api.createBill(draft)
    }

    /** `PATCH /bills/{id}`. */
    package func updateBill(id: String, _ draft: BillDraft) async throws -> String {
        try await api.updateBill(id: id, draft)
    }

    /** `DELETE /bills/{id}`. */
    package func deleteBill(id: String) async throws {
        try await api.deleteBill(id: id)
    }
}
