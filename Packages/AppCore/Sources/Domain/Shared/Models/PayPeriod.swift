/**
 The pay period a budget, a summary and the history cover (`GET /me`'s and `GET /home`'s
 `period`): from one payday to the day before the next, both WIB days, and how far away the next
 payday is ("gajian 10 hari lagi").
 */
package struct PayPeriod: Hashable, Sendable {
    /** The payday that opens the period. */
    package let start: CalendarDay
    /** The day before the next payday, the period's last day. */
    package let end: CalendarDay
    /** Days from today until the next payday, as the API counted them; 0 is today. */
    package let daysUntilPayday: Int

    /** The period from `start` to `end`, both included, with the next payday `daysUntilPayday` away. */
    package init(start: CalendarDay, end: CalendarDay, daysUntilPayday: Int) {
        self.start = start
        self.end = end
        self.daysUntilPayday = daysUntilPayday
    }
}
