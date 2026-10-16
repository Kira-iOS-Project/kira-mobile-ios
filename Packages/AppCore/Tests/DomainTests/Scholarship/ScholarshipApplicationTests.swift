import Foundation
import Testing

@testable import Domain

@Suite("ScholarshipApplication")
struct ScholarshipApplicationTests {
    @Test("holds the decision's days once accepted")
    func decision() {
        let start = CalendarDay(year: 2026, month: 10, day: 19)
        let end = CalendarDay(year: 2027, month: 1, day: 19)
        let accepted = ScholarshipApplication(
            id: "app-1", status: .accepted, situations: [.incomeStopped], story: nil,
            submittedAt: Date(timeIntervalSince1970: 0), decideBy: CalendarDay(year: 2026, month: 10, day: 21),
            decision: .init(
                decidedAt: start, grantStart: start, grantEnd: end,
                extensionFrom: CalendarDay(year: 2027, month: 1, day: 5)))
        #expect(accepted.decidedAt == start)
        #expect(accepted.grant == start...end)
        #expect(accepted.extensionFrom == CalendarDay(year: 2027, month: 1, day: 5))

        let pending = ScholarshipApplication(
            id: "app-2", status: .inReview, situations: [.incomeStopped], story: nil,
            submittedAt: Date(timeIntervalSince1970: 0), decideBy: start)
        #expect(pending.grant == nil)
        #expect(pending.decidedAt == nil)
        #expect(pending.extensionFrom == nil)
    }
}
