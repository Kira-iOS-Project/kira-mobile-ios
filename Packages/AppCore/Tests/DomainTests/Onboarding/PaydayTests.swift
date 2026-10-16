/** Payday is a day of the month or the end of every month (ONB-10b, ONB-10c). */
import Testing

@testable import Domain

@Suite("Payday")
struct PaydayTests {
    @Test("a day is clamped to 1–31", arguments: [(25, 25), (0, 1), (-3, 1), (31, 31), (40, 31)])
    func day(_ input: Int, _ expected: Int) {
        let payday = Payday(day: input)
        #expect(payday.day == expected)
        #expect(!payday.isEndOfMonth)
    }

    @Test("the end of the month has no day, and the calendar offers 1–31 from the 25th")
    func endOfMonth() {
        #expect(Payday.endOfMonth.day == nil)
        #expect(Payday.endOfMonth.isEndOfMonth)
        #expect(Payday.days == Array(1...31))
        #expect(Payday.defaultDay == 25)
    }

    @Test("reads the API's day and end-of-month flag; neither set is no payday")
    func fromAPI() {
        #expect(Payday(day: 25, endOfMonth: false) == Payday(day: 25))
        #expect(Payday(day: nil, endOfMonth: true) == .endOfMonth)
        #expect(Payday(day: 25, endOfMonth: true) == .endOfMonth)
        #expect(Payday(day: nil, endOfMonth: false) == nil)
    }
}
