import Domain
import Features

/** Sample recurring bills used by previews and the debug screen launcher. */
nonisolated struct PreviewBillsService: BillsService {
    static let samples = [
        RecurringBill(
            id: "internet", name: "Internet Rumah", amount: 350_000, category: "bills",
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 22), repeatInterval: "monthly", kind: .bill,
            isDueSoon: true),
        RecurringBill(
            id: "paylater", name: "Cicilan Paylater", amount: 105_000, category: "paylater_instalment",
            nextDueDate: CalendarDay(year: 2026, month: 10, day: 24), repeatInterval: "monthly",
            kind: .debtInstallment, installmentsTotal: 6, installmentsRemaining: 2,
            linkedDebtAccountID: "debt-preview", linkedDebtName: "Paylater", isDueSoon: true),
    ]

    func bills() async throws -> [RecurringBill] { Self.samples }
}
