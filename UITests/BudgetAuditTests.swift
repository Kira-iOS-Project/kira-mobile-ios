/** Rule 24 for the budget overview screen. */
import XCTest

nonisolated final class BudgetAuditTests: XCTestCase {
    @MainActor
    func testBudgetOverviewPassesTheAudit() throws {
        try auditScreen("budget")
    }

    @MainActor
    func testBudgetEditorPassesTheAudit() throws {
        try auditScreen("budget", prepare: { $0.buttons["Atur Budget"].tap() })
    }
}
