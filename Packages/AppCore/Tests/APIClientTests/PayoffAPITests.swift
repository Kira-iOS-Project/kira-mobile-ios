/** The payoff calls: simulating, making the plan, reading it, moving its focus, marking a payment. */
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private struct PlanBody: Decodable {
    let method: String
    let extraPayment: Int?
}

private struct FocusBody: Decodable { let focusDebtId: String }

private struct PaymentBody: Decodable { let amount: Int }

@Suite("PayoffAPI")
struct PayoffAPITests {
    @Test("simulates a plan: order, months, interest, productive debts and the comparison")
    func simulates() async throws {
        let (api, transport) = KiraAPI.canned(json: payoffPlanJSON)
        let plan = try await api.simulatePayoff(method: .snowball, extraPayment: 200_000)
        #expect(plan.method == .snowball && plan.extraPayment == 200_000 && plan.maxExtraPayment == 1_840_000)
        #expect(plan.monthlyBudget == 700_000 && plan.hasUnknownRate)
        let first = try #require(plan.accounts.first)
        #expect(first.id == "00000000-0000-4000-8000-000000000001" && first.kind == .paylater)
        #expect(first.annualInterestRate == 24 && first.dueDay == 5 && first.position == 1)
        #expect(first.months == 2 && first.payoffMonth == "2026-11" && first.interest == 6_400)
        let second = try #require(plan.accounts.last)
        #expect(second.kind == .onlineLoan && second.annualInterestRate == nil && second.dueDay == nil)
        #expect(second.months == nil && second.payoffMonth == nil && second.interest == nil)
        #expect(plan.productive.map(\.name) == ["Cicilan Motor"] && plan.productive.first?.kind == .vehicle)
        #expect(plan.totalInterest == nil && plan.allPaidMonths == nil && plan.allPaidMonth == nil)
        let comparison = try #require(plan.comparison)
        #expect(comparison.otherMethod == .avalanche && comparison.interestSaved == -1_200)
        #expect(comparison.firstPayoffMonthsLater == 1)
        let sent = try #require(await transport.request)
        #expect(sent.path == "/api/payoff/simulate" && sent.method == .post)
        let body = try sent.decoded(PlanBody.self)
        #expect(body.method == "snowball" && body.extraPayment == 200_000)
    }

    @Test("a person without consumer debt gets an empty plan and no comparison")
    func simulatesNothing() async throws {
        let (api, _) = KiraAPI.canned(json: emptyPayoffPlanJSON)
        let plan = try await api.simulatePayoff(method: .avalanche, extraPayment: 0)
        #expect(plan.accounts.isEmpty && plan.productive.isEmpty && plan.comparison == nil)
        #expect(plan.method == .avalanche)
    }

    @Test("makes the plan, answered 201, and reads Rencanaku")
    func plans() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: activePlanJSON)
        let plan = try await api.createPayoffPlan(method: .avalanche, extraPayment: 0)
        #expect(plan.id == "00000000-0000-4000-8000-0000000000aa" && plan.method == .snowball)
        #expect(plan.startedAt == Date(timeIntervalSince1970: 1_791_601_200))
        #expect(plan.accounts.map(\.status) == [.inProgress, .ongoing])
        let account = try #require(plan.accounts.first)
        #expect(account.original == 600_000 && account.progressPercent == 30 && account.dueDay == 5)
        #expect(account.annualInterestRate == 24 && plan.accounts.last?.annualInterestRate == nil)
        let next = try #require(plan.nextPayment)
        #expect(next.amount == 210_000 && next.dueDate == "2026-11-05" && next.daysLeft == 20)
        let sent = try #require(await transport.request)
        #expect(sent.path == "/api/payoff/plans" && sent.method == .post)
        #expect(try sent.decoded(PlanBody.self).method == "avalanche")
    }

    @Test("reads the active plan, and moves its focus")
    func readsAndMoves() async throws {
        let (api, transport) = KiraAPI.canned(json: activePlanJSON)
        #expect(try await api.getActivePayoffPlan().accounts.count == 2)
        #expect(try #require(await transport.request).path == "/api/payoff/plans/active")
        let moved = try await api.setPayoffFocus(debtId: "debt-2")
        #expect(moved.nextPayment?.name == "Paylater A")
        let sent = try #require(await transport.request)
        #expect(sent.method == .patch && sent.path == "/api/payoff/plans/active")
        #expect(try sent.decoded(FocusBody.self).focusDebtId == "debt-2")
    }

    @Test("a plan with every consumer account paid has no next payment")
    func noNextPayment() async throws {
        let (api, _) = KiraAPI.canned(json: donePlanJSON)
        #expect(try await api.getActivePayoffPlan().nextPayment == nil)
    }

    @Test("marks a payment, and announces the account it settled with the score estimate")
    func records() async throws {
        let (api, transport) = KiraAPI.canned(json: settledPaymentJSON)
        let settled = try await api.recordDebtPayment(debtId: "debt-1", amount: 420_000)
        #expect(settled.paidOff && settled.remaining == 0 && settled.progressPercent == 100)
        #expect(settled.paid == 420_000 && settled.debtId == "00000000-0000-4000-8000-000000000001")
        #expect(settled.nextAccount == NextAccountDTO(id: "00000000-0000-4000-8000-000000000002", name: "Pinjol B"))
        let estimate = try #require(settled.scoreEstimate)
        #expect(estimate.before == 66 && estimate.after == 72)
        #expect(estimate.consumerDebtBefore == 50 && estimate.consumerDebtAfter == 80)
        let sent = try #require(await transport.request)
        #expect(sent.path == "/api/debts/debt-1/payments" && sent.method == .post)
        #expect(try sent.decoded(PaymentBody.self).amount == 420_000)

        let (partial, _) = KiraAPI.canned(json: partPaymentJSON)
        let part = try await partial.recordDebtPayment(debtId: "debt-1", amount: 210_000)
        #expect(!part.paidOff && part.remaining == 210_000 && part.progressPercent == 65)
        #expect(part.nextAccount == nil && part.scoreEstimate == nil)
    }

    @Test("throws every problem the payoff routes answer")
    func problems() async {
        await expectProblems([400, 401, 422]) { _ = try await $0.simulatePayoff(method: .snowball, extraPayment: 0) }
        await expectProblems([400, 401, 422]) { _ = try await $0.createPayoffPlan(method: .snowball, extraPayment: 0) }
        await expectProblems([401, 404]) { _ = try await $0.getActivePayoffPlan() }
        await expectProblems([401, 404, 422]) { _ = try await $0.setPayoffFocus(debtId: "debt-2") }
        await expectProblems([400, 401, 404, 422]) { _ = try await $0.recordDebtPayment(debtId: "d", amount: 1) }
    }
}
