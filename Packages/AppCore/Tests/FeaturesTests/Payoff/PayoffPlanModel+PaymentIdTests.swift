import APIClient
import Domain
import Testing
import os

@testable import Features

/** Hands out `id-1`, `id-2`, ... so a test can tell which payment a call carried. */
final class PaymentIds: Sendable {
    private let count = OSAllocatedUnfairLock(initialState: 0)

    @Sendable func next() -> String { count.withLock { value in value += 1; return "id-\(value)" } }
}

@MainActor
@Suite("PayoffPlanModel payment ids")
struct PayoffPlanModelPaymentIdTests {
    @Test("a payment that failed is retried under the same id, and the next payment gets a new one")
    func retryKeepsId() async {
        let ids = PaymentIds()
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service, makePaymentId: ids.next)
        await model.load()
        await service.answersPayment(.failure(PayoffOtherError()))
        await model.markPaid()
        await service.answersPayment(.success(PayoffPlanFixtures.partPayment))
        await model.markPaid()
        await model.markPaid()
        #expect(
            await service.calls == [
                "active", "pay a-1 210000 id-1", "pay a-1 210000 id-1", "active", "pay a-1 210000 id-2", "active",
            ])
    }

    @Test("a payment the API already saved counts as saved: no celebration, and the plan reloads")
    func alreadyRecorded() async {
        let ids = PaymentIds()
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service, makePaymentId: ids.next)
        await model.load()
        await service.answersPayment(.failure(AppProblem(code: "PAYOFF_PAYMENT_ALREADY_RECORDED")))
        await model.markPaid()
        #expect(model.actionProblem == nil && model.celebration == nil)
        #expect(await service.calls == ["active", "pay a-1 210000 id-1", "active"])
        await service.answersPayment(.success(PayoffPlanFixtures.partPayment))
        await model.markPaid()
        #expect(await service.calls.last == "active" && model.actionProblem == nil)
        #expect(await service.calls.contains("pay a-1 210000 id-2"))
    }
}
