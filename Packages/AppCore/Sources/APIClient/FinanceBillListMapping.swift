import Domain

extension Operations.ListBills.Output {
    func bills() throws -> [RecurringBill] {
        switch self {
        case .ok(let response): try response.body.json.items.map(recurringBill)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

func recurringBill(_ row: Components.Schemas.Bill) throws -> RecurringBill {
    guard let due = CalendarDay(iso: row.nextDueDate) else { throw AppProblem() }
    return RecurringBill(
        id: row.id, name: row.name, amount: row.amount, category: row.category.rawValue,
        nextDueDate: due, repeatInterval: row.repeatInterval.rawValue,
        kind: row.kind == .debtInstallment ? .debtInstallment : .bill,
        installmentsTotal: row.installmentsTotal, installmentsRemaining: row.installmentsRemaining,
        linkedDebtAccountID: row.linkedDebtAccountId, linkedDebtName: row.linkedDebtName,
        isDueSoon: row.dueSoon, isPaidThisPeriod: row.paidThisPeriod)
}
