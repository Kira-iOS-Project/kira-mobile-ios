/**
 The date formats of Riwayat, Detail Transaksi and Impor Mutasi, written the one way Kira writes
 dates: in full, in Indonesian, in WIB ("Kamis, 15 Oktober 2026 · 12.41 WIB"). Like
 RupiahFormatStyle they are a product rule rather than a regional preference, so they name their
 locale and time zone instead of following the device's.
 */
import Domain
import Foundation

/** Kira's date formats, in WIB. */
enum KiraDateFormat {
    /** Western Indonesia Time, which the API writes dates in. */
    static let timeZone = TimeZone(identifier: "Asia/Jakarta") ?? .current
    private static let locale = Locale(identifier: "id_ID")

    /** "15 Oktober 2026". */
    static let day = style("\(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits)")
    /** "Kamis 15 Oktober 2026", as a day's group title writes it. */
    static let weekdayDay = style("\(weekday: .wide) \(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits)")
    /** "Kamis, 15 Oktober 2026". */
    static let weekdayDayComma = style(
        "\(weekday: .wide), \(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits)")
    /** "12.41". */
    static let time = style("\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)).\(minute: .twoDigits)")
    /** "15 Oktober". */
    static let dayMonth = style("\(day: .defaultDigits) \(month: .wide)")
    /** "15". */
    static let dayNumber = style("\(day: .defaultDigits)")

    /** "Kamis, 15 Oktober 2026 · 12.41 WIB": when a transaction happened. */
    static func dateTime(_ date: Date) -> LocalizedStringResource {
        "transaction.dateTime \(weekdayDayComma.format(date)) \(time.format(date))"
    }

    /** "15 Oktober 2026 · 12.41 WIB": when a message was sent. */
    static func dayTime(_ date: Date) -> LocalizedStringResource {
        "history.dayTime \(day.format(date)) \(time.format(date))"
    }

    private static func style(_ format: Date.FormatString) -> Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(
            format: format, locale: locale, timeZone: timeZone, calendar: Calendar(identifier: .gregorian))
    }
}

/** Two days written as one range: "1–30 September 2026", "25 September – 24 Oktober 2026". */
struct DayRangeFormatStyle: FormatStyle {
    /** The first and last day of the range. */
    struct Range: Hashable, Codable {
        let first: CalendarDay
        let last: CalendarDay
    }

    func format(_ range: Range) -> String {
        let first = range.first.start
        let last = range.last.start
        guard range.first != range.last else { return KiraDateFormat.day.format(first) }
        if range.first.year == range.last.year, range.first.month == range.last.month {
            return KiraDateFormat.dayNumber.format(first) + "–" + KiraDateFormat.day.format(last)
        }
        let start = range.first.year == range.last.year ? KiraDateFormat.dayMonth : KiraDateFormat.day
        return start.format(first) + " – " + KiraDateFormat.day.format(last)
    }
}

extension DayRangeFormatStyle.Range {
    /** The range of a pay period. */
    init(_ period: PayPeriod) {
        self.init(first: period.start, last: period.end)
    }
}
