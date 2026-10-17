import APIClient
import Domain
import Testing

@testable import Features

@Suite("LiveBudgetService")
struct LiveBudgetServiceTests {
    @Test("reads the server spending and adjusted period; a goal post without a name shows no row")
    func readsBudget() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/budgets/current": ok(budgetJSON)])

        let budget = try await LiveBudgetService(api: api).currentBudget()

        #expect(budget.income == 1_000_000 && budget.remaining == 100_000)
        #expect(budget.isConfigured)
        #expect(
            budget.allocations == [
                BudgetAllocation(category: .food, amount: 1_200_000, spent: 900_000, nearLimit: true)
            ])
        #expect(budget.period.start == CalendarDay(year: 2026, month: 9, day: 25))
        #expect(budget.period.end == CalendarDay(year: 2026, month: 10, day: 24))
        #expect(budget.period.daysUntilPayday == 8)
        #expect(budget.goalPosts.isEmpty)
        #expect(await transport.routes == ["GET /api/budgets/current"])
    }
}

private let budgetJSON =
    #"{"configured":true,"income":1000000,"remaining":100000,"allocations":[{"category":"food","amount":"#
    + #"1200000,"spent":900000,"nearLimit":true}],"totalAllocated":1200000,"overAllocated":true,"averages"#
    + #"":[],"instalmentsMonthly":0,"goalPost":{"goalId":"7d1f0c9e-3b2a-4c8e-9f10-2a3b4c5d6e7f","monthlyDe"#
    + #"posit":500000,"savedAmount":500000,"targetAmount":1000000},"payday":{"requested":{"day":25,"endOfM"#
    + #"onth":false},"periodStart":"2026-09-25","periodEnd":"2026-10-24","nextPayday":"2026-10-26","daysU"#
    + #"ntilPayday":8}}"#
