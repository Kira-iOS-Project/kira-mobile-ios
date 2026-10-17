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
        {"id":"p-1","kind":"online_loan","name":"Pinjol Lama","remaining":0,"original":300000,\#
        "progressPercent":100,"monthlyInstalment":150000,"annualInterestRate":null,"dueDay":null,\#
        "status":"paid_off","payoffMonth":"2026-10","payoffDate":"2026-10-05","startMonth":null},\#
        {"id":"a-1","kind":"paylater","name":"Paylater A","remaining":420000,"original":600000,\#
        "progressPercent":30,"monthlyInstalment":210000,"annualInterestRate":24,"dueDay":5,\#
        "status":"in_progress","payoffMonth":"2026-12","payoffDate":"2026-12-05","startMonth":null},\#
        {"id":"m-1","kind":"vehicle","name":"Cicilan Motor","remaining":13000000,"original":15000000,\#
        "progressPercent":13,"monthlyInstalment":850000,"annualInterestRate":null,"dueDay":null,\#
        "status":"ongoing","payoffMonth":null,"payoffDate":null,"startMonth":null}],\#
        "nextPayment":{"debtId":"a-1","name":"Paylater A","amount":260000,"instalment":210000,"extra":50000,\#
        "dueDate":"2026-11-05","daysLeft":20}}
        """#

    @Test("GET /payoff/plans/active becomes the Domain's plan, paid accounts first, with their months")
    func active() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/payoff/plans/active": ok(planJSON)])
        let plan = try await LivePayoffPlanService(api: api).active()
        #expect(plan.id == "plan-1" && plan.method == .snowball && plan.extraPayment == 0)
        #expect(plan.startedAt == Date(timeIntervalSince1970: 1_791_601_200))
        #expect(plan.accounts.map(\.status) == [.paidOff, .inProgress, .ongoing])
        #expect(plan.accounts.map(\.kind) == [.onlineLoan, .paylater, .vehicle])
        let paid = try #require(plan.accounts.first)
        #expect(paid.remaining == 0 && paid.payoffMonth == "2026-10" && paid.payoffDate == "2026-10-05")
        #expect(paid.annualInterestRate == nil && paid.dueDay == nil && paid.startMonth == nil)
        let current = plan.accounts[1]
        #expect(current.annualInterestRate == 24 && current.dueDay == 5 && current.payoffMonth == "2026-12")
        #expect(
            plan.nextPayment
                == NextPayment(
                    debtId: "a-1", name: "Paylater A", amount: 260_000, instalment: 210_000, extra: 50_000,
                    dueDate: "2026-11-05", daysLeft: 20))
        #expect(plan.position(of: "a-1") == 2)
    }

    @Test("a plan with every consumer account paid has no next payment")
    func noNextPayment() async throws {
        let done = planJSON.replacingOccurrences(
            of: #""nextPayment":\{[^}]*\}"#, with: #""nextPayment":null"#, options: .regularExpression)
        let (api, _) = KiraAPI.routed(["GET /api/payoff/plans/active": ok(done)])
        #expect(try await LivePayoffPlanService(api: api).active().nextPayment == nil)
    }

    @Test("an account status the app does not know is a problem, not a crash")
    func unknownStatus() async {
        let odd = planJSON.replacingOccurrences(of: #""status":"ongoing""#, with: #""status":"frozen""#)
        let (api, _) = KiraAPI.routed(["GET /api/payoff/plans/active": ok(odd)])
        await #expect(throws: (any Error).self) { try await LivePayoffPlanService(api: api).active() }
    }

    @Test("a missing plan reaches the model with its code")
    func noPlan() async {
        let (api, _) = KiraAPI.routed(["GET /api/payoff/plans/active": problem("PAYOFF_PLAN_NOT_FOUND", status: 404)])
        let error = await #expect(throws: AppProblem.self) { try await LivePayoffPlanService(api: api).active() }
        #expect(error?.knownCode == .payoffPlanNotFound)
    }

    @Test("POST /payoff/plans sends the method and the extra payment")
    func create() async throws {
        let (api, transport) = KiraAPI.routed(["POST /api/payoff/plans": ok(planJSON, status: 201)])
        let plan = try await LivePayoffPlanService(api: api).create(method: .avalanche, extraPayment: 150_000)
        #expect(await transport.sent.first?.json == ["method": .string("avalanche"), "extraPayment": .number(150_000)])
        #expect(plan.id == "plan-1")
    }

    @Test("PATCH /payoff/plans/active sends the account to move to and answers the plan")
    func setFocus() async throws {
        let (api, transport) = KiraAPI.routed(["PATCH /api/payoff/plans/active": ok(planJSON)])
        let plan = try await LivePayoffPlanService(api: api).setFocus(debtId: "a-2")
        #expect(await transport.sent.first?.json == ["focusDebtId": .string("a-2")])
        #expect(plan.id == "plan-1")
    }

    @Test("a move the API refuses reaches the model with its code", arguments: [404, 422])
    func focusRefused(status: Int) async {
        let code = status == 404 ? "PAYOFF_DEBT_NOT_FOUND" : "VALIDATION_FAILED"
        let (api, _) = KiraAPI.routed(["PATCH /api/payoff/plans/active": problem(code, status: status)])
        let error = await #expect(throws: AppProblem.self) {
            try await LivePayoffPlanService(api: api).setFocus(debtId: "x")
        }
        #expect(error?.code == code)
    }
}
