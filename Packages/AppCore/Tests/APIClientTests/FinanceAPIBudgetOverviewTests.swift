import Domain
import Testing

@testable import APIClient

@Suite("FinanceAPI budget overview")
struct FinanceAPIBudgetOverviewTests {
    @Test("current-budget reads preserve authentication and undocumented failures")
    func reads() async {
        await expectProblems([401]) { _ = try await $0.getCurrentBudget() }
    }

    @Test("invalid server periods cannot become a budget overview")
    func rejectsInvalidPeriod() async {
        let json =
            #"{"configured":true,"income":1000,"remaining":1000,"allocations":[],"totalAllocated":0,"ove"#
                + #"rAllocated":false,"goalPosts":[],"payday":{"requested":{"type":"endOfMonth"},"adjustedDate"#
                + #"":"2026-10-31","periodStart":"not-a-date","periodEnd":"2026-10-30","nextPayday":"2026-10-3"#
                + #"1","daysUntilPayday":8}}"#
        let (api, _) = KiraAPI.canned(json: json)
        await #expect(throws: AppProblem()) { _ = try await api.getCurrentBudget() }
    }
}
