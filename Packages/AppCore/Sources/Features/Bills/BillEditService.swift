import APIClient
import Domain

/** The detail and save calls made by the recurring-bill editor. */
package protocol BillEditService: Sendable {
    /** Loads an owned bill schedule. */
    func bill(id: String) async throws -> RecurringBill
    /** Saves changed future-schedule fields without changing recorded transactions. */
    func updateBill(id: String, update: BillScheduleUpdate) async throws -> RecurringBill
    /** Cancels future occurrences while preserving recorded transactions. */
    func deleteBill(id: String) async throws
}

/** The problem shown when the edit screen cannot load or save a schedule. */
func billEditProblem(_ error: any Error) -> AppProblem {
    if let problem = error as? AppProblem { return problem }
    return AppProblem()
}
