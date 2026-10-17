import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LivePayoffPlanService payments")
struct LivePayoffPlanServicePaymentTests {
    private let settledJSON = #"""
        {"debtId":"a-1","monthlyInstalment":210000,"paid":420000,"remaining":0,"progressPercent":100,\#
        "paidOff":true,"nextAccount":{"id":"a-2","name":"Pinjol B"},\#
        "scoreEstimate":{"before":66,"after":72,"consumerDebtBefore":50,"consumerDebtAfter":80}}
        """#

    private let partJSON = #"""
        {"debtId":"a-1","monthlyInstalment":210000,"paid":210000,"remaining":210000,"progressPercent":65,\#
        "paidOff":false,"nextAccount":null,"scoreEstimate":null}
        """#

    private let paymentRoute = "POST /api/debts/a-1/payments"

    @Test("POST /debts/{id}/payments sends the amount and the payment's id, and reads the settled account")
    func recordSettled() async throws {
        let (api, transport) = KiraAPI.routed([paymentRoute: ok(settledJSON)])
        let payment = try await LivePayoffPlanService(api: api)
            .recordPayment(debtId: "a-1", amount: 420_000, paymentId: "pay-7")
        let sent = try #require(await transport.sent.first)
        #expect(sent.route == paymentRoute)
        #expect(sent.json == ["amount": .number(420_000), "paymentId": .string("pay-7")])
        #expect(
            payment
                == DebtPayment(
                    debtId: "a-1", monthlyInstalment: 210_000, paidOff: true,
                    nextAccount: NextAccount(id: "a-2", name: "Pinjol B"),
                    scoreEstimate: ScoreEstimate(before: 66, after: 72)))
    }

    @Test("a part payment has no next account and no estimate")
    func recordPart() async throws {
        let (api, _) = KiraAPI.routed([paymentRoute: ok(partJSON)])
        let payment = try await LivePayoffPlanService(api: api)
            .recordPayment(debtId: "a-1", amount: 210_000, paymentId: "pay-8")
        #expect(!payment.paidOff)
        #expect(payment.nextAccount == nil && payment.scoreEstimate == nil)
    }

    @Test(
        "every refused payment reaches the model with its code",
        arguments: [
            ("PAYOFF_PAYMENT_ALREADY_RECORDED", 409), ("PAYOFF_PAYMENT_TOO_HIGH", 422), ("PAYOFF_DEBT_NOT_FOUND", 404),
            ("VALIDATION_FAILED", 400), ("AUTH_UNAUTHENTICATED", 401), ("INTERNAL_ERROR", 500),
        ])
    func refused(code: String, status: Int) async {
        let (api, _) = KiraAPI.routed([paymentRoute: problem(code, status: status)])
        let error = await #expect(throws: AppProblem.self) {
            try await LivePayoffPlanService(api: api).recordPayment(debtId: "a-1", amount: 1, paymentId: "p")
        }
        #expect(error?.code == code)
    }

    @Test("the 409 of a payment already recorded is known to the app")
    func alreadyRecordedCode() async throws {
        let (api, _) = KiraAPI.routed([paymentRoute: problem("PAYOFF_PAYMENT_ALREADY_RECORDED", status: 409)])
        let error = await #expect(throws: AppProblem.self) {
            try await LivePayoffPlanService(api: api).recordPayment(debtId: "a-1", amount: 1, paymentId: "p")
        }
        #expect(error?.knownCode == .payoffPaymentAlreadyRecorded)
    }

    @Test("offline, every call fails as a lost connection once mapped")
    func offline() async {
        let service = LivePayoffPlanService(api: .offline)
        let calls: [@Sendable () async throws -> Void] = [
            { _ = try await service.active() },
            { _ = try await service.setFocus(debtId: "a-2") },
            { _ = try await service.recordPayment(debtId: "a-1", amount: 1, paymentId: "p") },
            { _ = try await service.create(method: .snowball, extraPayment: 0) },
        ]
        for call in calls {
            let error = await #expect(throws: (any Error).self) { try await call() }
            #expect(error.map(AppProblem.init) == .connectionLost)
        }
    }
}
