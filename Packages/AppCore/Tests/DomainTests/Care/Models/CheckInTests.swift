import Foundation
import Testing

@testable import Domain

@Suite("CheckIn")
struct CheckInTests {
    @Test("the delays are the board's 24, 48 and 72 hours")
    func hours() {
        #expect(CheckInDelay.allCases.map(\.hours) == [24, 48, 72])
    }

    @Test("a check-in keeps its id and due time")
    func fields() {
        let due = Date(timeIntervalSince1970: 1_792_000_000)
        let checkIn = CheckIn(id: "c1", dueAt: due)
        #expect(checkIn.id == "c1")
        #expect(checkIn.dueAt == due)
    }
}
