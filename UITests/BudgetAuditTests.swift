/** Rule 24 for the budget overview screen. */
import XCTest

nonisolated final class BudgetAuditTests: XCTestCase {
    @MainActor
    func testBudgetOverviewPassesTheAudit() throws {
        try auditScreen("budget")
    }
}
