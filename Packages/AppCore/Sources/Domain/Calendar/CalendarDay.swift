/**
 A day on the calendar in Western Indonesia Time (WIB, UTC+7 all year, no daylight saving): the API
 writes dates as `YYYY-MM-DD` in WIB. The day is computed with plain arithmetic on the days since
 1970 (Howard Hinnant's civil calendar algorithms), so it needs no time zone database.
 */
import Foundation

/** A calendar day in WIB, ordered by date. */
package struct CalendarDay: Hashable, Comparable, Codable, Sendable {
    /** WIB's offset from UTC, in seconds. */
    package static let wibOffset = 7 * 3600
    private static let secondsPerDay = 86_400

    /** The year, such as 2026. */
    package let year: Int
    /** The month, 1 to 12. */
    package let month: Int
    /** The day of the month, 1 to 31. */
    package let day: Int

    /** The day with these parts, which the caller knows to be a real date. */
    package init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /** The WIB day `date` falls on. */
    package init(_ date: Date) {
        let seconds = Int(date.timeIntervalSince1970.rounded(.down)) + Self.wibOffset
        self.init(daysSince1970: Int((Double(seconds) / Double(Self.secondsPerDay)).rounded(.down)))
    }

    /** Reads `YYYY-MM-DD`; nil for any other shape or a date the calendar does not have. */
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

    /** Midnight at the start of this day in WIB. */
    package var start: Date {
        Date(timeIntervalSince1970: TimeInterval(daysSince1970 * Self.secondsPerDay - Self.wibOffset))
    }

    /** The day `count` days later (earlier when negative). */
    package func adding(days count: Int) -> CalendarDay {
        CalendarDay(daysSince1970: daysSince1970 + count)
    }

    /** How many days from this day to `other`: 1 from today to tomorrow. */
    package func days(to other: CalendarDay) -> Int {
        other.daysSince1970 - daysSince1970
    }

    /** Earlier days come first. */
    package static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        lhs.daysSince1970 < rhs.daysSince1970
    }

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

    /** The number of days in `month` of `year`. */
    private static func length(ofMonth month: Int, in year: Int) -> Int {
        switch month {
        case 2: isLeap(year) ? 29 : 28
        case 4, 6, 9, 11: 30
        default: 31
        }
    }

    private static func isLeap(_ year: Int) -> Bool {
        year.isMultiple(of: 4) && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
    }

    /** Days since 1970-01-01 (Hinnant's `days_from_civil`). */
    private var daysSince1970: Int {
        let shiftedYear = month <= 2 ? year - 1 : year
        let era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400
        let yearOfEra = shiftedYear - era * 400
        let dayOfYear = (153 * (month + (month > 2 ? -3 : 9)) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    /** The day `days` after 1970-01-01 (Hinnant's `civil_from_days`). */
    private init(daysSince1970 days: Int) {
        let shifted = days + 719_468
        let era = (shifted >= 0 ? shifted : shifted - 146_096) / 146_097
        let dayOfEra = shifted - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let shiftedMonth = (5 * dayOfYear + 2) / 153
        let day = dayOfYear - (153 * shiftedMonth + 2) / 5 + 1
        let month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9
        let year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0)
        self.init(year: year, month: month, day: day)
    }
}
