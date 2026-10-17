import Domain
import Testing

@Suite("RecurringBill")
struct RecurringBillTests {
    @Test("retains bill and installment fields from the server")
    func fields() {
        let due = CalendarDay(year: 2026, month: 10, day: 22)
        let bill = RecurringBill(
            id: "installment", name: "Paylater A", amount: 105_000, category: "paylater_instalment",
            nextDueDate: due, repeatInterval: "monthly", kind: .debtInstallment,
            installmentsTotal: 6, installmentsRemaining: 2, linkedDebtAccountID: "debt-1",
            linkedDebtName: "Paylater A", isDueSoon: true, isPaidThisPeriod: false)

        #expect(bill.id == "installment")
        #expect(bill.kind == .debtInstallment)
        #expect(bill.installmentsTotal == 6 && bill.installmentsRemaining == 2)
        #expect(bill.linkedDebtAccountID == "debt-1" && bill.linkedDebtName == "Paylater A")
        #expect(bill.isDueSoon && !bill.isPaidThisPeriod)
    }
}
