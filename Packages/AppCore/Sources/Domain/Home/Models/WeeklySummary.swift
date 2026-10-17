/**
 Ringkasan Mingguan (UNG-08): seven WIB days of spending, the week before's total, and the
 categories spent on, largest first. The server sends numbers only; the sentences are the app's.
 */
package struct WeeklySummary: Hashable, Sendable {
    /** The first day, seven days before `end`'s next. */
    package let start: CalendarDay
    /** The last day, included. */
    package let end: CalendarDay
    /** Spending this week, in whole rupiah. */
    package let total: Int
    /** Spending in the seven days before. */
    package let previousTotal: Int
    /** Each day's spending, oldest first; a day without spending is 0. */
    package let days: [DaySpending]
    /** Every category spent on, largest first. */
    package let categories: [CategorySpending]

    /** A week as the API sends it. */
    package init(
        start: CalendarDay, end: CalendarDay, total: Int, previousTotal: Int, days: [DaySpending],
        categories: [CategorySpending]
    ) {
        self.start = start
        self.end = end
        self.total = total
        self.previousTotal = previousTotal
        self.days = days
        self.categories = categories
    }
}

/** One day's spending. */
package struct DaySpending: Hashable, Sendable {
    /** The WIB day. */
    package let day: CalendarDay
    /** What was spent. */
    package let amount: Int

    /** `amount` spent on `day`. */
    package init(day: CalendarDay, amount: Int) {
        self.day = day
        self.amount = amount
    }
}

/** What one category took this week. */
package struct CategorySpending: Hashable, Sendable {
    /** The category. */
    package let category: TransactionCategory
    /** What was spent on it. */
    package let amount: Int

    /** `amount` spent on `category`. */
    package init(category: TransactionCategory, amount: Int) {
        self.category = category
        self.amount = amount
    }
}
