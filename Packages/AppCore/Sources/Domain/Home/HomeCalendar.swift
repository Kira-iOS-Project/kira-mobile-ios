import Foundation

/**
 Kira's calendar: Gregorian in Western Indonesia Time (WIB, UTC+7, no daylight saving), where every
 date of the API is a day. The greeting and the day ranges are read in it, whatever the device's
 time zone.
 */
package enum HomeCalendar {
    /** WIB's offset from UTC, in seconds. */
    package static let offset: TimeInterval = 7 * 3600

    /** A Gregorian calendar in UTC, read with instants moved by `offset`. */
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    /** One component of `date` as a clock in WIB shows it. */
    package static func component(_ component: Calendar.Component, of date: Date) -> Int {
        calendar.component(component, from: date.addingTimeInterval(offset))
    }
}

/** The part of the day the greeting names: Pagi, Siang, Sore or Malam. */
package enum DayPart: String, CaseIterable, Sendable {
    /** 04.00 to 10.59. */
    case morning
    /** 11.00 to 14.59. */
    case midday
    /** 15.00 to 17.59. */
    case afternoon
    /** 18.00 to 03.59. */
    case night

    /** The part of the day `date` falls in, in WIB. */
    package init(at date: Date) {
        switch HomeCalendar.component(.hour, of: date) {
        case 4..<11: self = .morning
        case 11..<15: self = .midday
        case 15..<18: self = .afternoon
        default: self = .night
        }
    }
}

/** Some consecutive days, such as the week a summary covers ("8–14 Oktober 2026"). */
package struct DayRange: Equatable, Sendable {
    /** What the two ends share, which decides how much of the first end is written. */
    package enum Shape: Equatable, Sendable {
        /** "8–14 Oktober 2026": the first end is its day only. */
        case sameMonth
        /** "28 September–4 Oktober 2026": the first end is its day and month. */
        case sameYear
        /** "29 Desember 2025–4 Januari 2026": both ends in full. */
        case acrossYears
    }

    package let from: Date
    package let to: Date

    package init(from: Date, to: Date) {
        self.from = from
        self.to = to
    }

    /** The day of the month of the first end, in WIB. */
    package var fromDay: Int { HomeCalendar.component(.day, of: from) }

    package var shape: Shape {
        guard HomeCalendar.component(.year, of: from) == HomeCalendar.component(.year, of: to) else {
            return .acrossYears
        }
        let sameMonth = HomeCalendar.component(.month, of: from) == HomeCalendar.component(.month, of: to)
        return sameMonth ? .sameMonth : .sameYear
    }
}
