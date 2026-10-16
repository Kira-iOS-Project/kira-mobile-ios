import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("MarketplaceModel")
struct MarketplaceModelTests {
    private let all = [MarketplaceFixtures.course, MarketplaceFixtures.consultation]

    @Test("loads every kind first, in the team's order")
    func loadsAll() async {
        let model = MarketplaceModel(service: FakeMarketplaceService(lists: [nil: .success(all)]))
        #expect(model.phase.value == nil && model.kind == nil)
        await model.load()
        #expect(model.phase.value == all)
    }

    @Test("a chip shows its kind; a kind with no product is empty; the same chip does nothing")
    func filters() async {
        let service = FakeMarketplaceService(lists: [
            nil: .success(all), .course: .success([MarketplaceFixtures.course]), .event: .success([]),
        ])
        let model = MarketplaceModel(service: service)
        await model.select(.course)
        #expect(model.kind == .course && model.phase.value == [MarketplaceFixtures.course])
        await model.select(.event)
        guard case .empty = model.phase else { return #expect(Bool(false)) }
        await model.select(.event)
        guard case .empty = model.phase else { return #expect(Bool(false)) }
        await model.select(nil)
        #expect(model.kind == nil && model.phase.value == all)
    }

    @Test("shows the API's problem, and the connection message when no answer came")
    func failures() async {
        let service = FakeMarketplaceService(lists: [nil: .failure(AppProblem(code: "INTERNAL_ERROR"))])
        let model = MarketplaceModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { return #expect(Bool(false)) }
        #expect(problem.code == "INTERNAL_ERROR")
        let offline = MarketplaceModel(service: OfflineMarketplaceService())
        await offline.load()
        guard case .failed(let lost) = offline.phase else { return #expect(Bool(false)) }
        #expect(lost.isConnectionLoss)
    }

    @Test("Coba Lagi loads the same screen again after a failure")
    func retry() async {
        let service = ScriptedMarketplaceService(lists: [.failure(AppProblem(code: "INTERNAL_ERROR")), .success(all)])
        let model = MarketplaceModel(service: service)
        await model.load()
        guard case .failed = model.phase else { return #expect(Bool(false)) }
        await model.load()
        #expect(model.phase.value == all)
    }

    @Test("appearing again, back from a product, keeps the list without loading it again")
    func appearsOnce() async {
        let service = ScriptedMarketplaceService(lists: [.success(all)])
        let model = MarketplaceModel(service: service)
        await model.appear()
        await model.appear()
        #expect(model.phase.value == all)
        #expect(await service.listCalls == 1)
    }

    @Test("a load cut off by leaving the screen stays loading, and loads on the next appearance")
    func cancelled() async {
        let gate = Gate()
        let model = MarketplaceModel(service: FakeMarketplaceService(lists: [nil: .success(all)], held: (nil, gate)))
        let leaving = Task { await model.appear() }
        while !(await gate.hasWaiter) { await Task.yield() }
        leaving.cancel()
        await gate.open()
        await leaving.value
        guard case .loading = model.phase else { return #expect(Bool(false)) }
        await model.appear()
        #expect(model.phase.value == all)
    }

    @Test("an answer for a kind no longer chosen never replaces the newer list")
    func staleAnswer() async {
        let gate = Gate()
        let service = FakeMarketplaceService(
            lists: [.course: .success([MarketplaceFixtures.course]), .consultation: .success([])],
            held: (.course, gate))
        let model = MarketplaceModel(service: service)
        let slow = Task { await model.select(.course) }
        while !(await gate.hasWaiter) { await Task.yield() }
        await model.select(.consultation)
        await gate.open()
        await slow.value
        #expect(model.kind == .consultation)
        guard case .empty = model.phase else { return #expect(Bool(false)) }
    }
}
