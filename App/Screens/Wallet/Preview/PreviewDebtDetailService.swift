/**
 Detail Utang on the canvas's sample (board DetailUtang): Paylater A, Rp420.000,00 left of
 Rp1.260.000,00, 4 of 6 instalments, the next due 25 Oktober 2026, prioritas 1 dari 3. `problem`
 answers like the API refusing it, for the failed state.
 */
import APIClient
import Domain
import Features

struct PreviewDebtDetailService: DebtDetailService {
    var problem: AppProblem?

    func debt(id _: String) throws -> DebtDetail {
        if let problem { throw problem }
        return Self.paylaterA
    }

    /** DetailUtang's Paylater A. */
    static let paylaterA = DebtDetail(
        id: "paylater-a", name: "Paylater A", kind: .paylater, remaining: 420_000, totalAmount: 1_260_000,
        paidAmount: 840_000, instalmentsPaid: 4, instalmentsTotal: 6, monthlyInstalment: 210_000,
        dueDate: CalendarDay(year: 2026, month: 10, day: 25),
        payments: (1...4).reversed().map { number in
            DebtInstalment(
                id: "payment-\(number)", number: number, amount: 210_000,
                paidOn: CalendarDay(year: 2026, month: 5 + number, day: 25), onTime: true)
        },
        nextStep: DebtNextStep(
            priority: 1, priorityOf: 3, extraAmount: 210_000, payOn: CalendarDay(year: 2026, month: 10, day: 25),
            scoreBefore: 66, scoreAfter: 71))
}
