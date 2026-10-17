import APIClient
import Domain
import Features
import Foundation

/** Tagihan & Cicilan's bills from memory; `failing` makes `bills()` throw it. */
actor FakeBillService: BillService {
    private var overview: BillOverview
    private var failing: AppProblem?

    init(overview: BillOverview = BillFixtures.board) {
        self.overview = overview
    }

    func fail(with problem: AppProblem?) {
        failing = problem
    }

    func bills() async throws -> BillOverview {
        if let failing { throw failing }
        return overview
    }
}

/** The board's six bills (Tagihan), as of 15 October 2026. */
enum BillFixtures {
    static let today = CalendarDay(year: 2026, month: 10, day: 15)

    static let electricity = Bill(
        id: "listrik", name: "Listrik Token", kind: .bill, category: "bills", amount: 300_000, isEstimate: true,
        dueOn: CalendarDay(year: 2026, month: 1, day: 20), dueDay: 20, nextDueOn: CalendarDay(year: 2026, month: 10, day: 20))
    static let internet = Bill(
        id: "internet", name: "Internet Rumah", kind: .bill, category: "household", amount: 350_000,
        dueOn: CalendarDay(year: 2026, month: 1, day: 22), dueDay: 22, nextDueOn: CalendarDay(year: 2026, month: 10, day: 22))
    static let paylaterA = Bill(
        id: "paylater-a", name: "Paylater A", kind: .instalment, category: "paylater_instalment", amount: 210_000,
        dueOn: CalendarDay(year: 2026, month: 5, day: 25), dueDay: 25, nextDueOn: CalendarDay(year: 2026, month: 10, day: 25),
        debtId: "debt-a", remainingInstalments: 2)
    static let motorbike = Bill(
        id: "motor", name: "Cicilan Motor", kind: .instalment, category: "transport", amount: 910_000,
        dueOn: CalendarDay(year: 2025, month: 12, day: 28), dueDay: 28, nextDueOn: CalendarDay(year: 2026, month: 10, day: 28),
        debtId: "debt-motor", remainingInstalments: 14)
    static let paylaterB = Bill(
        id: "paylater-b", name: "Paylater B", kind: .instalment, category: "paylater_instalment", amount: 230_000,
        dueOn: CalendarDay(year: 2026, month: 6, day: 5), dueDay: 5, nextDueOn: CalendarDay(year: 2026, month: 11, day: 5),
        debtId: "debt-b")
    static let bpjs = Bill(
        id: "bpjs", name: "BPJS Kesehatan", kind: .bill, category: "insurance", amount: 150_000,
        dueOn: CalendarDay(year: 2026, month: 1, day: 10), dueDay: 10, nextDueOn: CalendarDay(year: 2026, month: 11, day: 10),
        paidThisPeriod: true)

    static let board = BillOverview(
        count: 6, monthlyTotal: 2_150_000,
        sections: [
            BillSection(group: .nextSevenDays, bills: [electricity, internet]),
            BillSection(group: .thisMonth, bills: [paylaterA, motorbike]),
            BillSection(group: .nextMonth, bills: [paylaterB, bpjs]),
        ])
}
