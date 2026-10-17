import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

@Suite("FinanceAPI budget editing")
struct FinanceAPIBudgetEditTests {
    @Test("maps averages for complete prior periods")
    func editContext() async throws {
        let (api, transport) = KiraAPI.canned(json: editJSON)
        let context = try await api.getCurrentBudgetEdit()
        #expect(context.averagePeriods == 2)
        #expect(context.averages == [BudgetCategoryAverage(category: .food, amount: 400)])
        #expect(context.budget.income == 1_000 && context.budget.period.daysUntilPayday == 3)
        let request = try #require(await transport.request)
        #expect(request.method == .get && request.path == "/api/budgets/current/edit")

        await expectProblems([401]) { _ = try await $0.getCurrentBudgetEdit() }
    }

    @Test("saves day and end-of-month choices with allocation amounts")
    func save() async throws {
        let dayDraft = BudgetDraft(
            income: 1_000, payday: Payday(day: 31),
            allocations: [BudgetAllocation(category: .food, amount: 1_200)])
        let (dayAPI, dayTransport) = KiraAPI.canned(json: budgetJSON)
        let saved = try await dayAPI.updateCurrentBudget(dayDraft)
        #expect(saved.payday == Payday(day: 25) && saved.period.daysUntilPayday == 3)
        let dayRequest = try #require(await dayTransport.request)
        let dayBody = try #require(JSONSerialization.jsonObject(with: Data(dayRequest.text.utf8)) as? [String: Any])
        let dayPayday = try #require(dayBody["payday"] as? [String: Any])
        #expect(dayPayday["type"] as? String == "day" && dayPayday["day"] as? Int == 31)
        #expect((dayBody["allocations"] as? [[String: Any]])?.first?["amount"] as? Int == 1_200)

        var monthDraft = dayDraft
        monthDraft.payday = .endOfMonth
        let (monthAPI, monthTransport) = KiraAPI.canned(json: budgetJSON)
        _ = try await monthAPI.updateCurrentBudget(monthDraft)
        let monthRequest = try #require(await monthTransport.request)
        let monthBody = try #require(JSONSerialization.jsonObject(with: Data(monthRequest.text.utf8)) as? [String: Any])
        #expect((monthBody["payday"] as? [String: Any])?["type"] as? String == "endOfMonth")

        await expectProblems([401, 422]) { _ = try await $0.updateCurrentBudget(dayDraft) }
    }
}

private let budgetJSON =
    #"{"configured":true,"income":1000,"remaining":700,"allocations":[{"category":"food","amount":1200,"spent":300,"nearLimit":false}],"totalAllocated":1200,"overAllocated":true,"goalPosts":[],"payday":{"requested":{"type":"day","day":25},"adjustedDate":"2026-10-26","periodStart":"2026-09-25","periodEnd":"2026-10-24","nextPayday":"2026-10-26","daysUntilPayday":3}}"#
private let editJSON =
    #"{"configured":true,"income":1000,"remaining":700,"allocations":[{"category":"food","amount":1200,"spent":300,"nearLimit":false}],"totalAllocated":1200,"overAllocated":true,"goalPosts":[],"payday":{"requested":{"type":"day","day":25},"adjustedDate":"2026-10-26","periodStart":"2026-09-25","periodEnd":"2026-10-24","nextPayday":"2026-10-26","daysUntilPayday":3},"averagePeriods":2,"averages":[{"category":"food","amount":400}]}"#
