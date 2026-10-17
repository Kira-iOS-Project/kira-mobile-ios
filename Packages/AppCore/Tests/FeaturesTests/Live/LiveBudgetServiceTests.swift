/** LiveBudgetService maps the current-budget contract into feature values. */
import APIClient
import Domain
import Testing

@testable import Features

@Suite("LiveBudgetService")
struct LiveBudgetServiceTests {
    @Test("reads spending, allocation warning and the resolved period")
    func readsBudget() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/budgets/current": ok(budgetJSON)])

        let budget = try await LiveBudgetService(api: api).currentBudget()

        #expect(budget.income == 1_000_000 && budget.allocated == 1_200_000 && budget.isOverallocated)
        #expect(budget.isConfigured && budget.payday == Payday(day: 25))
        #expect(budget.remaining == 100_000)
        #expect(
            budget.allocations == [
                BudgetAllocation(category: .food, amount: 1_200_000, spent: 900_000, nearLimit: true)
            ])
        #expect(budget.period.start == CalendarDay(year: 2026, month: 9, day: 25))
        #expect(budget.period.end == CalendarDay(year: 2026, month: 10, day: 24))
        #expect(budget.period.daysUntilPayday == 8)
        #expect(await transport.routes == ["GET /api/budgets/current"])
    }

    @Test("reads editor averages from the dedicated endpoint")
    func readsEditContext() async throws {
        let (api, transport) = KiraAPI.routed([
            "GET /api/budgets/current/edit": ok(budgetEditJSON)
        ])

        let context = try await LiveBudgetService(api: api).currentBudgetEdit()

        #expect(context.averagePeriods == 3)
        #expect(context.averages == [BudgetCategoryAverage(category: .food, amount: 450_000)])
        #expect(context.budget.remaining == 100_000)
        #expect(context.budget.goalPosts.first?.name == "Dana Darurat")
        #expect(
            context.budget.goalPosts.first?.milestones == [
                BudgetGoalMilestone(amount: 500_000, label: "Bulan pertama", reached: true)
            ])
        #expect(await transport.routes == ["GET /api/budgets/current/edit"])
    }

    @Test("saves a draft and adopts the server's returned pay period")
    func savesBudget() async throws {
        let (api, transport) = KiraAPI.routed([
            "PUT /api/budgets/current": ok(budgetJSON)
        ])
        let draft = BudgetDraft(income: 1_000_000, payday: .endOfMonth, allocations: [])

        let budget = try await LiveBudgetService(api: api).saveCurrentBudget(draft)

        #expect(budget.payday == Payday(day: 25))
        #expect(budget.period.daysUntilPayday == 8)
        let sent = try #require(await transport.sent.first)
        #expect(sent.json["income"] == .number(1_000_000))
        #expect(sent.json["payday"] == .object(["type": .string("endOfMonth")]))
    }
}

private let budgetJSON =
    #"{"configured":true,"income":1000000,"remaining":100000,"allocations":[{"category":"food","amount":1200000,"spent":900000,"nearLimit":true}],"totalAllocated":1200000,"overAllocated":true,"goalPosts":[],"payday":{"requested":{"type":"day","day":25},"adjustedDate":"2026-10-26","periodStart":"2026-09-25","periodEnd":"2026-10-24","nextPayday":"2026-10-26","daysUntilPayday":8}}"#

private let budgetEditJSON =
    #"{"configured":true,"income":1000000,"remaining":100000,"allocations":[{"category":"food","amount":1200000,"spent":900000,"nearLimit":true}],"totalAllocated":1200000,"overAllocated":true,"goalPosts":[{"category":"emergency_fund","name":"Dana Darurat","currentAmount":500000,"targetAmount":1000000,"milestones":[{"amount":500000,"label":"Bulan pertama","reached":true}]}],"payday":{"requested":{"type":"day","day":25},"adjustedDate":"2026-10-26","periodStart":"2026-09-25","periodEnd":"2026-10-24","nextPayday":"2026-10-26","daysUntilPayday":8},"averagePeriods":3,"averages":[{"category":"food","amount":450000}]}"#
