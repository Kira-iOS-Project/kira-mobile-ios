/** Accessibility audit for the recurring-bill and debt-installment list. */
import XCTest

nonisolated final class BillsAuditTests: XCTestCase {
    @MainActor
    func testBillsPassesTheAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "billList"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Tagihan & Cicilan"].waitForExistence(timeout: 10))
        try auditInPlace(app)
    }
}
