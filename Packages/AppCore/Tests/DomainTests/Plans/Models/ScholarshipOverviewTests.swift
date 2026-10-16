import Foundation
import Testing

@testable import Domain

@Suite("ScholarshipOverview")
struct ScholarshipOverviewTests {
    private func overview(_ status: ScholarshipApplication.Status?) -> ScholarshipOverview {
        let application = status.map {
            ScholarshipApplication(
                status: $0, situations: [.medicalCosts],
                submittedAt: Date(timeIntervalSince1970: 0), decideBy: CalendarDay(year: 2026, month: 10, day: 21))
        }
        return ScholarshipOverview(
            quotaRemaining: 42,
            quotaTotal: 60, application: application)
    }

    @Test("explains Beasiswa Kira until an application is open, and again once withdrawn")
    func stage() throws {
        #expect(overview(nil).stage == .intro)
        #expect(overview(.withdrawn).stage == .intro)
        let pending = try #require(overview(.inReview).application)
        #expect(overview(.inReview).stage == .pending(pending))
        #expect(overview(.waitlisted).stage == .pending(try #require(overview(.waitlisted).application)))
        #expect(overview(.accepted).stage == .accepted(try #require(overview(.accepted).application)))
    }
}
