import Testing

@testable import Domain

@Suite("Bill")
struct BillTests {
    @Test("a bill repeats monthly, is exact, unpaid and without a debt unless told otherwise")
    func defaults() {
        let day = CalendarDay(year: 2026, month: 10, day: 20)
        let bill = Bill(
            id: "b", name: "Listrik", kind: .bill, category: "bills", amount: 300_000, dueOn: day, dueDay: 20,
            nextDueOn: day)
        #expect(bill.repeats == .monthly && !bill.isEstimate && !bill.paidThisPeriod)
        #expect(bill.debtId == nil && bill.remainingInstalments == nil)
        #expect(BillGroup.nextSevenDays.rawValue == "next7Days" && BillGroup.allCases.count == 4)
        #expect(BillRepeat.allCases.map(\.rawValue) == ["once", "monthly", "yearly"])
        #expect(BillKind(rawValue: "instalment") == .instalment)
        let section = BillSection(group: .later, bills: [bill])
        #expect(BillOverview(count: 1, monthlyTotal: 25_000, sections: [section]).sections.first?.bills == [bill])
    }
}
