/**
 Rule 24 for Budget per Kategori (UNG-04, board Budget) on the board's sample: the hero, Per Kategori
 with its tags, the footnote and Atur Budget (ScreenAudit.swift).
 */
import XCTest

nonisolated final class BudgetAuditTests: XCTestCase {
    @MainActor
    func testBudgetOverviewPassesTheAudit() throws {
        try auditScreen("budget") { app in
            XCTAssertTrue(app.staticTexts["Sisa uang · gajian 10 hari lagi"].exists)
            XCTAssertTrue(app.staticTexts["Sisa Rp60.000,00"].exists)
            XCTAssertTrue(app.staticTexts["Lunas"].exists)
            XCTAssertTrue(app.staticTexts["Pos Tujuan"].exists)
        }
    }
}
