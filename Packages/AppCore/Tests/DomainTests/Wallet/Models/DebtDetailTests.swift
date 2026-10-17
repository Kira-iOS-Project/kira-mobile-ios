import Domain
import Testing

@Suite("DebtDetail")
struct DebtDetailTests {
    private func debt(paid: Int?, total: Int?, due: CalendarDay?) -> DebtDetail {
        DebtDetail(
            id: "a", name: "Paylater A", kind: .paylater, remaining: 420_000, totalAmount: 1_260_000,
            paidAmount: 840_000, instalmentsPaid: paid, instalmentsTotal: total, monthlyInstalment: 210_000,
            dueDate: due,
            payments: [
                DebtInstalment(
                    id: "p4", number: 4, amount: 210_000, paidOn: CalendarDay(year: 2026, month: 9, day: 25),
                    onTime: true)
            ],
            nextStep: DebtNextStep(
                priority: 1, priorityOf: 3, extraAmount: 210_000, payOn: nil, monthsEarlier: 1, scoreBefore: nil,
                scoreAfter: nil))
    }

    @Test("the instalments left, never below zero, and none without a fixed count")
    func instalmentsLeft() {
        let due = CalendarDay(year: 2026, month: 10, day: 25)
        #expect(debt(paid: 4, total: 6, due: due).instalmentsLeft == 2)
        #expect(debt(paid: 7, total: 6, due: due).instalmentsLeft == 0)
        #expect(debt(paid: nil, total: 6, due: due).instalmentsLeft == nil)
    }

    @Test("days to the due date, as Jatuh Tempo's tag counts them")
    func daysUntilDue() {
        let full = debt(paid: 4, total: 6, due: CalendarDay(year: 2026, month: 10, day: 25))
        #expect(full.daysUntilDue(from: CalendarDay(year: 2026, month: 10, day: 15)) == 10)
        let undated = debt(paid: 4, total: 6, due: nil)
        #expect(undated.daysUntilDue(from: CalendarDay(year: 2026, month: 10, day: 15)) == nil)
        #expect(full.payments.first?.onTime == true && full.nextStep?.payOn == nil && full.id == "a")
    }
}
