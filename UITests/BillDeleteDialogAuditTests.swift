/** Accessibility audit for deleting a bill schedule from its edit screen. */
import XCTest

nonisolated final class BillDeleteDialogAuditTests: XCTestCase {
    @MainActor
    func testBillDeleteConfirmationPassesTheAuditAndCanBeCancelled() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "billEdit"]
        app.launch()
        let open = app.buttons["Hapus Tagihan"].firstMatch
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        open.tap()
        let title = app.staticTexts["Hapus Tagihan Ini?"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        try auditInPlace(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        app.buttons["Batal"].tap()
        XCTAssertFalse(title.waitForExistence(timeout: 1))
        XCTAssertTrue(open.exists)
        app.terminate()
    }
}
