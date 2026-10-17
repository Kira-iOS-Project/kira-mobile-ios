import APIClient
import Domain
import Testing

@testable import Features

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
        let none = FakePayoffService()
        await none.answers { call in
            let full = payoffSimulation(for: call)
            return PayoffSimulation(
                method: full.method, extraPayment: full.extraPayment, maxExtraPayment: full.maxExtraPayment,
                hasUnknownRate: false, accounts: [], productive: full.productive, allPaidMonth: nil, comparison: nil)
        }
        let answered = PayoffModel(service: none)
        await answered.load()
        guard case .empty = answered.phase else { return #expect(Bool(false), "200 with no account is empty too") }
    }

    @Test("a first load that fails shows the problem, or the generic one")
    func firstLoadFails() async {
        let service = FakePayoffService()
        await service.answers { _ in throw AppProblem(code: "INTERNAL_ERROR") }
        let model = PayoffModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.code == "INTERNAL_ERROR")
        await service.answers { _ in throw PayoffOtherError() }
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
        await service.answers { payoffSimulation(for: $0) }
        await model.choose(.snowball)
        #expect(model.recalculationProblem == nil && model.phase.value?.method == .snowball)
    }

    @Test("the slider keeps a range one step wide and its value inside it, and is off with no room left")
    func sliderBounds() async {
        let service = FakePayoffService()
        let model = PayoffModel(service: service)
        #expect(model.sliderRange == 0...10_000 && !model.canSlide && model.sliderValue == 0)
        await model.load()
        #expect(model.sliderRange == 0...1_840_000 && model.canSlide)
        await model.setExtra("2.000.000")
        #expect(model.sliderValue == 1_840_000)
        for maximum in [0, -250_000] {
            await service.answers { call in
                let full = payoffSimulation(for: call)
                return PayoffSimulation(
                    method: full.method, extraPayment: full.extraPayment, maxExtraPayment: maximum,
                    hasUnknownRate: false, accounts: full.accounts, productive: [], allPaidMonth: nil, comparison: nil)
            }
            let tight = PayoffModel(service: service)
            #expect(tight.hasRoomForExtra)
            await tight.load()
            #expect(tight.sliderRange == 0...10_000 && !tight.canSlide && tight.sliderValue == 0)
            #expect(!tight.hasRoomForExtra)
            await tight.setExtra("50.000")
            #expect(tight.extraText.isEmpty && tight.extraPayment == 0)
        }
    }
}
