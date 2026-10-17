import Domain
import Foundation
import Testing

@Suite("ActivePayoffPlan")
struct ActivePayoffPlanTests {
    private func account(_ id: String, _ status: PlanAccountStatus, remaining: Int, original: Int) -> PlanAccount {
        PlanAccount(
            id: id, kind: .paylater, name: id, remaining: remaining, original: original, progressPercent: 0,
            monthlyInstalment: 1, annualInterestRate: nil, dueDay: nil, status: status)
    }

    private func plan(_ accounts: [PlanAccount]) -> ActivePayoffPlan {
        ActivePayoffPlan(
            id: "p", method: .avalanche, extraPayment: 0, startedAt: Date(timeIntervalSince1970: 0),
            accounts: accounts, nextPayment: nil)
    }

    @Test("the API's spelling of a tag is its raw value")
    func rawValues() {
        #expect(PlanAccountStatus(rawValue: "in_progress") == .inProgress)
        #expect(PlanAccountStatus(rawValue: "next") == .next && PlanAccountStatus(rawValue: "ongoing") == .ongoing)
    }

    @Test("the plan splits into the accounts it pays and the debts it leaves alone, and knows its focus")
    func groups() {
        let paid = plan([
            account("a", .inProgress, remaining: 1, original: 2), account("b", .next, remaining: 2, original: 2),
            account("m", .ongoing, remaining: 9, original: 9),
        ])
        #expect(paid.consumerAccounts.map(\.id) == ["a", "b"])
        #expect(paid.ongoingAccounts.map(\.id) == ["m"])
        #expect(paid.focus?.id == "a")
        #expect(plan([account("m", .ongoing, remaining: 9, original: 9)]).focus == nil)
    }

    @Test("progress counts what is paid of the consumer accounts' original balances, and ignores the rest")
    func progress() {
        let partway = plan([
            account("a", .inProgress, remaining: 420, original: 600),
            account("b", .next, remaining: 400, original: 400),
            account("m", .ongoing, remaining: 1, original: 1_000_000),
        ])
        #expect(partway.progressPercent == 18)
        #expect(plan([]).progressPercent == 0)
        #expect(plan([account("a", .inProgress, remaining: 5, original: 0)]).progressPercent == 0)
    }

    @Test("progress stays between 0 and 100 when a balance grew past its original or is paid")
    func progressBounds() {
        #expect(plan([account("a", .inProgress, remaining: 900, original: 600)]).progressPercent == 0)
        #expect(plan([account("a", .inProgress, remaining: 0, original: 600)]).progressPercent == 100)
    }
}
