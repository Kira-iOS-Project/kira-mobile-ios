import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("PayoffPlanModel")
struct PayoffPlanModelTests {
    @Test("loads the person's plan")
    func load() async {
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service)
        guard case .loading = model.phase else { return #expect(Bool(false)) }
        await model.load()
        #expect(model.phase.value == PayoffPlanFixtures.plan())
        #expect(await service.calls == ["active"])
    }

    @Test("a person without a plan sees the empty screen")
    func noPlan() async {
        let service = FakePayoffPlanService()
        await service.answersActive(.failure(AppProblem(code: "PAYOFF_PLAN_NOT_FOUND")))
        let model = PayoffPlanModel(service: service)
        await model.load()
        guard case .empty = model.phase else { return #expect(Bool(false)) }
    }

    @Test("a load that fails shows the problem, or the generic one")
    func loadFails() async {
        let service = FakePayoffPlanService()
        await service.answersActive(.failure(AppProblem(code: "INTERNAL_ERROR")))
        let model = PayoffPlanModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.code == "INTERNAL_ERROR")
        await service.answersActive(.failure(PayoffPlanOtherError()))
        await model.load()
        guard case .failed(let generic) = model.phase else { return #expect(Bool(false)) }
        #expect(generic.code == nil)
    }

    @Test("moving the plan to another account shows the plan the API answers")
    func focus() async {
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service)
        await model.load()
        await model.focus(on: "a-2")
        #expect(model.phase.value == PayoffPlanFixtures.plan(focusIsFirst: false) && !model.isWorking)
        #expect(await service.calls == ["active", "focus a-2"])
    }

    @Test("a move that fails leaves the plan as it was and names the problem until the next move works")
    func focusFails() async {
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service)
        await model.load()
        await service.answersFocus(.failure(AppProblem(code: "PAYOFF_DEBT_NOT_FOUND")))
        await model.focus(on: "gone")
        #expect(model.phase.value == PayoffPlanFixtures.plan() && model.actionProblem?.knownCode == .payoffDebtNotFound)
        await service.answersFocus(.failure(PayoffPlanOtherError()))
        await model.focus(on: "gone")
        #expect(model.actionProblem != nil && model.actionProblem?.code == nil)
        await service.answersFocus(.success(PayoffPlanFixtures.plan(focusIsFirst: false)))
        await model.focus(on: "a-2")
        #expect(model.actionProblem == nil && !model.isWorking)
    }

    @Test("Tandai Sudah Bayar pays the next payment and reloads the plan, with no celebration for a part payment")
    func markPaid() async {
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service)
        await model.load()
        await model.markPaid()
        #expect(await service.calls == ["active", "pay a-1 210000", "active"])
        #expect(model.celebration == nil && model.actionProblem == nil && !model.isWorking)
    }

    @Test("the payment that settles an account opens the celebration once, until it is closed")
    func celebrate() async {
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service)
        await model.load()
        await service.answersPayment(.success(PayoffPlanFixtures.settledPayment))
        await service.answersActive(.success(PayoffPlanFixtures.plan(focusIsFirst: false)))
        await model.markPaid()
        #expect(model.celebration == PayoffPlanFixtures.settledPayment && model.celebratedName == "Akun")
        #expect(model.phase.value == PayoffPlanFixtures.plan(focusIsFirst: false))
        model.dismissCelebration()
        #expect(model.celebration == nil && model.celebratedName == nil)
        await service.answersPayment(.success(PayoffPlanFixtures.partPayment))
        await model.markPaid()
        #expect(model.celebration == nil && model.celebratedName == nil)
    }

    @Test("a payment that fails names the problem and does not reload the plan")
    func markPaidFails() async {
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service)
        await model.load()
        await service.answersPayment(.failure(AppProblem(code: "PAYOFF_PAYMENT_TOO_HIGH")))
        await model.markPaid()
        #expect(model.actionProblem?.knownCode == .payoffPaymentTooHigh && model.celebration == nil)
        #expect(await service.calls == ["active", "pay a-1 210000"])
        await service.answersPayment(.failure(PayoffPlanOtherError()))
        await model.markPaid()
        #expect(model.actionProblem != nil && model.actionProblem?.code == nil)
    }

    @Test("with no payment due, or before the plan loads, Tandai Sudah Bayar does nothing")
    func nothingToPay() async {
        let service = FakePayoffPlanService()
        let model = PayoffPlanModel(service: service)
        await model.markPaid()
        await service.answersActive(.success(PayoffPlanFixtures.donePlan))
        await model.load()
        await model.markPaid()
        #expect(await service.calls == ["active"])
    }
}
