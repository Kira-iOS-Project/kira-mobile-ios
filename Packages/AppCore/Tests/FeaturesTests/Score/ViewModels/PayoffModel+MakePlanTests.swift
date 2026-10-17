import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("PayoffModel Jadikan Rencanaku")
struct PayoffModelMakePlanTests {
    @Test("Jadikan Rencanaku saves the plan on screen with its method and extra payment")
    func makePlan() async {
        let model = PayoffModel(service: FakePayoffService())
        let plans = FakePayoffPlanService()
        await model.load()
        await model.choose(.avalanche)
        await model.setExtra("200000")
        #expect(await model.makePlan(using: plans))
        #expect(await plans.calls == ["create avalanche 200000"])
        #expect(model.makePlanProblem == nil && !model.isMakingPlan)
    }

    @Test("Jadikan Rencanaku waits for a plan on screen and for an extra payment within the maximum")
    func makePlanGuards() async {
        let model = PayoffModel(service: FakePayoffService())
        let plans = FakePayoffPlanService()
        #expect(await !model.makePlan(using: plans))
        await model.load()
        await model.setExtra("2000000")
        #expect(await !model.makePlan(using: plans))
        #expect(await plans.calls.isEmpty)
    }

    @Test("a plan that cannot be saved names the problem until the next try works")
    func makePlanFails() async {
        let model = PayoffModel(service: FakePayoffService())
        let plans = FakePayoffPlanService()
        await model.load()
        await plans.creates(.failure(AppProblem(code: "PAYOFF_NOTHING_TO_PLAN")))
        #expect(await !model.makePlan(using: plans))
        #expect(model.makePlanProblem?.knownCode == .payoffNothingToPlan && !model.isMakingPlan)
        await plans.creates(.failure(PayoffOtherError()))
        #expect(await !model.makePlan(using: plans))
        #expect(model.makePlanProblem != nil && model.makePlanProblem?.code == nil)
        await plans.creates(.success(PayoffPlanFixtures.plan()))
        #expect(await model.makePlan(using: plans))
        #expect(model.makePlanProblem == nil)
    }
}
