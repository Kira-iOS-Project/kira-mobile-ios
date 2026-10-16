import Foundation

/** The WIB midnight of a day: UTC midnight less seven hours. */
func wibDay(_ year: Int, _ month: Int, _ day: Int) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    let midnight = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    return midnight.addingTimeInterval(-7 * 3600)
}
