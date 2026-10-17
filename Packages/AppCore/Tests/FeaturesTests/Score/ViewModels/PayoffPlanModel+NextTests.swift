import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("PayoffPlanModel next account")
struct PayoffPlanModelNextTests {
    private let service = FakePayoffPlanService()

    private func loadedModel() async -> PayoffPlanModel {
        let ids = PaymentIds()
        let model = PayoffPlanModel(service: service) { ids.next() }
        await model.load()
        return model
    }

    @Test("Lanjut ke the next account closes the celebration and moves the plan to it")
    func continueToNext() async throws {
        await service.answersPayment(.success(PayoffPlanFixtures.settledPayment))
        let model = await loadedModel()
        await model.markPaid()
        let paid = try #require(model.celebration)
        await model.continueToNext(after: paid)
        #expect(model.celebration == nil && model.failure == nil && !model.isWorking)
        #expect(model.phase.value == PayoffPlanFixtures.plan(focusIsFirst: false))
        #expect(await service.calls.last == "focus a-2")
    }

    @Test("the last account has nothing to move to: the celebration closes and no move is sent")
    func continueAfterLast() async throws {
        let last = DebtPayment(
            debtId: "a-1", monthlyInstalment: 210_000, paidOff: true, nextAccount: nil, scoreEstimate: nil)
        await service.answersPayment(.success(last))
        let model = await loadedModel()
        await model.markPaid()
        let paid = try #require(model.celebration)
        await model.continueToNext(after: paid)
        #expect(model.celebration == nil)
        #expect(await service.calls.allSatisfy { !$0.hasPrefix("focus") })
    }

    @Test("a move that fails keeps the plan and opens the dialog; Coba Lagi moves to the same account")
    func focusFails() async throws {
        await service.answersPayment(.success(PayoffPlanFixtures.settledPayment))
        await service.answersFocus(.failure(URLError(.notConnectedToInternet)))
        let model = await loadedModel()
        await model.markPaid()
        await model.continueToNext(after: try #require(model.celebration))
        guard case .focus(let debtId, let problem) = model.failure else { return #expect(Bool(false)) }
        #expect(debtId == "a-2" && problem == .connectionLost)
        #expect(model.phase.value == PayoffPlanFixtures.plan() && !model.isWorking)
        let failed = try #require(model.failure)
        await service.answersFocus(.success(PayoffPlanFixtures.plan(focusIsFirst: false)))
        await model.retry(failed)
        #expect(model.failure == nil && model.phase.value == PayoffPlanFixtures.plan(focusIsFirst: false))
        #expect(await service.calls.filter { $0.hasPrefix("focus") } == ["focus a-2", "focus a-2"])
    }
}
