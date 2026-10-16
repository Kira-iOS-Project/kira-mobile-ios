/**
 Rule 24 for Kira Peduli inside Catat: the reply to a crisis signal (PED-02, board SinyalKrisis),
 Check-in Lanjutan (PED-05, CheckIn) and the check-in greeting with the Mode Darurat Utang card
 (PED-06, CheckInChat). Each opens through `-KiraScreen <name>` and the taps the boards show; the
 other test checks the promise that a crisis message is never read as a transaction.
 */
import XCTest

nonisolated final class CrisisChatAuditTests: XCTestCase {
    /** The board's message, which the phrase list reads as danger. */
    private static let crisisMessage = "tagihan numpuk semua, capek banget. kayaknya mending gak ada aja"

    @MainActor
    func testCrisisSignalPassesTheAudit() throws {
        try auditScreen("crisisSignal") { app in Self.sendCrisisMessage(in: app) }
    }

    @MainActor
    func testCheckInPassesTheAudit() throws {
        try auditScreen("crisisSignal") { app in
            Self.sendCrisisMessage(in: app)
            Self.tap(app.buttons["Aku Aman"])
            XCTAssertTrue(app.staticTexts["Boleh Aku Menyapamu Lagi?"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testCheckInChatPassesTheAudit() throws {
        try auditScreen("checkInChat") { app in
            Self.tap(app.buttons["Sedikit Lebih Baik"])
            XCTAssertTrue(app.staticTexts["Mode Darurat Utang"].waitForExistence(timeout: 5))
        }
    }

    /** The crisis message gets Kira's fixed reply and no drafts; Aku Tidak Aman opens the help. */
    @MainActor
    func testCrisisMessageIsNeverATransaction() {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "crisisSignal"]
        app.launch()
        Self.sendCrisisMessage(in: app)
        XCTAssertTrue(app.staticTexts["Aku mau tanya langsung, ya. Apakah kamu aman sekarang?"].exists)
        XCTAssertFalse(app.staticTexts["Aku tangkap 2 pengeluaran. Cek dulu sebelum disimpan, ya."].exists)
        Self.tap(app.buttons["Aku Tidak Aman"])
        XCTAssertTrue(app.buttons["Telepon 119"].waitForExistence(timeout: 5))
        app.terminate()
    }

    @MainActor
    private static func sendCrisisMessage(in app: XCUIApplication) {
        let label = "Tulis Pengeluaran atau Pemasukan"
        let field = app.textViews[label].firstMatch
        let composer = field.waitForExistence(timeout: 10) ? field : app.textFields[label]
        tap(composer)
        composer.typeText(crisisMessage)
        tap(app.buttons["Kirim"])
        XCTAssertTrue(app.buttons["Aku Aman"].waitForExistence(timeout: 5))
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
