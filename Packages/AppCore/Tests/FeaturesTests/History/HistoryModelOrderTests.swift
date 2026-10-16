import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Answers that arrive after a newer request started are dropped, whether they succeed or fail. */
@MainActor
@Suite("HistoryModel order")
struct HistoryModelOrderTests {
    private let service = FakeHistoryService()

    private func model() -> HistoryModel {
        HistoryModel(service: service, now: { Sample.now }, pause: { _ in })
    }

    /** Holds the next list request, runs `newer`, then lets the held one answer, failing when asked. */
    private func race(_ held: @escaping @MainActor () async -> Void, newer: () async -> Void, heldFails: Bool) async {
        await service.configure { $0.holdsNextTransactions = true }
        let first = Task { await held() }
        await eventually { await service.isHolding }
        await newer()
        if heldFails { await service.configure { $0.failing = [.transactions] } }
        await service.release()
        await first.value
    }

    @Test("drops a stale first load, answered or failed", arguments: [false, true])
    func staleLoad(fails: Bool) async throws {
        let model = model()
        await race({ await model.load() }, newer: { await model.select(kind: .expense) }, heldFails: fails)
        #expect(model.phase.value != nil)
        #expect(model.kind == .expense)
    }

    @Test("drops a stale filter, answered or failed", arguments: [false, true])
    func staleFilter(fails: Bool) async throws {
        let model = model()
        await model.load()
        await race(
            { await model.select(kind: .expense) }, newer: { await model.select(kind: .income) }, heldFails: fails)
        #expect(model.phase.value != nil)
    }

    @Test("drops a stale older page")
    func staleOlderPage() async throws {
        await service.configure { $0.pages[nil] = TransactionPage(items: Sample.transactions, nextCursor: "p2") }
        let model = model()
        await model.load()
        model.showOlderDays()
        await race({ await model.loadMore() }, newer: { await model.select(kind: .income) }, heldFails: false)
        #expect(await service.queries.last?.type == .income)
    }

    @Test("keeps the shown list while it reloads, and fails a filter when the API refuses it")
    func reloadKeepsList() async throws {
        let model = model()
        await model.load()
        await service.configure { $0.holdsNextTransactions = true }
        let reload = Task { await model.load() }
        await eventually { await service.isHolding }
        #expect(model.phase.value != nil)
        await service.release()
        await reload.value
        await service.configure { $0.failing = [.transactions] }
        await model.select(category: .food)
        guard case .failed = model.phase else {
            Issue.record("expected failed")
            return
        }
    }
}
