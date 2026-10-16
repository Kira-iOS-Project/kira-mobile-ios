import APIClient
import Domain
import Testing

@testable import Features

/** The API's side of the plan, answered from memory: the network is the boundary replaced here. */
private actor FakePayoffService: PayoffService {
    private(set) var calls: [PayoffCall] = []
    var answer: @Sendable (PayoffCall) throws -> PayoffSimulation = { simulation(for: $0) }

    func simulate(method: PayoffMethod, extraPayment: Int) throws -> PayoffSimulation {
        let call = PayoffCall(method: method, extraPayment: extraPayment)
        calls.append(call)
        return try answer(call)
    }

    func answers(_ answer: @escaping @Sendable (PayoffCall) throws -> PayoffSimulation) {
        self.answer = answer
    }
}

private struct PayoffCall: Equatable, Sendable {
    let method: PayoffMethod
    let extraPayment: Int
}

private struct OtherError: Error {}

private func simulation(for call: PayoffCall) -> PayoffSimulation {
    PayoffSimulation(
        method: call.method, extraPayment: call.extraPayment, maxExtraPayment: 1_840_000, monthlyBudget: 700_000,
        hasUnknownRate: false, accounts: [], productive: [], totalInterest: nil, allPaidMonths: nil,
        allPaidMonth: nil, comparison: nil)
}

@MainActor
@Suite("PayoffModel")
struct PayoffModelTests {
    @Test("opens on Snowball with no extra payment and loads the plan")
    func load() async {
        let service = FakePayoffService()
        let model = PayoffModel(service: service)
        #expect(model.phase.value == nil && model.method == .snowball && model.extraPayment == 0)
        await model.load()
        #expect(model.phase.value?.method == .snowball)
        #expect(model.maxExtraPayment == 1_840_000 && !model.isRecalculating)
        #expect(await service.calls == [PayoffCall(method: .snowball, extraPayment: 0)])
    }

    @Test("choosing the other method recomputes; choosing the same one does not")
    func choose() async {
        let service = FakePayoffService()
        let model = PayoffModel(service: service)
        await model.load()
        await model.choose(.avalanche)
        await model.choose(.avalanche)
        #expect(model.method == .avalanche && model.phase.value?.method == .avalanche)
        #expect(await service.calls.count == 2)
    }

    @Test("the extra payment keeps its digits, grouped, and recomputes with them")
    func extra() async {
        let service = FakePayoffService()
        let model = PayoffModel(service: service)
        await model.load()
        await model.setExtra("Rp 200000")
        #expect(model.extraText == "200.000" && model.extraPayment == 200_000 && !model.exceedsMaximum)
        #expect(await service.calls.last == PayoffCall(method: .snowball, extraPayment: 200_000))
        await model.setExtra("")
        #expect(model.extraText.isEmpty && model.extraPayment == 0)
    }

    @Test("an extra payment above the money left is flagged without asking the API")
    func tooHigh() async {
        let service = FakePayoffService()
        let model = PayoffModel(service: service)
        await model.load()
        await model.setExtra("2000000")
        #expect(model.exceedsMaximum && model.extraPayment == 2_000_000)
        #expect(await service.calls.count == 1)
        await model.setExtra("1840000")
        #expect(!model.exceedsMaximum)
        #expect(await service.calls.count == 2)
    }

    @Test("before a plan is on screen nothing exceeds the maximum")
    func beforeLoad() {
        let model = PayoffModel(service: FakePayoffService())
        #expect(!model.exceedsMaximum && model.maxExtraPayment == nil)
    }

    @Test("no consumer debt makes the screen empty")
    func nothingToPlan() async {
        let service = FakePayoffService()
        await service.answers { _ in throw AppProblem(code: "PAYOFF_NOTHING_TO_PLAN") }
        let model = PayoffModel(service: service)
        await model.load()
        guard case .empty = model.phase else { return #expect(Bool(false)) }
    }

    @Test("a first load that fails shows the problem, or the generic one")
    func firstLoadFails() async {
        let service = FakePayoffService()
        await service.answers { _ in throw AppProblem(code: "INTERNAL_ERROR") }
        let model = PayoffModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.code == "INTERNAL_ERROR")
        await service.answers { _ in throw OtherError() }
        await model.load()
        guard case .failed(let generic) = model.phase else { return #expect(Bool(false)) }
        #expect(generic.code == nil)
    }

    @Test("a failed recomputation keeps the plan on screen and names the problem until the next one works")
    func recalculationFails() async {
        let service = FakePayoffService()
        let model = PayoffModel(service: service)
        await model.load()
        await service.answers { _ in throw AppProblem(code: "PAYOFF_EXTRA_TOO_HIGH") }
        await model.choose(.avalanche)
        #expect(model.phase.value?.method == .snowball)
        #expect(model.recalculationProblem?.knownCode == .payoffExtraTooHigh)
        await service.answers { simulation(for: $0) }
        await model.choose(.snowball)
        #expect(model.recalculationProblem == nil && model.phase.value?.method == .snowball)
    }

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
        await plans.creates(.failure(PayoffPlanOtherError()))
        #expect(await !model.makePlan(using: plans))
        #expect(model.makePlanProblem != nil && model.makePlanProblem?.code == nil)
        await plans.creates(.success(PayoffPlanFixtures.plan()))
        #expect(await model.makePlan(using: plans))
        #expect(model.makePlanProblem == nil)
    }

    @Test("an answer that arrives after a newer request is dropped")
    func staleAnswer() async {
        let service = GatedPayoffService(heldFails: false)
        let model = PayoffModel(service: service)
        await model.load()
        let slow = Task { await model.choose(.avalanche) }
        await service.untilHeld()
        await model.setExtra("100000")
        await service.release()
        await slow.value
        #expect(model.phase.value?.extraPayment == 100_000 && model.phase.value?.method == .avalanche)
        #expect(!model.isRecalculating)
    }

    @Test("a failure that arrives after a newer request is dropped too")
    func staleFailure() async {
        let service = GatedPayoffService(heldFails: true)
        let model = PayoffModel(service: service)
        await model.load()
        let slow = Task { await model.choose(.avalanche) }
        await service.untilHeld()
        await model.setExtra("100000")
        await service.release()
        await slow.value
        #expect(model.phase.value?.extraPayment == 100_000 && model.recalculationProblem == nil)
    }
}

/** Holds the Avalanche call with no extra payment until released, so a newer request can overtake it. */
private actor GatedPayoffService: PayoffService {
    private let heldFails: Bool
    private var held: CheckedContinuation<Void, Never>?

    init(heldFails: Bool) {
        self.heldFails = heldFails
    }

    func simulate(method: PayoffMethod, extraPayment: Int) async throws -> PayoffSimulation {
        let call = PayoffCall(method: method, extraPayment: extraPayment)
        guard method == .avalanche, extraPayment == 0 else { return simulation(for: call) }
        await withCheckedContinuation { held = $0 }
        if heldFails { throw AppProblem(code: "INTERNAL_ERROR") }
        return simulation(for: call)
    }

    func untilHeld() async {
        while held == nil { await Task.yield() }
    }

    func release() {
        held?.resume()
        held = nil
    }
}
