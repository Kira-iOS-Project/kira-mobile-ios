/**
 Rule 24 for Tujuan Baru · DP Rumah (REN-02b) and its Hasil Simulasi with Simulasi KPR (REN-04c),
 the failure dialog of Jadikan Pos Budget, and Tujuan Baru · Menikah (REN-02d) with a row's price
 sheet and its Hasil Simulasi (REN-04e). Each opens through `-KiraScreen <name>` and a tap.
 */
import XCTest

nonisolated final class HouseWeddingGoalAuditTests: XCTestCase {
    @MainActor
    func testHouseFormPassesTheAudit() throws {
        try auditScreen("houseGoal")
    }

    @MainActor
    func testHouseResultPassesTheAudit() throws {
        try auditScreen("houseGoalResult") { app in
            XCTAssertTrue(app.staticTexts["Cicilan Sehat"].waitForExistence(timeout: 10))
        }
    }

    /** Jadikan Pos Budget without an answer: Belum Berhasil Menyimpan, Coba Lagi and Tutup. */
    @MainActor
    func testBudgetFailurePassesTheAudit() throws {
        try auditScreen(
            "houseGoalBudgetFailing",
            prepare: { app in
                Self.tap(app.buttons["Jadikan Pos Budget"])
                XCTAssertTrue(app.staticTexts["Belum Berhasil Menyimpan"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.buttons["Coba Lagi"].exists && app.buttons["Tutup"].exists)
            },
            accepting: Self.behindCover)
    }

    @MainActor
    func testWeddingFormPassesTheAudit() throws {
        try auditScreen("weddingGoal")
    }

    /** "Ketuk baris untuk mengubah harganya": Venue / Gedung's price sheet. */
    @MainActor
    func testWeddingRowSheetPassesTheAudit() throws {
        try auditScreen(
            "weddingGoal",
            prepare: { app in
                /** The row's label is its title, then its amount: match the title. */
                Self.tap(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Venue / Gedung")).firstMatch)
                XCTAssertTrue(app.textFields["Harga"].waitForExistence(timeout: 10))
            },
            accepting: Self.behindCover)
    }

    @MainActor
    func testWeddingResultPassesTheAudit() throws {
        try auditScreen("weddingGoalResult") { app in
            XCTAssertTrue(app.staticTexts["Hampir Cocok"].waitForExistence(timeout: 10))
        }
    }

    /** Accepted, as for every sheet and dialog (docs/design-system.md): text behind its scrim. */
    private static func behindCover(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        issue.auditType == .elementDetection && issue.element == nil
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
