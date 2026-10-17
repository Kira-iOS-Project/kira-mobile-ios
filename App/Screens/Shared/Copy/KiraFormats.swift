/**
 Dates and decimal numbers the way Kira writes them, whatever the device's region: Indonesian
 words in WIB ("Kamis, 15 Oktober 2026 · 12.41 WIB"), day ranges ("1–30 September 2026") and a
 decimal comma ("1,1×"). Like `RupiahFormatStyle`, the format is a product rule, not a regional
 preference (docs/design-system.md), so the styles name their locale and time zone.
 */
import Domain
import Foundation

private let indonesian = Locale(identifier: "id_ID")
private let gregorian = Calendar(identifier: .gregorian)
private let wib = Date.FormatStyle(locale: indonesian, calendar: gregorian, timeZone: KiraDateFormat.timeZone)

/** Kira's calendar settings and the dated phrases built from the styles below. */
enum KiraDateFormat {
    /** Western Indonesia Time, UTC+7 all year, which every date of the API is in. */
    static let timeZone = TimeZone(secondsFromGMT: CalendarDay.wibOffset) ?? .gmt

    /** "Kamis, 15 Oktober 2026 · 12.41 WIB": when a transaction happened. */
    static func dateTime(_ date: Date) -> LocalizedStringResource {
        "transaction.dateTime \(date.formatted(.kiraWeekdayDate)) \(date.formatted(.kiraTime))"
    }

    /** "15 Oktober 2026 · 12.41 WIB": when a message was sent. */
    static func dayTime(_ date: Date) -> LocalizedStringResource {
        "history.dayTime \(date.formatted(.kiraDate)) \(date.formatted(.kiraTime))"
    }
}

extension FormatStyle where Self == Date.FormatStyle {
    /** "Kamis, 15 Oktober 2026". */
    static var kiraWeekdayDate: Date.FormatStyle { wib.weekday(.wide).day().month(.wide).year() }

    /** "15 Oktober 2026". */
    static var kiraDate: Date.FormatStyle { wib.day().month(.wide).year() }

    /** "28 September", the first end of a range within one year. */
    static var kiraDayMonth: Date.FormatStyle { wib.day().month(.wide) }

    /** "Oktober", the month a quota or a period names. */
    static var kiraMonth: Date.FormatStyle { wib.month(.wide) }

    /** "April 2029", when a goal is reached. */
    static var kiraMonthYear: Date.FormatStyle { wib.month(.wide).year() }

    /** "12.41", a time written before "WIB". */
    static var kiraTime: Date.FormatStyle { wib.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits) }
}

extension FormatStyle where Self == Date.VerbatimFormatStyle {
    /** "Kamis 15 Oktober 2026", a day's group title in Riwayat (no comma, as the board writes it). */
    static var kiraGroupDate: Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(
            format: "\(weekday: .wide) \(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits)",
            locale: indonesian, timeZone: KiraDateFormat.timeZone, calendar: gregorian)
    }
}

extension DayRange {
    /** The first day, as much of it as the last day does not already say: "8", "28 September". */
    var firstEnd: String {
        switch shape {
        case .sameMonth: String(first.day)
        case .sameYear: first.date.formatted(.kiraDayMonth)
        case .acrossYears: first.date.formatted(.kiraDate)
        }
    }

    /** The last day in full: "14 Oktober 2026". */
    var lastEnd: String { last.date.formatted(.kiraDate) }

    /** The range written with `style`, as Foundation's own values are: `range.formatted(.kiraDayRange)`. */
    func formatted(_ style: DayRangeFormatStyle) -> String {
        style.format(self)
    }
}

/** A range written whole, as Riwayat and Impor Mutasi do: "1–30 September 2026", "25 September – 24 Oktober 2026". */
struct DayRangeFormatStyle: FormatStyle {
    func format(_ range: DayRange) -> String {
        guard range.first != range.last else { return range.lastEnd }
        return range.firstEnd + (range.shape == .sameMonth ? "–" : " – ") + range.lastEnd
    }
}

extension FormatStyle where Self == DayRangeFormatStyle {
    /** A range written whole: "1–30 September 2026". */
    static var kiraDayRange: DayRangeFormatStyle { DayRangeFormatStyle() }
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    /** A number with a comma and exactly `digits` decimals: "1,1", "0,18", "65,8". */
    static func kiraDecimal(_ digits: Int) -> FloatingPointFormatStyle<Double> {
        FloatingPointFormatStyle<Double>(locale: indonesian).precision(.fractionLength(digits)).grouping(.never)
    }

    /** A multiple with a comma and at most one decimal: "6", "0,5". */
    static var kiraMultiple: FloatingPointFormatStyle<Double> {
        FloatingPointFormatStyle<Double>(locale: indonesian).precision(.fractionLength(0...1)).grouping(.never)
    }
}

extension Int {
    /** Whole rupiah as the `Decimal` that `RupiahFormatStyle` and `KiraAmount` take. */
    var rupiah: Decimal { Decimal(self) }
}
