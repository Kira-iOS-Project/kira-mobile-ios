/** The board's six bills (Tagihan): what previews, the launcher and the loading placeholder show. */
import Domain

nonisolated enum BillsPreviewData {
    /** Rp2.150.000,00 a month in three groups, as on the board. */
    static let board = BillOverview(
        count: 6, monthlyTotal: 2_150_000,
        sections: [
            BillSection(group: .nextSevenDays, bills: [electricity, internet]),
            BillSection(group: .thisMonth, bills: [paylaterA, motorbike]),
            BillSection(group: .nextMonth, bills: [paylaterB, bpjs]),
        ])

    private static let electricity = Bill(
        id: "listrik", name: "Listrik Token", kind: .bill, category: "bills", amount: 300_000, isEstimate: true,
        dueOn: day(1, 20), dueDay: 20, nextDueOn: day(10, 20))
    private static let internet = Bill(
        id: "internet", name: "Internet Rumah", kind: .bill, category: "household", amount: 350_000,
        dueOn: day(1, 22), dueDay: 22, nextDueOn: day(10, 22))
    private static let paylaterA = Bill(
        id: "paylater-a", name: "Paylater A", kind: .instalment, category: "paylater_instalment", amount: 210_000,
        dueOn: day(5, 25), dueDay: 25, nextDueOn: day(10, 25), debtId: "debt-paylater-a")
    private static let motorbike = Bill(
        id: "motor", name: "Cicilan Motor", kind: .instalment, category: "transport", amount: 910_000,
        dueOn: day(1, 28), dueDay: 28, nextDueOn: day(10, 28), debtId: "debt-motor", remainingInstalments: 14)
    private static let paylaterB = Bill(
        id: "paylater-b", name: "Paylater B", kind: .instalment, category: "paylater_instalment", amount: 230_000,
        dueOn: day(6, 5), dueDay: 5, nextDueOn: day(11, 5), debtId: "debt-paylater-b")
    private static let bpjs = Bill(
        id: "bpjs", name: "BPJS Kesehatan", kind: .bill, category: "insurance", amount: 150_000,
        dueOn: day(1, 10), dueDay: 10, nextDueOn: day(11, 10), paidThisPeriod: true)

    private static func day(_ month: Int, _ day: Int) -> CalendarDay {
        CalendarDay(year: 2026, month: month, day: day)
    }
}
