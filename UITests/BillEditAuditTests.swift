/** Accessibility audit for the recurring-bill edit screen. */
import XCTest

nonisolated final class BillEditAuditTests: XCTestCase {
    @MainActor
    func testBillEditPassesTheAudit() throws {
        try auditScreen("billEdit") { app in
            XCTAssertTrue(app.staticTexts["Ubah Tagihan"].waitForExistence(timeout: 10))
        }
    }
}
