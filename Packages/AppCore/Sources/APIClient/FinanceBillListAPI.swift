import Domain

/** KIR-40's recurring-bill list operation. */
extension KiraAPI {
    package func getBills() async throws -> [RecurringBill] {
        try await client.listBills(.init()).bills()
    }
}
