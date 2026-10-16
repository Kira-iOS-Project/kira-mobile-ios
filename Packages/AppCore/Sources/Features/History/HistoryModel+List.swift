import APIClient
import Domain
import Foundation

/** How Riwayat asks for its list and turns the answers into sections. */
extension HistoryModel {
    /** Whether a filter or a search narrows the list, so an empty answer is not an empty period. */
    var isFiltered: Bool { kind != .all || category != nil || !Self.normalized(searchText).isEmpty }

    /** Asks for the first page again under the current filters, keeping the period's totals. */
    func reloadList() async {
        guard let context else { return await load() }
        generation += 1
        let current = generation
        appliedSearch = Self.normalized(searchText)
        do {
            let page = try await service.transactions(query(context.period, cursor: nil))
            guard current == generation else { return }
            show(page, appending: false)
        } catch {
            guard current == generation else { return }
            phase = .failed(historyProblem(error))
        }
    }

    /** The request for one page of the period under the current filters. */
    func query(_ period: PayPeriod, cursor: String?) -> TransactionQuery {
        TransactionQuery(
            start: period.start, end: period.end, type: kind.type, category: category,
            text: appliedSearch.isEmpty ? nil : appliedSearch, cursor: cursor, limit: Self.pageSize)
    }

    /** Takes a page in and shows the list. */
    func show(_ page: TransactionPage, appending: Bool) {
        items = appending ? items + page.items : page.items
        cursor = page.nextCursor
        publish()
    }

    /** Lays the loaded transactions out by day, folded unless opened. */
    func publish() {
        guard let context else { return }
        let days = HistoryTimeline.days(
            items, summary: context.summary, period: context.period, today: CalendarDay(now()))
        if days.isEmpty, !isFiltered {
            phase = .empty
            return
        }
        let sections = HistoryTimeline.sections(days, period: context.period, isExpanded: isExpanded)
        let folds = sections.contains { section in
            if case .olderDays = section { return true }
            return false
        }
        phase = .loaded(
            Content(
                period: context.period, summary: context.summary, sections: sections,
                canLoadMore: cursor != nil && !folds))
    }

    /** Search text as it is sent: trimmed of surrounding spaces. */
    static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/** The API's problem behind `error`, or a problem without a code for anything else. */
func historyProblem(_ error: any Error) -> AppProblem {
    (error as? AppProblem) ?? AppProblem()
}
