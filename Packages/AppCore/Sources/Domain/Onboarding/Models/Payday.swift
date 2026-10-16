/**
 Tanggal Gajian (ONB-10b, ONB-10c): the day pay arrives each month, which sets the budget period
 (25 September – 24 Oktober). "Gajian di akhir bulan" means the last day of every month,
 February included, which the server resolves.
 */

/** The day of the month pay arrives, or the end of every month. */
package struct Payday: Hashable, Sendable {
    /** The day the calendar sheet starts on. */
    package static let defaultDay = 25
    /** The days the calendar offers. */
    package static let days = Array(1...31)

    /** The day, 1–31; nil when pay arrives at the end of the month. */
    package let day: Int?

    /** Pay on `day` of every month, clamped to 1...31. */
    package init(day: Int) {
        self.day = min(max(day, 1), 31)
    }

    private init() {
        day = nil
    }

    /** Pay on the last day of every month. */
    package static let endOfMonth = Self()

    /** Whether pay arrives at the end of every month. */
    package var isEndOfMonth: Bool { day == nil }
}
