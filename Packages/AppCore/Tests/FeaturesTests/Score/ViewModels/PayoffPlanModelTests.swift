import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Names each new payment "p1", "p2", … so the tests can tell a new payment from a retry. */
final class PaymentIds: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    func next() -> String {
        lock.withLock {
            count += 1
            return "p\(count)"
        }
    }
}

@MainActor
@Suite("PayoffPlanModel")
struct PayoffPlanModelTests {
    private let service = FakePayoffPlanService()

    private func loadedModel() async -> PayoffPlanModel {
        let ids = PaymentIds()
        let model = PayoffPlanModel(service: service) { ids.next() }
        await model.load()
        return model
    }

    @Test("loads the person's plan")
    func load() async {
        let model = PayoffPlanModel(service: service)
        guard case .loading = model.phase else { return #expect(Bool(false)) }
        await model.load()
        #expect(model.phase.value == PayoffPlanFixtures.plan())
        #expect(await service.calls == ["active"])
    }

    @Test("a person without a plan sees the empty screen")
    func noPlan() async {
        await service.answersActive(.failure(AppProblem(code: "PAYOFF_PLAN_NOT_FOUND")))
        let model = await loadedModel()
        guard case .empty = model.phase else { return #expect(Bool(false)) }
    }

    @Test(
        "a load that fails shows the API's problem, connection loss offline, the generic one for anything else",
        arguments: [
            (AppProblem(code: "INTERNAL_ERROR") as any Error, AppProblem(code: "INTERNAL_ERROR")),
            (URLError(.notConnectedToInternet), AppProblem.connectionLost),
            (PayoffOtherError(), AppProblem()),
        ])
    func loadFails(error: any Error, shown: AppProblem) async {
        await service.answersActive(.failure(error))
        let model = await loadedModel()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem == shown)
    }

    @Test("Tandai Sudah Bayar pays the next payment as a new payment and reloads, no celebration for a part payment")
    func markPaid() async {
        let model = await loadedModel()
        await model.markPaid()
        #expect(await service.calls == ["active", "pay a-1 210000 p1", "active"])
        #expect(model.celebration == nil && model.failure == nil && !model.isWorking)
        await model.markPaid()
        #expect(await service.calls.last(where: { $0.hasPrefix("pay") }) == "pay a-1 210000 p2")
    }

    @Test("a double tap sends one payment")
    func doubleTap() async {
        let model = await loadedModel()
        let first = Task { await model.markPaid() }
        let second = Task { await model.markPaid() }
        await first.value
        await second.value
        #expect(await service.calls.filter { $0.hasPrefix("pay") } == ["pay a-1 210000 p1"])
        #expect(!model.isWorking)
    }

    @Test("the payment that settles an account opens the celebration, placed by the plan before the payment")
    func celebrate() async throws {
        await service.answersPayment(.success(PayoffPlanFixtures.settledPayment))
        let model = await loadedModel()
        await model.markPaid()
        let paid = try #require(model.celebration)
        #expect(paid.id == "a-1" && paid.name == "Akun" && paid.position == 1 && paid.total == 3)
        #expect(paid.nextAccount == NextAccount(id: "a-2", name: "Pinjol B"))
        #expect(paid.scoreEstimate?.after == 72 && paid.monthlyInstalment == 210_000)
        #expect(await service.calls == ["active", "pay a-1 210000 p1", "active"])
        model.dismissCelebration()
        #expect(model.celebration == nil)
        #expect(await service.calls.count == 3)
    }

    @Test("nothing to pay sends nothing: before the plan loads, and once every account is paid")
    func nothingToPay() async {
        let waiting = PayoffPlanModel(service: service)
        await waiting.markPaid()
        #expect(await service.calls.isEmpty)
        await service.answersActive(.success(PayoffPlanFixtures.donePlan))
        let done = await loadedModel()
        await done.markPaid()
        #expect(await service.calls == ["active"])
    }
}
