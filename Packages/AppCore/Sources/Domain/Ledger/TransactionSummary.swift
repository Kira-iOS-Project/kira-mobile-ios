/**
 The pay period and the engine's totals for it (`GET /me` period, `GET /transactions/summary`):
 Riwayat shows them as they come, it never adds transactions up itself.
 */

/** The payday period: from the last payday to the day before the next. */
package struct PayPeriod: Hashable, Sendable {
    package let start: CalendarDay
    package let end: CalendarDay

    package init(start: CalendarDay, end: CalendarDay) {
        self.start = start
        self.end = end
    }
}

/** Money out and money in on one day. */
package struct DayTotals: Hashable, Sendable {
    package let day: CalendarDay
    package let expense: Int
    package let income: Int

    package init(day: CalendarDay, expense: Int, income: Int) {
        self.day = day
        self.expense = expense
        self.income = income
    }
}

/** The totals of a period and of each of its days. */
package struct TransactionSummary: Hashable, Sendable {
    package let expense: Int
    package let income: Int
    package let days: [DayTotals]

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
    package let items: [Transaction]
    package let nextCursor: String?

    package init(items: [Transaction], nextCursor: String?) {
        self.items = items
        self.nextCursor = nextCursor
    }
}

/** What `GET /transactions` asks for. */
package struct TransactionQuery: Hashable, Sendable {
    package let from: CalendarDay
    package let to: CalendarDay
    package let type: TransactionType?
    package let category: TransactionCategory?
    /** The search text, trimmed; nil when empty. */
    package let text: String?
    package let cursor: String?
    package let limit: Int

    package init(
        from: CalendarDay, to: CalendarDay, type: TransactionType? = nil, category: TransactionCategory? = nil,
        text: String? = nil, cursor: String? = nil, limit: Int
    ) {
        self.from = from
        self.to = to
        self.type = type
        self.category = category
        self.text = text
        self.cursor = cursor
        self.limit = limit
    }
}
