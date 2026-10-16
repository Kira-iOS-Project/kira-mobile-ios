/**
 The pay period and the engine's totals for it (`GET /me` period, `GET /transactions/summary`):
 Riwayat shows them as they come, it never adds transactions up itself.
 */

/** The payday period: from the last payday to the day before the next. */
package struct PayPeriod: Hashable, Sendable {
    /** The payday that opens the period. */
    package let start: CalendarDay
    /** The last day of the period. */
    package let end: CalendarDay

    /** The period from `start` to `end`, both included. */
    package init(start: CalendarDay, end: CalendarDay) {
        self.start = start
        self.end = end
    }
}

/** Money out and money in on one day. */
package struct DayTotals: Hashable, Sendable {
    /** The day. */
    package let day: CalendarDay
    /** Money out that day, in whole rupiah. */
    package let expense: Int
    /** Money in that day, in whole rupiah. */
    package let income: Int

    /** The totals of `day`. */
    package init(day: CalendarDay, expense: Int, income: Int) {
        self.day = day
        self.expense = expense
        self.income = income
    }
}

/** The totals of a period and of each of its days. */
package struct TransactionSummary: Hashable, Sendable {
    /** Money out in the period, in whole rupiah. */
    package let expense: Int
    /** Money in in the period, in whole rupiah. */
    package let income: Int
    /** The days that have transactions. */
    package let days: [DayTotals]

    /** The totals of a period. */
    package init(expense: Int, income: Int, days: [DayTotals]) {
        self.expense = expense
        self.income = income
        self.days = days
    }

    /** The totals of `day`, zero when the summary does not list it. */
    package func totals(on day: CalendarDay) -> DayTotals {
        days.first { $0.day == day } ?? DayTotals(day: day, expense: 0, income: 0)
    }
}

/** A page of transactions, newest first, and the cursor of the next older page. */
package struct TransactionPage: Hashable, Sendable {
    /** The page's transactions, newest first. */
    package let items: [Transaction]
    /** The cursor of the next older page; nil on the last. */
    package let nextCursor: String?

    /** A page and the cursor after it. */
    package init(items: [Transaction], nextCursor: String?) {
        self.items = items
        self.nextCursor = nextCursor
    }
}

/** What `GET /transactions` asks for. */
package struct TransactionQuery: Hashable, Sendable {
    /** The first day asked for. */
    package let start: CalendarDay
    /** The last day asked for. */
    package let end: CalendarDay
    /** Only this direction; nil for both. */
    package let type: TransactionType?
    /** Only this category; nil for all. */
    package let category: TransactionCategory?
    /** The search text, trimmed; nil when empty. */
    package let text: String?
    /** The page after this cursor; nil for the newest. */
    package let cursor: String?
    /** The most transactions on the page. */
    package let limit: Int

    /** A request for one page. */
    package init(
        start: CalendarDay, end: CalendarDay, type: TransactionType? = nil, category: TransactionCategory? = nil,
        text: String? = nil, cursor: String? = nil, limit: Int
    ) {
        self.start = start
        self.end = end
        self.type = type
        self.category = category
        self.text = text
        self.cursor = cursor
        self.limit = limit
    }
}
