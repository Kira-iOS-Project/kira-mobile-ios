/** Rule 24 for the Thursday-to-Wednesday weekly spending summary. */
import XCTest

nonisolated final class WeeklySummaryAuditTests: XCTestCase {
    @MainActor
    func testWeeklySummaryPassesTheAudit() throws {
        try auditScreen("weeklySummary")
    }
}
