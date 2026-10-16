import Foundation
import Testing

@testable import Domain

@Suite("HomeCalendar")
struct HomeCalendarTests {
    /** 15 October 2026 at `hour`:`minute` WIB. */
    private func wib(_ hour: Int, _ minute: Int = 0) -> Date {
        wibDay(2026, 10, 15).addingTimeInterval(TimeInterval(hour * 3600 + minute * 60))
    }

    @Test("reads days in WIB, UTC+7")
    func day() {
        #expect(HomeCalendar.offset == 25_200)
        #expect(wibDay(2026, 10, 15) == Date(timeIntervalSince1970: 1_791_997_200))
        #expect(HomeCalendar.component(.day, of: Date(timeIntervalSince1970: 1_791_997_200)) == 15)
    }

    struct PartCase: Sendable {
        let hour: Int
        let minute: Int
        let part: DayPart
    }

    @Test(
        "greets Pagi from 04.00, Siang from 11.00, Sore from 15.00 and Malam from 18.00",
        arguments: [
            PartCase(hour: 3, minute: 59, part: .night),
            PartCase(hour: 4, minute: 0, part: .morning),
            PartCase(hour: 10, minute: 59, part: .morning),
            PartCase(hour: 11, minute: 0, part: .midday),
            PartCase(hour: 14, minute: 59, part: .midday),
            PartCase(hour: 15, minute: 0, part: .afternoon),
            PartCase(hour: 17, minute: 59, part: .afternoon),
            PartCase(hour: 18, minute: 0, part: .night),
            PartCase(hour: 23, minute: 59, part: .night),
        ])
    func dayPart(_ row: PartCase) {
        #expect(DayPart(at: wib(row.hour, row.minute)) == row.part)
    }

    @Test("writes the first end of a range by what the two ends share")
    func range() {
        let week = DayRange(first: wibDay(2026, 10, 8), last: wibDay(2026, 10, 14))
        #expect(week.shape == .sameMonth)
        #expect(week.firstDay == 8)
        #expect(DayRange(first: wibDay(2026, 9, 28), last: wibDay(2026, 10, 4)).shape == .sameYear)
        #expect(DayRange(first: wibDay(2025, 12, 29), last: wibDay(2026, 1, 4)).shape == .acrossYears)
    }
}
