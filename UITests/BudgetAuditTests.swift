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

    @MainActor
    func testBudgetSaveSuccessPassesTheAuditAndClosesEditor() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "budget"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(app.staticTexts.firstMatch.waitForExistence(timeout: 10))
        app.buttons["Atur Budget"].tap()
        app.buttons["Simpan Budget"].tap()

        XCTAssertTrue(app.staticTexts["Budget Tersimpan"].waitForExistence(timeout: 5))
        try auditInPlace(app)
        app.buttons["Selesai"].tap()

        let editorButtonClosed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"), object: app.buttons["Simpan Budget"])
        XCTAssertEqual(XCTWaiter.wait(for: [editorButtonClosed], timeout: 5), .completed)
    }

    @MainActor
    func testBudgetPaydayPickerPassesAuditAndDistinguishesMonthEndFromDay31() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "budget"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(app.staticTexts.firstMatch.waitForExistence(timeout: 10))
        app.buttons["Atur Budget"].tap()

        let payday = app.buttons["Tanggal Gajian"]
        XCTAssertTrue(payday.waitForExistence(timeout: 5))
        payday.tap()
        let day31 = app.buttons["payday.day.31"]
        XCTAssertTrue(day31.waitForExistence(timeout: 5))
        day31.tap()
        app.buttons["Pilih Tanggal"].tap()
        XCTAssertEqual(payday.value as? String, "Setiap Tanggal 31")

        payday.tap()
        app.buttons["Gajian di akhir bulan"].tap()
        try auditInPlace(app)
        app.buttons["Pilih Tanggal"].tap()
        XCTAssertEqual(payday.value as? String, "Setiap Akhir Bulan")
    }
}
