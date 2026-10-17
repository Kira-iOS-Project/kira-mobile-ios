import Testing

@testable import Domain

@Suite("Payday's period")
struct PaydayPeriodTests {
    private func day(_ year: Int, _ month: Int, _ day: Int) -> CalendarDay {
        CalendarDay(year: year, month: month, day: day)
    }

    @Test("Atur Budget's board: payday the 25th, on 17 Oktober, is 25 September – 24 Oktober 2026")
    func board() {
        let period = Payday(day: 25).period(containing: day(2026, 10, 17))
        #expect(period.start == day(2026, 9, 25) && period.end == day(2026, 10, 24))
        #expect(period.daysUntilPayday == 8)
    }

    @Test("on the payday itself the new period starts; a day past a short month's end is its last day")
    func edges() {
        let onPayday = Payday(day: 25).period(containing: day(2026, 10, 25))
        #expect(onPayday.start == day(2026, 10, 25) && onPayday.daysUntilPayday == 31)
        let february = Payday(day: 31).period(containing: day(2027, 2, 28))
        #expect(february.start == day(2027, 2, 28) && february.end == day(2027, 3, 30))
    }

    @Test("Gajian di akhir bulan is the last day of every month, February included")
    func endOfMonth() {
        let period = Payday.endOfMonth.period(containing: day(2027, 2, 10))
        #expect(period.start == day(2027, 1, 31) && period.end == day(2027, 2, 27))
        #expect(Payday.endOfMonth.day(inMonth: 12, of: 2026) == day(2026, 12, 31))
    }
}

@Suite("BudgetSetup")
struct BudgetSetupTests {
    @Test("the board's five categories first, then other expenses in use; incomes never")
    func categories() {
        let setup = BudgetSetup(
            income: -5, payday: Payday(day: 25), allocations: [.health: 100_000, .salary: 1],
            averages: [.coffee: 50_000], instalments: -1)
        #expect(setup.categories == BudgetSetup.standard + [.coffee, .health])
        #expect(setup.income == 0 && setup.instalments == 0 && setup.goalDeposit == nil)
        let plan = BudgetPlan(payday: .endOfMonth, allocations: [.food: 1])
        #expect(plan.payday.isEndOfMonth && plan.allocations[.food] == 1)
    }
}
