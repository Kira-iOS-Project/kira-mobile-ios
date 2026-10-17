import Domain
import Testing

@Suite("BudgetReading")
struct BudgetReadingTests {
    private func overview(
        income: Int = 7_500_000, remaining: Int = 1_840_000, days: Int = 10, allocations: [BudgetAllocation] = []
    ) -> BudgetOverview {
        BudgetOverview(
            income: income, remaining: remaining,
            period: PayPeriod(
                start: CalendarDay(year: 2026, month: 9, day: 25), end: CalendarDay(year: 2026, month: 10, day: 24),
                daysUntilPayday: days),
            allocations: allocations)
    }

    @Test("the board's hero: Rp184.000,00 a day, Rp5.660.000,00 used, 75% of the pay")
    func hero() {
        let board = overview()
        #expect(board.perDay == 184_000 && board.used == 5_660_000 && board.spentPercent == 75)
    }

    @Test("payday today spreads over one day; nothing left gives nothing a day and all the pay used")
    func heroEdges() {
        #expect(overview(days: 0).perDay == 1_840_000)
        let over = overview(remaining: -200_000)
        #expect(over.perDay == 0 && over.used == 7_700_000 && over.spentPercent == 102)
        let noPay = overview(income: 0, remaining: 0)
        #expect(noPay.spentPercent == 0 && noPay.used == 0)
        #expect(overview(income: 1_000, remaining: 5_000).used == 0)
    }

    @Test("masih aman while every category is within its plan, spent equal to the plan included")
    func withinPlan() {
        let exact = BudgetAllocation(category: .food, amount: 1_000, spent: 1_000)
        #expect(overview(allocations: [exact]).isWithinPlan)
        #expect(overview().isWithinPlan)
        let past = BudgetAllocation(category: .shopping, amount: 1_000, spent: 1_001)
        #expect(!overview(allocations: [exact, past]).isWithinPlan)
    }

    @Test("Tagihan fully spent is Lunas; other categories at 90% show what is left, never below zero")
    func rowTags() {
        #expect(BudgetAllocation(category: .bills, amount: 850_000, spent: 850_000).rowTag == .paid)
        #expect(BudgetAllocation(category: .bills, amount: 850_000, spent: 900_000).isPaidBill)
        #expect(BudgetAllocation(category: .shopping, amount: 600_000, spent: 540_000).rowTag == .left(60_000))
        #expect(BudgetAllocation(category: .shopping, amount: 600_000, spent: 700_000).rowTag == .left(0))
        #expect(BudgetAllocation(category: .food, amount: 1_800_000, spent: 1_380_000).rowTag == nil)
        #expect(BudgetAllocation(category: .bills, amount: 850_000, spent: 800_000).rowTag == .left(50_000))
        #expect(!BudgetAllocation(category: .bills, amount: 0, spent: 0).isPaidBill)
        #expect(BudgetAllocation(category: .food, amount: 1_000, spent: 1_000).rowTag == .left(0))
    }
}
