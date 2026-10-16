/**
 The pay period a budget, a summary and the history cover (`GET /me`'s `period`): from one payday
 to the day before the next, both WIB days.
 */
package struct PayPeriod: Hashable, Sendable {
    /** The payday that opens the period. */
    package let start: CalendarDay
    /** The day before the next payday, the period's last day. */
    package let end: CalendarDay

    /** The period from `start` to `end`, both included. */
    package init(start: CalendarDay, end: CalendarDay) {
        self.start = start
        self.end = end
    }
}
