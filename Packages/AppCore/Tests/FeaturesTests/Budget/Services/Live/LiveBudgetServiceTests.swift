import APIClient
import Domain
import Testing

@testable import Features

@Suite("LiveBudgetService")
struct LiveBudgetServiceTests {
    @Test("reads the server spending, goal posts and adjusted period")
    func readsBudget() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/budgets/current": ok(budgetJSON)])

        let budget = try await LiveBudgetService(api: api).currentBudget()

        #expect(budget.income == 1_000_000 && budget.remaining == 100_000)
        #expect(budget.allocated == 1_200_000 && budget.spent == 900_000 && budget.isOverallocated)
        #expect(budget.isConfigured && budget.payday == Payday(day: 25))
        #expect(
            budget.allocations == [
                BudgetAllocation(category: .food, amount: 1_200_000, spent: 900_000, nearLimit: true)
            ])
        #expect(budget.period.start == CalendarDay(year: 2026, month: 9, day: 25))
        #expect(budget.period.end == CalendarDay(year: 2026, month: 10, day: 24))
        #expect(budget.period.daysUntilPayday == 8)
        #expect(budget.goalPosts.first?.name == "Dana Darurat")
        #expect(
            budget.goalPosts.first?.milestones == [
                BudgetGoalMilestone(amount: 500_000, label: "Bulan pertama", reached: true)
            ])
        #expect(await transport.routes == ["GET /api/budgets/current"])
    }
}

private let budgetJSON =
    #"{"configured":true,"income":1000000,"remaining":100000,"allocations":[{"category":"food",""#
    + #"amount":1200000,"spent":900000,"nearLimit":true}],"totalAllocated":1200000,"overAllocated""#
    + #":true,"goalPosts":[{"category":"emergency_fund","name":"Dana Darurat","currentAmount":5000"#
    + #"00,"targetAmount":1000000,"milestones":[{"amount":500000,"label":"Bulan pertama","reached""#
    + #":true}]}],"payday":{"requested":{"type":"day","day":25},"adjustedDate":"2026-10-26","perio"#
    + #"dStart":"2026-09-25","periodEnd":"2026-10-24","nextPayday":"2026-10-26","daysUntilPayday":"#
    + #"8}}"#
