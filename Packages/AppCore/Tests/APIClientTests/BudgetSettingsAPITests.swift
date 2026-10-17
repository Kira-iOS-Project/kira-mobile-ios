import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

@Suite("Atur Budget's API")
struct BudgetSettingsAPITests {
    /** `GET /budgets/current` on Atur Budget's board, `payday` given. */
    private func budget(payday: String, goalPost: String = "null") -> String {
        #"{"configured":true,"income":7500000,"remaining":7500000,"#
            + #""allocations":[{"category":"food","amount":1800000,"spent":0,"nearLimit":false},"#
            + #"{"category":"food","amount":1900000,"spent":0,"nearLimit":false}],"#
            + #""totalAllocated":1900000,"overAllocated":false,"#
            + #""averages":[{"category":"transport","amount":860000}],"instalmentsMonthly":1350000,"#
            + #""goalPost":\#(goalPost),"payday":{"requested":\#(payday),"#
            + #""periodStart":"2026-09-25","periodEnd":"2026-10-24","nextPayday":"2026-10-25","daysUntilPayday":8}}"#
    }

    @Test("the setup: payday, amounts (the last of a repeated category), averages, instalments, goal deposit")
    func setup() async throws {
        let goal = #"{"goalId":"g-1","monthlyDeposit":650000,"savedAmount":0,"targetAmount":25200000}"#
        let (api, _) = KiraAPI.canned(json: budget(payday: #"{"day":25,"endOfMonth":false}"#, goalPost: goal))
        let setup = try await api.budgetSetup()
        #expect(setup.payday == Payday(day: 25) && setup.income == 7_500_000 && setup.allocations[.food] == 1_900_000)
        #expect(setup.averages[.transport] == 860_000 && setup.instalments == 1_350_000 && setup.goalDeposit == 650_000)
        let (endOfMonth, _) = KiraAPI.canned(json: budget(payday: #"{"day":null,"endOfMonth":true}"#))
        let late = try await endOfMonth.budgetSetup()
        #expect(late.payday.isEndOfMonth && late.goalDeposit == nil)
        let (unset, _) = KiraAPI.canned(json: budget(payday: #"{"endOfMonth":false}"#))
        #expect(try await unset.budgetSetup().payday == Payday(day: Payday.defaultDay))
    }

    @Test("Simpan Budget sends PUT with each category once, sorted, and the payday")
    func save() async throws {
        let (api, transport) = KiraAPI.canned(json: budget(payday: #"{"day":25,"endOfMonth":false}"#))
        try await api.saveBudget(BudgetPlan(payday: .endOfMonth, allocations: [.transport: 900_000, .food: 1_800_000]))
        let request = try #require(await transport.request)
        #expect(request.method == .put)
        #expect(request.text.contains(#""endOfMonth":true"#))
        let order = try #require(request.text.range(of: "food")).lowerBound
        #expect(order < (try #require(request.text.range(of: "transport")).lowerBound))
    }

    @Test("reads and saves pass on the API's problems")
    func problems() async {
        await expectProblems([401, 500]) { _ = try await $0.budgetSetup() }
        await expectProblems([401, 422, 500]) {
            try await $0.saveBudget(BudgetPlan(payday: Payday(day: 1), allocations: [:]))
        }
    }
}
