import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("HistoryModel paging")
struct HistoryModelPagingTests {
    private let service = FakeHistoryService()

    private func model() -> HistoryModel {
        HistoryModel(service: service, now: { HistorySample.now }, pause: { _ in })
    }

    @Test("opens the folded days, then loads older pages as the end appears")
    func paging() async throws {
        let older = Transaction(
            id: "old", type: .expense, amount: 9_000, category: .coffee, name: "Kopi",
            occurredAt: HistorySample.at(HistorySample.period.start.adding(days: 2), 9, 0), source: .receipt)
        await service.configure {
            $0.pages = [
                nil: TransactionPage(items: HistorySample.transactions, nextCursor: "p2"),
                "p2": TransactionPage(items: [older], nextCursor: nil),
            ]
        }
        let model = model()
        await model.loadMore()
        await model.load()
        #expect(try #require(model.phase.value).canLoadMore == false)
        model.showOlderDays()
        #expect(try #require(model.phase.value).canLoadMore)
        await model.loadMore()
        let content = try #require(model.phase.value)
        #expect(content.sections.count == 5)
        #expect(!content.canLoadMore)
        await model.loadMore()
        #expect(await service.queries.map(\.cursor) == [nil, "p2"])
    }

    @Test("a failed older page leaves the list, and one page loads at a time")
    func pagingFailure() async throws {
        await service.configure { $0.pages[nil] = TransactionPage(items: HistorySample.transactions, nextCursor: "p2") }
        let model = model()
        model.showOlderDays()
        await model.load()
        await service.configure { $0.failing = [.transactions] }
        await model.loadMore()
        #expect(try #require(model.phase.value).canLoadMore)
        await service.configure {
            $0.failing = []
            $0.holdsNextTransactions = true
        }
        let first = Task { await model.loadMore() }
        await eventually { await service.isHolding }
        await model.loadMore()
        await service.release()
        await first.value
        #expect(await service.queries.count == 3)
    }
}
