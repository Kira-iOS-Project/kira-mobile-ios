import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("PayoffPlanModel failures")
struct PayoffPlanModelFailureTests {
    private let service = FakePayoffPlanService()

    private func loadedModel() async -> PayoffPlanModel {
        let ids = PaymentIds()
        let model = PayoffPlanModel(service: service) { ids.next() }
        await model.load()
        return model
    }

    @Test(
        "a refused or lost payment keeps the plan, sends no reload and opens the failure dialog",
        arguments: [
            (AppProblem(code: "PAYOFF_PAYMENT_TOO_HIGH") as any Error, AppProblem(code: "PAYOFF_PAYMENT_TOO_HIGH")),
            (URLError(.notConnectedToInternet), AppProblem.connectionLost),
            (PayoffOtherError(), AppProblem()),
        ])
    func paymentFails(error: any Error, shown: AppProblem) async {
        await service.answersPayment(.failure(error))
        let model = await loadedModel()
        await model.markPaid()
        guard case .payment(let paymentId, let problem) = model.failure else { return #expect(Bool(false)) }
        #expect(paymentId == "p1" && problem == shown && model.failure?.problem == shown)
        #expect(model.phase.value == PayoffPlanFixtures.plan() && model.celebration == nil && !model.isWorking)
        #expect(await service.calls == ["active", "pay a-1 210000 p1"])
    }

    @Test("Coba Lagi sends the failed payment again under the same id")
    func retryPayment() async throws {
        await service.answersPayment(.failure(URLError(.timedOut)))
        let model = await loadedModel()
        await model.markPaid()
        let failed = try #require(model.failure)
        await service.answersPayment(.success(PayoffPlanFixtures.partPayment))
        model.failure = nil
        await model.retry(failed)
        #expect(await service.calls == ["active", "pay a-1 210000 p1", "pay a-1 210000 p1", "active"])
        #expect(model.failure == nil && !model.isWorking)
    }

    @Test("a retry the API already recorded counts as saved: the plan reloads, no dialog, no celebration")
    func alreadyRecorded() async throws {
        await service.answersPayment(.failure(URLError(.networkConnectionLost)))
        let model = await loadedModel()
        await model.markPaid()
        let failed = try #require(model.failure)
        await service.answersPayment(.failure(AppProblem(code: "PAYOFF_PAYMENT_ALREADY_RECORDED")))
        await service.answersActive(.success(PayoffPlanFixtures.plan(focusIsFirst: false)))
        await model.retry(failed)
        #expect(model.failure == nil && model.celebration == nil)
        #expect(model.phase.value == PayoffPlanFixtures.plan(focusIsFirst: false))
        #expect(await service.calls.suffix(2) == ["pay a-1 210000 p1", "active"])
    }

    @Test("a retry the API already recorded opens the celebration when the reloaded plan shows the account paid off")
    func alreadyRecordedPayoff() async throws {
        await service.answersPayment(.failure(URLError(.networkConnectionLost)))
        let model = await loadedModel()
        await model.markPaid()
        let failed = try #require(model.failure)
        await service.answersPayment(.failure(AppProblem(code: "PAYOFF_PAYMENT_ALREADY_RECORDED")))
        await service.answersActive(.success(PayoffPlanFixtures.planAfterPayoff))
        await model.retry(failed)
        let paid = try #require(model.celebration)
        #expect(model.failure == nil && paid.id == "a-1" && paid.position == 1 && paid.total == 3)
        #expect(paid.scoreEstimate == nil && paid.nextAccount == NextAccount(id: "a-2", name: "Akun a-2"))
    }

    @Test("when only the reload after a payment fails, the page shows the failure, never the old plan")
    func reloadFails() async {
        let model = await loadedModel()
        await service.answersActive(.failure(URLError(.notConnectedToInternet)))
        await model.markPaid()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem == .connectionLost && model.failure == nil && !model.isWorking)
        await model.markPaid()
        #expect(await service.calls.filter { $0.hasPrefix("pay") }.count == 1)
    }
}
