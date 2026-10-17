import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("PayoffEntryModel")
struct PayoffEntryModelTests {
    @Test("a plan opens Rencanaku; none yet opens Rencana Pelunasan")
    func destinations() async {
        let withPlan = PayoffEntryModel(plans: FakePayoffPlanService())
        await withPlan.load()
        #expect(withPlan.phase.value == PayoffPlanFixtures.plan())
        let service = FakePayoffPlanService()
        await service.answersActive(.failure(AppProblem(code: "PAYOFF_PLAN_NOT_FOUND")))
        let none = PayoffEntryModel(plans: service)
        await none.load()
        guard case .empty = none.phase else { return #expect(Bool(false), "no plan should open Rencana Pelunasan") }
    }

    @Test("offline shows the connection's problem and Coba Lagi asks again; a cancelled ask shows nothing")
    func failures() async {
        let service = FakePayoffPlanService()
        await service.answersActive(.failure(URLError(.notConnectedToInternet)))
        let model = PayoffEntryModel(plans: service)
        await model.load()
        #expect(model.phase.problem == .connectionLost)
        await service.answersActive(.success(PayoffPlanFixtures.plan()))
        await model.load()
        #expect(model.phase.value != nil && await service.calls == ["active", "active"])
        await service.answersActive(.failure(CancellationError()))
        let cancelled = PayoffEntryModel(plans: service)
        await cancelled.load()
        #expect(cancelled.phase.value == nil && cancelled.phase.problem == nil)
    }
}
