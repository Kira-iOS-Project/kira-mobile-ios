import APIClient
import Domain
import Features

/** Sample service for the bill-edit canvas and accessibility audit. */
nonisolated struct PreviewBillEditService: BillEditService {
    func bill(id: String) async throws -> RecurringBill {
        guard let bill = PreviewBillsService.samples.first(where: { $0.id == id }) else { throw AppProblem() }
        return bill
    }

    func updateBill(id: String, update: BillScheduleUpdate) async throws -> RecurringBill {
        let bill = try await bill(id: id)
        return RecurringBill(
            id: bill.id, name: update.name, amount: update.amount, category: update.category.rawValue,
            nextDueDate: update.nextDueDate, repeatInterval: update.repeatInterval.rawValue, kind: .bill,
            isDueSoon: bill.isDueSoon, isPaidThisPeriod: bill.isPaidThisPeriod)
    }
}
