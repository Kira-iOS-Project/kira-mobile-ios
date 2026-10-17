import Domain
import Testing

@Suite("Budget overview values")
struct BudgetTests {
    @Test("near limit starts at 90 percent and progress stays capped")
    func categoryUsage() {
        let below = BudgetAllocation(category: .food, amount: 1_000, spent: 899)
        let threshold = BudgetAllocation(category: .food, amount: 1_000, spent: 900)
        let exceeded = BudgetAllocation(category: .food, amount: 1_000, spent: 1_200)
        let zero = BudgetAllocation(category: .food, amount: 0, spent: 5)
        #expect(!below.isNearLimit)
        #expect(threshold.isNearLimit)
        #expect(exceeded.isNearLimit)
        #expect(exceeded.progress == 1)
        #expect(zero.progress == 0)
        #expect(!zero.isNearLimit)
        #expect(!BudgetAllocation(category: .food, amount: 1_000, spent: 950, nearLimit: false).isNearLimit)
        #expect(BudgetAllocation(category: .food, amount: 1_000, spent: 10, nearLimit: true).isNearLimit)
    }

    @Test("negative amounts clamp and overview totals use the server values")
    func overviewValues() {
        let allocation = BudgetAllocation(category: .food, amount: -1, spent: -2)
        #expect(allocation.amount == 0)
        #expect(allocation.spent == 0)
        let period = PayPeriod(
            start: CalendarDay(year: 2026, month: 1, day: 31),
            end: CalendarDay(year: 2026, month: 2, day: 27), daysUntilPayday: 4)
        let overview = BudgetOverview(
            income: 2_000, remaining: 700,
            goalPosts: [
                BudgetGoalPost(
                    category: "emergency_fund", name: "Dana Darurat", currentAmount: 500,
                    targetAmount: 1_000,
                    milestones: [BudgetGoalMilestone(amount: 500, label: "Pertama", reached: true)]
                )
            ],
            payday: .endOfMonth, period: period,
            allocations: [BudgetAllocation(category: .food, amount: 1_000, spent: 300)])
        #expect(overview.allocated == 1_000)
        #expect(overview.spent == 300)
        #expect(overview.remaining == 700)
        #expect(overview.isConfigured)
        #expect(!overview.isOverallocated)
        #expect(overview.goalPosts.first?.category == "emergency_fund")
        #expect(overview.goalPosts.first?.name == "Dana Darurat")
        #expect(overview.goalPosts.first?.currentAmount == 500)
        #expect(overview.goalPosts.first?.targetAmount == 1_000)
        #expect(overview.goalPosts.first?.milestones.first?.amount == 500)
        #expect(overview.goalPosts.first?.milestones.first?.label == "Pertama")
        #expect(overview.goalPosts.first?.milestones.first?.reached == true)
        let setup = BudgetOverview(
            income: 2_000, payday: .endOfMonth, period: period, allocations: [], isConfigured: false)
        #expect(!setup.isConfigured)
        #expect(setup.income == 2_000)
        #expect(setup.remaining == 2_000)
        #expect(setup.goalPosts.isEmpty)
        let negativeIncome = BudgetOverview(income: -1, payday: .endOfMonth, period: period, allocations: [])
        #expect(negativeIncome.income == 0)
        #expect(negativeIncome.remaining == 0)
    }
}
