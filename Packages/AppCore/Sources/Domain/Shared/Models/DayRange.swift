/**
 Some consecutive WIB days: the week a summary covers, the days a bank statement spans, the folded
 days of Riwayat. How much the two ends share decides how the range is written ("8–14 Oktober 2026",
 "28 September – 4 Oktober 2026"), which the app's formats read from `shape`.
 */

/** The days from `first` to `last`, both included. */
package struct DayRange: Hashable, Sendable {
    /** What the two ends share, which decides how much of the first end is written. */
    package enum Shape: Hashable, Sendable {
        /** "8–14 Oktober 2026": the first end is its day only. */
        case sameMonth
        /** "28 September–4 Oktober 2026": the first end is its day and month. */
        case sameYear
        /** "29 Desember 2025–4 Januari 2026": both ends in full. */
        case acrossYears
    }

    /** The first day. */
    package let first: CalendarDay
    /** The last day. */
    package let last: CalendarDay

    /** The days from `first` to `last`, both included. */
    package init(first: CalendarDay, last: CalendarDay) {
        self.first = first
        self.last = last
    }

    /** The days of a pay period. */
    package init(_ period: PayPeriod) {
        self.init(first: period.start, last: period.end)
    }

    /** How much of the first day the range writes. */
    package var shape: Shape {
        guard first.year == last.year else { return .acrossYears }
        return first.month == last.month ? .sameMonth : .sameYear
    }
}
