/**
 Dates and decimal numbers the way Kira writes them, whatever the device's region: Indonesian
 words in WIB ("Kamis, 15 Oktober 2026") and a decimal comma ("1,1×"). Like `RupiahFormatStyle`,
 the format is a product rule, not a regional preference (docs/design-system.md).
 */
import Domain
import Foundation

private let indonesian = Locale(identifier: "id_ID")
private let wib = Date.FormatStyle(
    locale: indonesian, calendar: Calendar(identifier: .gregorian),
    timeZone: TimeZone(secondsFromGMT: Int(HomeCalendar.offset)) ?? .gmt)

extension FormatStyle where Self == Date.FormatStyle {
    /** "Kamis, 15 Oktober 2026". */
    static var kiraWeekdayDate: Date.FormatStyle { wib.weekday(.wide).day().month(.wide).year() }

    /** "15 Oktober 2026". */
    static var kiraDate: Date.FormatStyle { wib.day().month(.wide).year() }

    /** "28 September", the first end of a range within one year. */
    static var kiraDayMonth: Date.FormatStyle { wib.day().month(.wide) }
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
