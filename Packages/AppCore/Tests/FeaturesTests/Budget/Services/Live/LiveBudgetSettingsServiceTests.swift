import APIClient
import Domain
import Testing

@testable import Features

@Suite("LiveBudgetSettingsService")
struct LiveBudgetSettingsServiceTests {
    private let budget =
        #"{"configured":false,"income":7500000,"remaining":7500000,"allocations":[],"totalAllocated":0,"#
        + #""overAllocated":false,"averages":[],"instalmentsMonthly":0,"goalPost":null,"#
        + #""payday":{"requested":{"day":25,"endOfMonth":false},"periodStart":"2026-09-25","#
        + #""periodEnd":"2026-10-24","nextPayday":"2026-10-25","daysUntilPayday":8}}"#

    @Test("reads Atur Budget's setup and saves through PUT /budgets/current")
    func readsAndSaves() async throws {
        let (api, transport) = KiraAPI.routed([
            "GET /api/budgets/current": ok(budget), "PUT /api/budgets/current": ok(budget),
        ])
        let service = LiveBudgetSettingsService(api: api)
        let setup = try await service.budgetSetup()
        #expect(setup.income == 7_500_000 && setup.payday == Payday(day: 25) && setup.goalDeposit == nil)
        try await service.saveBudget(BudgetPlan(payday: setup.payday, allocations: [.food: 1_800_000]))
        #expect(await transport.routes == ["GET /api/budgets/current", "PUT /api/budgets/current"])
    }
}
