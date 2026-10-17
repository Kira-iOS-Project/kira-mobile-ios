/** Accessibility audit for recurring-bill creation and its navigation from the bills list. */
import XCTest

nonisolated final class BillCreateAuditTests: XCTestCase {
    @MainActor
    func testBillCreatePassesTheAudit() throws {
        try auditScreen("billCreate")
    }

    @MainActor
    func testBillsListOpensTheCreateForm() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "billList"]
        app.launch()
        let add = app.buttons["Tambah Tagihan"]
        XCTAssertTrue(add.waitForExistence(timeout: 10))
        add.tap()
        XCTAssertTrue(
            app.staticTexts["Catat tagihan rutin agar jadwal berikutnya mudah dipantau."].waitForExistence(timeout: 5))
        try auditInPlace(app)
    }
}
