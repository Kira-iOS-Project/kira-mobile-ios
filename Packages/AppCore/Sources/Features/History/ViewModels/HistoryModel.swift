import APIClient
import Domain
import Foundation
import Observation

/**
 Riwayat Transaksi (CAT-07): the pay period's transactions, searched and filtered by type and
 category, grouped by day under the engine's totals. Each new filter or search replaces the list;
 a response that arrives after a newer request started is dropped, so a slow answer never shows
 the wrong filter.
 */
@MainActor
@Observable
package final class HistoryModel {
    /** The segmented filter: Semua, Keluar, Masuk. */
    package enum Kind: CaseIterable, Hashable, Sendable {
        /** Semua, Keluar and Masuk. */
        case all, expense, income

        /** The transaction type the filter asks for; nil for all. */
        package var type: TransactionType? {
            switch self {
            case .all: nil
            case .expense: .expense
            case .income: .income
            }
        }
    }

    /** What the loaded screen shows. */
    package struct Content: Sendable {
        /** The pay period the list covers. */
        package let period: PayPeriod
        /** The engine's totals of the period and its days. */
        package let summary: TransactionSummary
        /** The list's blocks, newest first. */
        package let sections: [HistorySection]
        /** Whether older pages wait to load when the list's end appears. */
        package let canLoadMore: Bool
    }

    /** Transactions asked for per page. */
    package static let pageSize = 50
    /** How long typing pauses before the search runs. */
    package static let searchDelay = Duration.milliseconds(350)

    /** Loading, empty (no transaction this period), loaded, or failed. */
    package internal(set) var phase: ScreenPhase<Content> = .loading
    /** The search field's text; the list follows it after `searchChanged()`. */
    package var searchText = ""
    /** The chosen segment. */
    package private(set) var kind = Kind.all
    /** The chosen category chip; nil for Semua Kategori. */
    package private(set) var category: TransactionCategory?
    /**
     Where the upload icon leads: Impor Mutasi, also before the account has loaded (the API still
     refuses a plan without it, and the import step offers the plans then), or Paket Kira.
     */
    package private(set) var importEntry = ImportEntry.importer

    /** Internal, not private: `HistoryModel+List.swift` lays the list out from them. */
    let service: any HistoryService
    let now: @Sendable () -> Date
    private let pause: @Sendable (Duration) async throws -> Void
    var context: (period: PayPeriod, summary: TransactionSummary)?
    var items: [Transaction] = []
    var cursor: String?
    var isExpanded = false
    private var isLoadingMore = false
    /** Why the last older page did not load; the list's end then offers Coba Lagi instead of a spinner. */
    package internal(set) var moreFailure: AppProblem?
    /** Counts requests, so an answer to an older one is dropped. */
    var generation = 0
    var appliedSearch = ""

    /** A history read through `service`; `now` and `pause` are the clock, replaceable in tests. */
    package init(
        service: any HistoryService, now: @escaping @Sendable () -> Date = { Date() },
        pause: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.service = service
        self.now = now
        self.pause = pause
    }

    /** The category chips for the chosen kind: expense categories, or income ones under Masuk. */
    package var categories: [TransactionCategory] {
        TransactionCategory.allCases.filter { $0.type == (kind.type ?? .expense) }
    }

    /** Loads the period, its totals and the newest page; the shown list stays while it reloads. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        generation += 1
        let current = generation
        appliedSearch = Self.normalized(searchText)
        do {
            let account = try await service.currentAccount()
            let period = account.period
            importEntry = account.canImport ? .importer : .plans
            async let summary = service.summary(from: period.start, to: period.end)
            async let page = service.transactions(query(period, cursor: nil))
            let (loadedSummary, loadedPage) = try await (summary, page)
            guard current == generation else { return }
            context = (period, loadedSummary)
            show(loadedPage, appending: false)
        } catch {
            guard current == generation else { return }
            phase = .failed(historyProblem(error))
        }
    }

    /** Shows one kind of transaction; a chosen category of the other direction is cleared. */
    package func select(kind: Kind) async {
        self.kind = kind
        if let category, !categories.contains(category) { self.category = nil }
        await reloadList()
    }

    /** Shows one category, or every category for nil. */
    package func select(category: TransactionCategory?) async {
        self.category = category
        await reloadList()
    }

    /** Hapus Filter, when nothing matches: the search, the segment and the category back to all. */
    package func clearFilters() async {
        searchText = ""
        kind = .all
        category = nil
        await reloadList()
    }

    /** Runs the search once typing pauses; a newer keystroke cancels the wait. */
    package func searchChanged() async {
        do { try await pause(Self.searchDelay) } catch { return }
        guard Self.normalized(searchText) != appliedSearch else { return }
        await reloadList()
    }

    /** Opens the folded days ("Tampilkan …"); older pages then load as the end appears. */
    package func showOlderDays() {
        isExpanded = true
        publish()
    }

    /**
     Loads the next older page, and again on Coba Lagi. A failure leaves the list as it is and keeps
     its problem in `moreFailure`, so the list's end shows it with Coba Lagi rather than a spinner
     that nothing would ask again.
     */
    package func loadMore() async {
        guard let context, let cursor, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        moreFailure = nil
        let current = generation
        do {
            let page = try await service.transactions(query(context.period, cursor: cursor))
            guard current == generation else { return }
            show(page, appending: true)
        } catch {
            guard current == generation else { return }
            moreFailure = historyProblem(error)
        }
    }
}
