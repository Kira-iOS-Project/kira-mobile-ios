import APIClient
import Domain
import Testing

@testable import Features

@Suite("Bridge")
struct BridgeTests {
    @Test("a case is read by its spelling, and a spelling the Domain lacks is a problem without a code")
    func value() throws {
        let focus: Focus = try Bridge.value(FocusDTO.debtFree)
        #expect(focus == .debtFree)
        #expect(throws: AppProblem()) { let _: ScholarshipSituation = try Bridge.value(Focus.trackSpending) }
    }

    @Test("a WIB day is read from YYYY-MM-DD, and anything else is a problem without a code")
    func day() throws {
        #expect(try Bridge.day("2026-10-25") == CalendarDay(year: 2026, month: 10, day: 25))
        #expect(throws: AppProblem()) { try Bridge.day("25-10-2026") }
    }
}
