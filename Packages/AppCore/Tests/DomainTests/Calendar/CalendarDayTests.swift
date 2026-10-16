import Foundation
import Testing

@testable import Domain

@Suite("CalendarDay")
struct CalendarDayTests {
    @Test("reads and writes YYYY-MM-DD", arguments: ["2026-10-15", "2024-02-29", "1969-12-31", "0001-01-01"])
    func roundTrip(text: String) throws {
        let day = try #require(CalendarDay(iso: text))
        #expect(day.iso == text)
    }

    @Test(
        "refuses other shapes and dates the calendar does not have",
        arguments: [
            "2026-1-15", "26-10-15", "2026/10/15", "2026-13-01", "2026-00-10", "2025-02-29", "2026-04-31",
            "2026-10-1x", "2026-10-15-01", "２０２６-10-15", "",
        ])
    func refuses(text: String) {
        #expect(CalendarDay(iso: text) == nil)
    }

    @Test("knows leap years by the Gregorian rules")
    func leapYears() {
        #expect(CalendarDay(iso: "2000-02-29") != nil)
        #expect(CalendarDay(iso: "1900-02-29") == nil)
        #expect(CalendarDay(iso: "2026-06-31") == nil)
        #expect(CalendarDay(iso: "2026-07-31") != nil)
    }

    @Test("a day starts at midnight WIB, 17.00 UTC the day before")
    func start() {
        let day = CalendarDay(year: 2026, month: 10, day: 15)
        #expect(day.start == Date(timeIntervalSince1970: 1_791_997_200))
        #expect(CalendarDay(day.start) == day)
        #expect(CalendarDay(day.start.addingTimeInterval(-1)) == CalendarDay(year: 2026, month: 10, day: 14))
        #expect(CalendarDay(day.start.addingTimeInterval(86_399)) == day)
    }

    @Test("reads days before 1970 and before year zero")
    func farDays() {
        let early = CalendarDay(year: 1969, month: 12, day: 31)
        #expect(CalendarDay(early.start) == early)
        let ancient = CalendarDay(year: -1, month: 3, day: 1)
        #expect(ancient.adding(days: 0) == ancient)
        #expect(ancient.adding(days: -1) == CalendarDay(year: -1, month: 2, day: 28))
    }

    @Test("adds days across months and years, and counts days between")
    func arithmetic() {
        let day = CalendarDay(year: 2026, month: 12, day: 31)
        #expect(day.adding(days: 1) == CalendarDay(year: 2027, month: 1, day: 1))
        #expect(day.adding(days: -365) == CalendarDay(year: 2025, month: 12, day: 31))
        #expect(CalendarDay(year: 2026, month: 9, day: 25).days(to: CalendarDay(year: 2026, month: 10, day: 24)) == 29)
        #expect(day < day.adding(days: 1))
    }

    @Test("codes as a YYYY-MM-DD string")
    func coding() throws {
        let day = CalendarDay(year: 2026, month: 9, day: 5)
        let data = try JSONEncoder().encode([day])
        #expect(String(decoding: data, as: UTF8.self) == "[\"2026-09-05\"]")
        #expect(try JSONDecoder().decode([CalendarDay].self, from: data) == [day])
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode([CalendarDay].self, from: Data("[\"5 Sep\"]".utf8))
        }
    }
}
