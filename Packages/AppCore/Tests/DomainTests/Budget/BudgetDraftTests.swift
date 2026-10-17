import Domain
import Testing

@Suite("Budget drafts and edit context")
struct BudgetDraftTests {
    @Test("clamps income and category amounts and supports allocation edits")
    func draftValues() {
        var draft = BudgetDraft(
            income: -1, payday: Payday(day: 31),
            allocations: [BudgetAllocation(category: .food, amount: -5)])
        #expect(draft.income == 0 && draft.allocated == 0 && !draft.isOverallocated)

        draft.setIncome(10)
        draft.setAmount(15, for: .food)
        draft.setAmount(4, for: .transport)
        #expect(draft.allocations.map(\.amount) == [15, 4])
        #expect(draft.allocated == 19 && draft.isOverallocated)

        draft.setAmount(2, for: .food)
        #expect(draft.allocations.map(\.amount) == [2, 4])
        #expect(!draft.isOverallocated)
    }

    @Test("clamps average period count and negative average amounts")
    func editContextValues() {
        let budget = BudgetOverview(
            income: 100, payday: Payday(day: 25),
            period: PayPeriod(
                start: CalendarDay(year: 2026, month: 9, day: 25),
                end: CalendarDay(year: 2026, month: 10, day: 24), daysUntilPayday: 1),
            allocations: [])
        let context = BudgetEditContext(
            budget: budget, averagePeriods: 9,
            averages: [BudgetCategoryAverage(category: .food, amount: -30)])
        #expect(context.averagePeriods == 3)
        #expect(context.averages == [BudgetCategoryAverage(category: .food, amount: 0)])
        #expect(BudgetEditContext(budget: budget, averagePeriods: -2, averages: []).averagePeriods == 0)
    }
}
