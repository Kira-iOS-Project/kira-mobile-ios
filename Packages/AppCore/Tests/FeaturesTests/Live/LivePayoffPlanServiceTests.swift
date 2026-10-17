import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LivePayoffPlanService")
struct LivePayoffPlanServiceTests {
    private let planJSON = #"""
        {"id":"plan-1","method":"snowball","extraPayment":0,"startedAt":"2026-10-10T03:00:00.000Z",\#
        "accounts":[\#
        {"id":"a-1","kind":"paylater","name":"Paylater A","remaining":420000,"original":600000,\#
        "progressPercent":30,"monthlyInstalment":210000,"annualInterestRate":24,"dueDay":5,"status":"in_progress"},\#
        {"id":"m-1","kind":"vehicle","name":"Cicilan Motor","remaining":13000000,"original":15000000,\#
        "progressPercent":13,"monthlyInstalment":850000,"status":"ongoing"}],\#
        "nextPayment":{"debtId":"a-1","name":"Paylater A","amount":210000,"instalment":210000,"extra":0,\#
        "dueDate":"2026-11-05","daysLeft":20}}
        """#

    private let settledJSON = #"""
        {"debtId":"a-1","monthlyInstalment":210000,"paid":420000,"remaining":0,"progressPercent":100,"paidOff":true,\#
        "nextAccount":{"id":"a-2","name":"Pinjol B"},\#
        "scoreEstimate":{"before":66,"after":72,"consumerDebtBefore":50,"consumerDebtAfter":80}}
        """#

    private let partJSON = #"""
        {"debtId":"a-1","monthlyInstalment":210000,"paid":210000,"remaining":210000,"progressPercent":65,\#
        "paidOff":false,"nextAccount":null,"scoreEstimate":null}
        """#

    private func expectedPlan() -> [PlanAccount] {
        [
            PlanAccount(
                id: "a-1", kind: .paylater, name: "Paylater A", remaining: 420_000, original: 600_000,
                progressPercent: 30, monthlyInstalment: 210_000, annualInterestRate: 24, dueDay: 5,
                status: .inProgress),
            PlanAccount(
                id: "m-1", kind: .vehicle, name: "Cicilan Motor", remaining: 13_000_000, original: 15_000_000,
                progressPercent: 13, monthlyInstalment: 850_000, annualInterestRate: nil, dueDay: nil,
                status: .ongoing),
        ]
    }

    @Test("GET /payoff/plans/active becomes the Domain's plan")
    func active() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/payoff/plans/active": ok(planJSON)])
        let plan = try await LivePayoffPlanService(api: api).active()
        #expect(plan.id == "plan-1" && plan.method == .snowball && plan.extraPayment == 0)
        #expect(plan.startedAt == Date(timeIntervalSince1970: 1_791_601_200))
        #expect(plan.accounts == expectedPlan())
        #expect(
            plan.nextPayment
                == NextPayment(debtId: "a-1", name: "Paylater A", amount: 210_000, dueDate: "2026-11-05", daysLeft: 20))
    }

    @Test("a missing plan reaches the model with its code")
    func noPlan() async {
        let (api, _) = KiraAPI.routed(["GET /api/payoff/plans/active": problem("PAYOFF_PLAN_NOT_FOUND", status: 404)])
        await #expect(throws: AppProblem.self) { try await LivePayoffPlanService(api: api).active() }
    }

    @Test("POST /payoff/plans sends the method and the extra payment")
    func create() async throws {
        let (api, transport) = KiraAPI.routed(["POST /api/payoff/plans": ok(planJSON, status: 201)])
        let plan = try await LivePayoffPlanService(api: api).create(method: .avalanche, extraPayment: 150_000)
        #expect(await transport.sent.first?.json == ["method": .string("avalanche"), "extraPayment": .number(150_000)])
        #expect(plan.id == "plan-1")
    }

    @Test("PATCH /payoff/plans/active sends the account to focus on")
    func setFocus() async throws {
        let (api, transport) = KiraAPI.routed(["PATCH /api/payoff/plans/active": ok(planJSON)])
        let plan = try await LivePayoffPlanService(api: api).setFocus(debtId: "a-2")
        #expect(await transport.sent.first?.json == ["focusDebtId": .string("a-2")])
        #expect(plan.focus?.id == "a-1")
    }

    @Test("a payment that settles the account carries the next account and the score estimate")
    func settled() async throws {
        let (api, transport) = KiraAPI.routed(["POST /api/debts/a-1/payments": ok(settledJSON)])
        let service = LivePayoffPlanService(api: api)
        let payment = try await service.recordPayment(debtId: "a-1", amount: 420_000, paymentId: "p-1")
        #expect(await transport.sent.first?.json == ["amount": .number(420_000), "paymentId": .string("p-1")])
        #expect(payment.paidOff && payment.remaining == 0 && payment.progressPercent == 100)
        #expect(payment.nextAccount == NextAccount(id: "a-2", name: "Pinjol B"))
        #expect(
            payment.scoreEstimate
                == ScoreEstimate(before: 66, after: 72, consumerDebtBefore: 50, consumerDebtAfter: 80))
    }

    @Test("a part payment has no next account and no estimate")
    func part() async throws {
        let (api, _) = KiraAPI.routed(["POST /api/debts/a-1/payments": ok(partJSON)])
        let service = LivePayoffPlanService(api: api)
        let payment = try await service.recordPayment(debtId: "a-1", amount: 210_000, paymentId: "p-2")
        #expect(!payment.paidOff && payment.paid == 210_000 && payment.remaining == 210_000)
        #expect(payment.nextAccount == nil && payment.scoreEstimate == nil)
    }
}
