/**
 What Ringkasan Mingguan says about a week, from its numbers alone: how it compares with the week
 before, its busiest and quietest days, the four largest categories with whole percentages adding
 up to their share, and whether the weekend took the most.
 */
package struct WeeklySummaryReading: Sendable {
    /** How this week compares with the one before. */
    package enum Comparison: Equatable, Sendable {
        /** Spent less, by the amount. */
        case less(Int)
        /** Spent more, by the amount. */
        case more(Int)
        /** Spent the same. */
        case same
    }

    /** A category and its whole share of the week's total. */
    package struct Share: Hashable, Sendable {
        /** The category and what it took. */
        package let spending: CategorySpending
        /** Its share of the total, 0…100. */
        package let percent: Int
    }

    /** How many categories "Terbesar Minggu Ini" lists. */
    package static let topCount = 4
    /** The weekend's share of the week from which the note calls the weekend the heaviest. */
    package static let weekendHeavyShare = 0.4
    /** A Sunday, from which the days of the week are counted. */
    private static let sunday = CalendarDay(year: 2026, month: 10, day: 11)

    private let summary: WeeklySummary

    /** The reading of `summary`. */
    package init(_ summary: WeeklySummary) {
        self.summary = summary
    }

    /** Less, more or the same as the week before. */
    package var comparison: Comparison {
        let difference = summary.total - summary.previousTotal
        if difference < 0 { return .less(-difference) }
        return difference > 0 ? .more(difference) : .same
    }

    /** The day that took the most (the earliest of equals), or nil without spending. */
    package var busiest: DaySpending? {
        guard summary.total > 0 else { return nil }
        return summary.days.reduce(nil) { best, day in day.amount > (best?.amount ?? -1) ? day : best }
    }

    /** The day that took the least (the earliest of equals), or nil without spending. */
    package var quietest: DaySpending? {
        guard summary.total > 0 else { return nil }
        return summary.days.reduce(nil) { least, day in day.amount < (least?.amount ?? .max) ? day : least }
    }

    /** The four largest categories, each with its whole share of the total. */
    package var top: [Share] {
        let spending = Array(summary.categories.prefix(Self.topCount))
        let shares = PortfolioShares.wholePercents(summary.categories.map(\.amount))
        return zip(spending, shares).map { Share(spending: $0, percent: $1) }
    }

    /** Whether Saturday and Sunday together took at least 40% of the week. */
    package var isWeekendHeavy: Bool {
        guard summary.total > 0 else { return false }
        let weekend = summary.days.filter { Self.isWeekend($0.day) }.map(\.amount).reduce(0, +)
        return Double(weekend) >= Self.weekendHeavyShare * Double(summary.total)
    }

    /** Whether `day` is a Saturday or a Sunday. */
    package static func isWeekend(_ day: CalendarDay) -> Bool {
        let weekday = ((sunday.days(to: day) % 7) + 7) % 7
        return weekday == 0 || weekday == 6
    }
}
