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

    @MainActor
    func testSavedBillDialogAppearsAfterSaveAndReturnsToTheList() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "billList"]
        app.launch()
        app.buttons["Tambah Tagihan"].firstMatch.tap()

        let name = app.textFields["Nama Tagihan"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Internet rumah")
        let amount = app.textFields["Jumlah"]
        amount.tap()
        amount.typeText("350000")
        app.buttons["Simpan Tagihan"].tap()

        XCTAssertTrue(app.staticTexts["Tagihan Tersimpan"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["\"Internet rumah\" tersimpan. Tagihan ini akan muncul pada jadwal berikutnya."].exists)
        try auditInPlace(app)
        app.buttons["Selesai"].tap()
        XCTAssertTrue(app.buttons["Tambah Tagihan"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Tagihan Tersimpan"].exists)
    }

    @MainActor
    func testSavedDebtInstallmentUsesSpecificDialogCopy() {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "billCreate"]
        app.launch()

        let name = app.textFields["Nama Tagihan"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Cicilan Paylater")
        let amount = app.textFields["Jumlah"]
        amount.tap()
        amount.typeText("105000")
        app.switches["Ini Cicilan Utang"].tap()
        app.buttons["Paylater"].tap()
        app.buttons["Simpan Tagihan"].tap()

        XCTAssertTrue(app.staticTexts["Tagihan Tersimpan"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["\"Cicilan Paylater\" tersimpan sebagai cicilan dan terhubung ke akun utangmu."].exists)
    }
}
