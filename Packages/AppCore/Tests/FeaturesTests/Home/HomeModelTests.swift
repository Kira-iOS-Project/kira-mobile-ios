import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** The API's side of Beranda, answered from memory: the network is the boundary replaced here. */
private final class FakeHomeService: HomeService, @unchecked Sendable {
    /** Read and written on the main actor only, by the model under test. */
    var result: Result<HomeOverview, AppProblem>
    var savedHideBalances: [Bool] = []
    var failsToSave = false

    init(_ result: Result<HomeOverview, AppProblem>) {
        self.result = result
    }

    func home() throws -> HomeOverview { try result.get() }

    func setHideBalances(_ isHidden: Bool) throws {
        savedHideBalances.append(isHidden)
        if failsToSave { throw AppProblem(code: "INTERNAL_ERROR") }
    }
}

private struct OtherError: Error {}

/** A service whose load throws something other than an `AppProblem`. */
private struct BrokenHomeService: HomeService {
    func home() throws -> HomeOverview { throw OtherError() }
    func setHideBalances(_: Bool) throws {}
}

@MainActor
@Suite("HomeModel")
struct HomeModelTests {
    private func overview(hideBalances: Bool = false, step: ScoreStep? = nil) -> HomeOverview {
        HomeOverview(
            variant: .overview, today: Date(timeIntervalSince1970: 1_791_997_200), displayName: "Dinda",
            hideBalances: hideBalances, period: PayPeriod(daysUntilPayday: 10), step: step)
    }

    @Test("starts loading, then shows Beranda with the amounts hidden as the account says")
    func load() async {
        let model = HomeModel(service: FakeHomeService(.success(overview(hideBalances: true))))
        #expect(model.phase.value == nil)
        await model.load()
        #expect(model.phase.value?.displayName == "Dinda")
        #expect(model.isMasked)
    }

    @Test("shows the API's problem, or the generic one for any other error")
    func failure() async {
        let problem = AppProblem(code: "INTERNAL_ERROR", requestId: "abc")
        let model = HomeModel(service: FakeHomeService(.failure(problem)))
        await model.load()
        guard case .failed(let shown) = model.phase else { return #expect(Bool(false)) }
        #expect(shown == problem)
        let broken = HomeModel(service: BrokenHomeService())
        await broken.load()
        guard case .failed(let generic) = broken.phase else { return #expect(Bool(false)) }
        #expect(generic == AppProblem())
    }

    @Test("the eye hides amounts, asks the API to remember, and keeps the choice through a reload")
    func eye() async {
        let service = FakeHomeService(.success(overview()))
        let model = HomeModel(service: service)
        await model.load()
        #expect(!model.isMasked)
        await model.toggleMasked()
        #expect(model.isMasked)
        #expect(service.savedHideBalances == [true])
        await model.load()
        #expect(model.isMasked)
        service.failsToSave = true
        await model.toggleMasked()
        #expect(!model.isMasked)
    }

    @Test("Nanti Saja puts the step away until the next load")
    func dismissStep() async {
        var step = ScoreStep(kind: .payOffDebt, estimatedGain: 5)
        step.debtName = "Paylater A"
        let model = HomeModel(service: FakeHomeService(.success(overview(step: step))))
        await model.load()
        #expect(model.visibleStep == step)
        model.dismissStep()
        #expect(model.visibleStep == nil)
        await model.load()
        #expect(model.visibleStep == step)
    }

    @Test("greets by the WIB time of day of its clock")
    func greeting() {
        let fivePastFive = Date(timeIntervalSince1970: 1_791_997_200 + 17 * 3600 + 300)
        let model = HomeModel(service: FakeHomeService(.success(overview())), now: { fivePastFive })
        #expect(model.dayPart == .afternoon)
        #expect(HomeModel(service: BrokenHomeService()).dayPart == DayPart(at: Date()))
    }
}
