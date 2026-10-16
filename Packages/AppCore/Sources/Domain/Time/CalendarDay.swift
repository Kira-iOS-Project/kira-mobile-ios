import Foundation

/**
 A day of the calendar in Western Indonesian Time (WIB), as the API writes dates (`YYYY-MM-DD`):
 a renewal, a reminder, a scholarship's end. It is plain arithmetic on the Gregorian calendar, so a
 day never shifts with the device's time zone; `date` is the instant to format it from.
 */
package struct CalendarDay: Hashable, Comparable, Sendable {
    /** WIB is seven hours ahead of UTC all year (Indonesia keeps no daylight saving). */
    private static let offset = 7 * 3600
    private static let secondsPerDay = 86_400

    /** The year, such as 2026. */
    package let year: Int
    /** The month, 1 to 12. */
    package let month: Int
    /** The day of the month, 1 to 31. */
    package let day: Int

    /** The given day; the caller passes a real one. */
    package init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /** The WIB day an instant falls on. */
    package init(_ instant: Date) {
        let seconds = Int(instant.timeIntervalSince1970.rounded(.down)) + Self.offset
        let days = Int((Double(seconds) / Double(Self.secondsPerDay)).rounded(.down))
        self = Self(daysSinceEpoch: days)
    }

    /** A day written `YYYY-MM-DD`, or nil when the text is not one. */
    package init?(iso text: String) {
        let parts = text.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3, (1...12).contains(parts[1]),
            (1...Self.length(ofMonth: parts[1], in: parts[0])).contains(parts[2])
        else { return nil }
        self.init(year: parts[0], month: parts[1], day: parts[2])
    }

    /**
     Noon WIB of the day: formatted in any time zone from UTC−5 to UTC+11 it still reads as this
     day, and in Indonesia always.
     */
    package var date: Date {
        Date(timeIntervalSince1970: TimeInterval(daysSinceEpoch * Self.secondsPerDay + 5 * 3600))
    }

    /** `YYYY-MM-DD`, as the API writes it. */
    package var iso: String {
        let monthText = month < 10 ? "0\(month)" : "\(month)"
        let dayText = day < 10 ? "0\(day)" : "\(day)"
        return "\(year)-\(monthText)-\(dayText)"
    }

    /**
     The day `days` later, or `months` and `years` later on the same day of the month; a day the
     later month lacks becomes its last (31 January plus one month is 28 or 29 February).
     */
    package func adding(days: Int = 0, months: Int = 0, years: Int = 0) -> Self {
        let monthIndex = year * 12 + (month - 1) + months + years * 12
        let newYear = Int((Double(monthIndex) / 12).rounded(.down))
        let newMonth = monthIndex - newYear * 12 + 1
        let shifted = Self(year: newYear, month: newMonth, day: min(day, Self.length(ofMonth: newMonth, in: newYear)))
        return Self(daysSinceEpoch: shifted.daysSinceEpoch + days)
    }

    /** Whether `lhs` comes before `rhs`. */
    package static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.daysSinceEpoch < rhs.daysSinceEpoch
    }

    /** The number of days in a month of a year. */
    package static func length(ofMonth month: Int, in year: Int) -> Int {
        switch month {
        case 2: isLeap(year) ? 29 : 28
        case 4, 6, 9, 11: 30
        default: 31
        }
    }

    private static func isLeap(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }

    /** Days since 1 January 1970 (Howard Hinnant's days_from_civil). */
    private var daysSinceEpoch: Int {
        let shiftedYear = month <= 2 ? year - 1 : year
        let era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400
        let yearOfEra = shiftedYear - era * 400
        let dayOfYear = (153 * (month > 2 ? month - 3 : month + 9) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    /** The day `days` after 1 January 1970 (Howard Hinnant's civil_from_days). */
    private init(daysSinceEpoch days: Int) {
        let shifted = days + 719_468
        let era = (shifted >= 0 ? shifted : shifted - 146_096) / 146_097
        let dayOfEra = shifted - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let monthPrime = (5 * dayOfYear + 2) / 153
        let day = dayOfYear - (153 * monthPrime + 2) / 5 + 1
        let month = monthPrime < 10 ? monthPrime + 3 : monthPrime - 9
        self.init(year: yearOfEra + era * 400 + (month <= 2 ? 1 : 0), month: month, day: day)
    }
}
