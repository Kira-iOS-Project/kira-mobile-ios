import Domain

/** Tagihan & Cicilan's reads through the generated client. */
extension KiraAPI {
    /** `GET /api/bills` (`listBills`): the recurring bills, grouped, with their monthly total. */
    package func listBills() async throws -> BillOverview {
        try await client.listBills().billOverview()
    }
}
