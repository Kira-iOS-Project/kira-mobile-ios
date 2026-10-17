import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("HistoryModel")
struct HistoryModelTests {
    private let service = FakeHistoryService()

    private func model(pause: @escaping @Sendable (Duration) async throws -> Void = { _ in }) -> HistoryModel {
        HistoryModel(service: service, now: { HistorySample.now }, pause: pause)
    }

    @Test("loads the period's totals and folds the days between the two newest and payday")
    func load() async throws {
        let model = model()
        #expect(model.phase.value == nil)
        await model.load()
        let content = try #require(model.phase.value)
        #expect(content.period == HistorySample.period)
        #expect(content.summary.expense == 5_660_000)
        #expect(content.sections.count == 4)
        #expect(
            content.sections[2]
                == .olderDays(
                    first: HistorySample.period.start.adding(days: 1), last: HistorySample.today.adding(days: -2)))
        #expect(!content.canLoadMore)
        let query = try #require(await service.queries.first)
        #expect(
            query
                == TransactionQuery(
                    start: HistorySample.period.start, end: HistorySample.period.end, limit: HistoryModel.pageSize))
    }

    @Test("an empty period is empty; a filter that matches nothing is an empty list")
    func empty() async throws {
        await service.configure { $0.pages = [:] }
        let model = model()
        await model.load()
        guard case .empty = model.phase else {
            Issue.record("expected empty")
            return
        }
        await model.select(kind: .income)
        #expect(try #require(model.phase.value).sections.isEmpty)
    }

    @Test("shows the API's problem when loading fails")
    func failure() async {
        await service.configure { $0.failing = [.period] }
        let model = model()
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failed")
            return
        }
        #expect(problem == FakeHistoryService.problem)
        struct Offline: Error {}
        #expect(historyProblem(Offline()) == AppProblem())
    }

    @Test("filters by kind and category; a category of the other direction is cleared")
    func filters() async throws {
        let model = model()
        await model.select(kind: .expense)
        await model.select(category: .food)
        #expect(model.categories.contains(.food) && !model.categories.contains(.salary))
        await model.select(kind: .income)
        #expect(model.category == nil)
        #expect(model.categories == [.salary, .bonus, .business, .otherIncome])
        await model.select(category: .salary)
        await model.select(kind: .all)
        #expect(model.category == nil)
        let queries = await service.queries
        #expect(queries.map(\.type) == [.expense, .expense, .income, .income, nil])
        #expect(queries.map(\.category) == [nil, .food, nil, .salary, nil])
        #expect(HistoryModel.Kind.allCases.count == 3)
    }

    @Test("searches once typing pauses, trimmed, and not again for the same text")
    func search() async throws {
        let model = model()
        await model.load()
        model.searchText = "  grab "
        await model.searchChanged()
        model.searchText = "grab"
        await model.searchChanged()
        let queries = await service.queries
        #expect(queries.map(\.text) == [nil, "grab"])
    }

    @Test("by default reads the device clock and really pauses before searching")
    func defaults() async throws {
        let model = HistoryModel(service: service)
        await model.load()
        #expect(model.phase.value != nil)
        model.searchText = "grab"
        let started = ContinuousClock.now
        await model.searchChanged()
        #expect(ContinuousClock.now - started >= HistoryModel.searchDelay)
        #expect(await service.queries.last?.text == "grab")
    }

    @Test("a newer keystroke cancels the pause, and nothing is asked")
    func searchCancelled() async {
        let model = model(pause: { _ in throw CancellationError() })
        model.searchText = "kopi"
        await model.searchChanged()
        #expect(await service.queries.isEmpty)
    }
}
