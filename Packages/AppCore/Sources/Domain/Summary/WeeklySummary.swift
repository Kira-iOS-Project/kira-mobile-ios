import Foundation

/** The whole-rupiah totals for one Thursday-to-Wednesday period. */
package struct WeeklyTotals: Hashable, Sendable {
    /** Money spent. */
    package let expense: Int
    /** Money received. */
    package let income: Int
    /** Income less expenses. */
    package let net: Int

    /** Totals calculated by the transaction engine. */
    package init(expense: Int, income: Int, net: Int) {
        self.expense = expense
        self.income = income
        self.net = net
    }
}

/** One day's amount in the weekly chart. */
package struct WeeklySummaryDay: Hashable, Identifiable, Sendable {
    /** The day used as the stable chart identity. */
    package var id: CalendarDay { date }
    /** The chart's date in WIB. */
    package let date: CalendarDay
    /** The day's expense total. */
    package let expense: Int
    /** The day's income total. */
    package let income: Int

    /** One of the seven server-calculated day totals. */
    package init(date: CalendarDay, expense: Int, income: Int) {
        self.date = date
        self.expense = expense
        self.income = income
    }
}

/** One of the four largest spending categories. */
package struct WeeklyTopCategory: Hashable, Identifiable, Sendable {
    /** The category key is unique in one period. */
    package var id: String { category }
    /** The API category key. */
    package let category: String
    /** The category's display name from the API or catalogue. */
    package let name: String
    /** The whole-rupiah total. */
    package let amount: Int

    /** A category total calculated by the transaction engine. */
    package init(category: String, name: String, amount: Int) {
        self.category = category
        self.name = name
        self.amount = amount
    }
}

/** A closed Thursday-to-Wednesday summary, compared with the preceding week. */
package struct WeeklySummary: Hashable, Sendable {
    /** The Thursday beginning the week. */
    package let weekStart: CalendarDay
    /** The following Wednesday. */
    package var weekEnd: CalendarDay { weekStart.adding(days: 6) }
    /** This period's totals. */
    package let totals: WeeklyTotals
    /** The preceding period's totals. */
    package let previousTotals: WeeklyTotals
    /** The seven daily bars. */
    package let days: [WeeklySummaryDay]
    /** Up to four highest expense categories. */
    package let topCategories: [WeeklyTopCategory]
    /** One deterministic, neutral note; nil when there is no activity. */
    package let note: String?

    /** A summary from the server's deterministic calculations. */
    package init(
        weekStart: CalendarDay, totals: WeeklyTotals, previousTotals: WeeklyTotals,
        days: [WeeklySummaryDay], topCategories: [WeeklyTopCategory], note: String?
    ) {
        self.weekStart = weekStart
        self.totals = totals
        self.previousTotals = previousTotals
        self.days = days
        self.topCategories = topCategories
        self.note = note
    }

    /** The period contains no transaction activity, so the screen uses its empty state. */
    package var isEmpty: Bool { totals.expense == 0 && totals.income == 0 }

    /** The absolute change in spending from the preceding week. */
    package var expenseDifference: Int { abs(totals.expense - previousTotals.expense) }

    /** Whether spending increased compared with the preceding week. */
    package var spendingIncreased: Bool { totals.expense > previousTotals.expense }

    /** Whether spending was unchanged compared with the preceding week. */
    package var spendingUnchanged: Bool { totals.expense == previousTotals.expense }

    /** The most recently completed week on or before `today`, Thursday through Wednesday. */
    package static func latestCompletedWeekStart(
        on today: CalendarDay, wibOffset: Int = CalendarDay.wibOffset
    ) -> CalendarDay {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: wibOffset) ?? .gmt
        let weekday = calendar.component(.weekday, from: today.date)
        let daysSinceThursday = (weekday - 5 + 7) % 7
        return today.adding(days: -daysSinceThursday - 7)
    }
}
