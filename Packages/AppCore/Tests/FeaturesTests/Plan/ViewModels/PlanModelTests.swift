import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("PlanModel")
struct PlanModelTests {
    @Test("loads the plan, with the emergency goal and its target multiple from step 2")
    func loads() async {
        let service = FakeGoalService()
        let emergency = GoalSummary(
            id: "e", kind: .emergencyFund, name: "Dana Darurat", targetAmount: 25_200_000,
            targetDate: CalendarDay(year: 2029, month: 4, day: 25), monthlyDeposit: 650_000, savedAmount: 4_800_000)
        await service.configure {
            $0.overview = PlanOverview(
                ladder: [
                    LadderStep(step: 2, key: .emergencyFund, status: .todo, detail: LadderDetail(targetMultiple: 6))
                ],
                goals: [emergency, FakeGoalService.summary], riskProfile: nil, prefill: PlanPrefill())
        }
        let model = PlanModel(service: service)
        #expect(model.phase.value == nil && model.emergencyGoal == nil && model.emergencyTargetMultiple == nil)
        await model.load()
        #expect(model.emergencyGoal == emergency)
        #expect(model.emergencyTargetMultiple == 6)
    }

    @Test("a failed first load shows the problem; a failed reload keeps what is on screen")
    func failures() async {
        let service = FakeGoalService()
        await service.configure { $0.failing[.plan] = URLError(.notConnectedToInternet) }
        let model = PlanModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.isConnectionLoss)
        await service.configure { $0.failing = [:] }
        await model.load()
        #expect(model.phase.value?.goals == [FakeGoalService.summary])
        await service.configure { $0.failing[.plan] = FakeGoalService.problem }
        await model.load()
        #expect(model.phase.value?.goals == [FakeGoalService.summary])
    }

    @Test("a load cut off by leaving the tab stays loading")
    func cancelled() async {
        let service = FakeGoalService()
        await service.configure { $0.failing[.plan] = FakeGoalService.problem }
        let model = PlanModel(service: service)
        let leaving = Task { await model.load() }
        leaving.cancel()
        await leaving.value
        guard case .loading = model.phase else { return #expect(Bool(false)) }
    }
}
