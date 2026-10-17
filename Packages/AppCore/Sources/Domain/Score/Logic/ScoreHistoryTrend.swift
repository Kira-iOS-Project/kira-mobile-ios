/**
 The shape of a score history, which the screen words: how far the score moved from the first
 month shown to now, and whether there is enough data to say so (two months or more).
 */
package struct ScoreHistoryTrend: Hashable, Sendable {
    /** Which way the score went. */
    package enum Direction: Sendable {
        /** The score went up. */
        case rising
        /** The score went down. */
        case falling
        /** The score is where it was. */
        case steady
    }

    /** The first month shown. */
    package let since: CalendarDay
    /** The last month shown, now. */
    package let until: CalendarDay
    /** The score that month. */
    package let start: Int
    /** The score now (the last month). */
    package let end: Int

    /** The trend of `points`, oldest first; nil with fewer than two months. */
    package init?(_ points: [ScoreHistoryPoint]) {
        guard points.count >= 2, let first = points.first, let last = points.last else { return nil }
        since = first.month
        until = last.month
        start = first.score
        end = last.score
    }

    /** Points moved, always positive; the direction says which way. */
    package var points: Int { abs(end - start) }

    /** Up, down or flat. */
    package var direction: Direction {
        if end > start { return .rising }
        return end < start ? .falling : .steady
    }

    /** Whether the first month is in another year than now, so its name needs the year. */
    package var crossesYear: Bool { since.year != until.year }
}
