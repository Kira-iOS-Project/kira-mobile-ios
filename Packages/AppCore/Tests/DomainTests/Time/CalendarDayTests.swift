import Foundation
import Testing

@testable import Domain

@Suite("CalendarDay")
struct CalendarDayTests {
    @Test("takes the WIB day of an instant, also before 1970")
    func fromInstant() {
        /** 16 October 2026, 23.30 WIB is 16.30 UTC. */
        #expect(CalendarDay(Date(timeIntervalSince1970: 1_792_168_200)) == CalendarDay(year: 2026, month: 10, day: 16))
        /** 17 October 2026, 00.30 WIB is still the 16th in UTC. */
        #expect(CalendarDay(Date(timeIntervalSince1970: 1_792_171_800)) == CalendarDay(year: 2026, month: 10, day: 17))
        #expect(CalendarDay(Date(timeIntervalSince1970: -86_400 * 400)) == CalendarDay(year: 1968, month: 11, day: 27))
        let ancient = CalendarDay(year: -221, month: 9, day: 13)
        #expect(CalendarDay(ancient.date) == ancient)
    }

    @Test("reads and writes YYYY-MM-DD")
    func iso() {
        #expect(CalendarDay(iso: "2026-11-15") == CalendarDay(year: 2026, month: 11, day: 15))
        #expect(CalendarDay(iso: "2028-02-29")?.iso == "2028-02-29")
        #expect(CalendarDay(year: 2026, month: 1, day: 5).iso == "2026-01-05")
        for text in ["2026-13-01", "2026-02-29", "2026-04-31", "2026-11", "kemarin", "2026-00-10"] {
            #expect(CalendarDay(iso: text) == nil, "\(text)")
        }
    }

    @Test("is noon WIB as an instant, and orders by day")
    func instant() {
        let day = CalendarDay(year: 2026, month: 10, day: 16)
        #expect(day.date == Date(timeIntervalSince1970: 1_792_126_800))
        #expect(CalendarDay(day.date) == day)
        #expect(day < CalendarDay(year: 2026, month: 10, day: 17))
        let same = CalendarDay(year: 2026, month: 10, day: 16)
        #expect(!(day < same))
    }

    @Test("adds days, months and years, keeping the day within the month")
    func adding() {
        let day = CalendarDay(year: 2026, month: 10, day: 16)
        #expect(day.adding(months: 1) == CalendarDay(year: 2026, month: 11, day: 16))
        #expect(day.adding(months: 3) == CalendarDay(year: 2027, month: 1, day: 16))
        #expect(day.adding(years: 1) == CalendarDay(year: 2027, month: 10, day: 16))
        #expect(day.adding(days: -14) == CalendarDay(year: 2026, month: 10, day: 2))
        #expect(
            CalendarDay(year: 2026, month: 1, day: 31).adding(months: 1) == CalendarDay(year: 2026, month: 2, day: 28))
        #expect(
            CalendarDay(year: 2028, month: 1, day: 31).adding(months: 1) == CalendarDay(year: 2028, month: 2, day: 29))
        #expect(
            CalendarDay(year: 2026, month: 3, day: 31).adding(months: -1) == CalendarDay(year: 2026, month: 2, day: 28))
        #expect(CalendarDay(year: 2100, month: 2, day: 1).adding(days: 28) == CalendarDay(year: 2100, month: 3, day: 1))
        #expect(
            CalendarDay(year: 2000, month: 2, day: 1).adding(days: 28) == CalendarDay(year: 2000, month: 2, day: 29))
    }

    @Test("knows each month's length")
    func lengths() {
        #expect(CalendarDay.length(ofMonth: 4, in: 2026) == 30)
        #expect(CalendarDay.length(ofMonth: 12, in: 2026) == 31)
        #expect(CalendarDay.length(ofMonth: 2, in: 2024) == 29)
    }
}
