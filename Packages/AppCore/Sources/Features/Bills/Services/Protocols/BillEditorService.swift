import Domain

/**
 The writes behind Tambah Tagihan and Ubah Tagihan (UNG-07, UNG-07c, UNG-07d). Each throws an
 `AppProblem` the API refuses with: 404 `BILL_NOT_FOUND`, 404 `BILL_DEBT_NOT_FOUND` for a debt
 account that is gone, 422 out of range. Returns the bill's id as stored.
 */
package protocol BillEditorService: Sendable {
    /** `POST /bills`: Simpan Tagihan. */
    func createBill(_ draft: BillDraft) async throws -> String
    /** `PATCH /bills/{id}`: Simpan Perubahan; the next occurrences change, recorded ones stay. */
    func updateBill(id: String, _ draft: BillDraft) async throws -> String
    /** `DELETE /bills/{id}`: Hapus. */
    func deleteBill(id: String) async throws
}
