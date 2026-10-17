import Foundation

/**
 A day of the calendar in Western Indonesian Time (WIB), as the API writes dates (`YYYY-MM-DD`):
 a transaction's day, a pay period, a renewal, a scholarship's end. It is plain arithmetic on the
 Gregorian calendar (Howard Hinnant's civil calendar algorithms), so a day never shifts with the
 device's time zone and needs no time zone database. WIB is UTC+7 all year.
 */
package struct CalendarDay: Hashable, Comparable, Sendable {
    /** WIB's offset from UTC, in seconds: seven hours, no daylight saving. */
    package static let wibOffset = 7 * 3600
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
        let seconds = Int(instant.timeIntervalSince1970.rounded(.down)) + Self.wibOffset
        self.init(daysSinceEpoch: Int((Double(seconds) / Double(Self.secondsPerDay)).rounded(.down)))
    }

    /** Reads exactly `YYYY-MM-DD`; nil for any other shape or a date the calendar does not have. */
    package init?(iso text: String) {
        let parts = text.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3, parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
            parts.allSatisfy({ $0.allSatisfy(\.isASCII) && $0.allSatisfy(\.isNumber) }),
            let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2]),
            (1...12).contains(month), (1...Self.length(ofMonth: month, in: year)).contains(day)
        else { return nil }
        self.init(year: year, month: month, day: day)
    }

    /** `YYYY-MM-DD`, as the API writes it. */
    package var iso: String {
        func padded(_ value: Int, to width: Int) -> String {
            let digits = String(value)
            return String(repeating: "0", count: max(0, width - digits.count)) + digits
        }
        return "\(padded(year, to: 4))-\(padded(month, to: 2))-\(padded(day, to: 2))"
    }

    /** Midnight at the start of the day in WIB: where a day's range begins. */
    package var start: Date {
        Date(timeIntervalSince1970: TimeInterval(daysSinceEpoch * Self.secondsPerDay - Self.wibOffset))
    }

    /**
     Noon WIB of the day, the instant to format a day from: formatted in any time zone from UTC−5
     to UTC+11 it still reads as this day, and in Indonesia always.
     */
    package var date: Date {
        Date(timeIntervalSince1970: TimeInterval(daysSinceEpoch * Self.secondsPerDay + 5 * 3600))
    }

    /**
     The day `days` later, or `months` and `years` later on the same day of the month; a day the
     later month lacks becomes its last (31 January plus one month is 28 or 29 February).
     Negative values go back.
     */
    package func adding(days: Int = 0, months: Int = 0, years: Int = 0) -> Self {
        let monthIndex = year * 12 + (month - 1) + months + years * 12
        let newYear = Int((Double(monthIndex) / 12).rounded(.down))
        let newMonth = monthIndex - newYear * 12 + 1
        let shifted = Self(year: newYear, month: newMonth, day: min(day, Self.length(ofMonth: newMonth, in: newYear)))
        return Self(daysSinceEpoch: shifted.daysSinceEpoch + days)
    }

    /** How many days from this day to `other`: 1 from today to tomorrow. */
    package func days(to other: CalendarDay) -> Int {
        other.daysSinceEpoch - daysSinceEpoch
    }

    /** Earlier days come first. */
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
        year.isMultiple(of: 4) && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
    }

    /** Days since 1 January 1970 (Hinnant's `days_from_civil`). */
    private var daysSinceEpoch: Int {
        let shiftedYear = month <= 2 ? year - 1 : year
        let era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400
        let yearOfEra = shiftedYear - era * 400
        let dayOfYear = (153 * (month > 2 ? month - 3 : month + 9) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    /** The day `days` after 1 January 1970 (Hinnant's `civil_from_days`). */
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

/** A day codes as its `YYYY-MM-DD` string. */
extension CalendarDay: Codable {
    /** Reads a `YYYY-MM-DD` string. */
    package init(from decoder: any Decoder) throws {
        let text = try decoder.singleValueContainer().decode(String.self)
        guard let day = CalendarDay(iso: text) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Not a YYYY-MM-DD date"))
        }
        self = day
    }

    /** Writes a `YYYY-MM-DD` string. */
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(iso)
    }
}
