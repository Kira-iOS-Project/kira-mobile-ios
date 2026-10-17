/** Rule 24 for the Dompet overview and Tambah Dompet sheet. */
import XCTest

nonisolated final class WalletAuditTests: XCTestCase {
    @MainActor
    func testWalletsPassesTheAudit() throws {
        try auditScreen("profile") { app in
            let walletEntry = app.buttons.matching(
                NSPredicate(format: "label CONTAINS %@", "Dompet & Akun Utang")
            ).firstMatch
            XCTAssertTrue(walletEntry.waitForExistence(timeout: 5))
            walletEntry.tap()
            XCTAssertTrue(app.staticTexts["Dompet"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testWalletCreateSheetPassesTheAudit() throws {
        try auditScreen("wallets") { app in
            app.buttons["Tambah Dompet"].firstMatch.tap()
        }
    }

    @MainActor
    func testWalletSaveSuccessDialogPassesTheAudit() throws {
        try auditScreen("wallets") { app in
            app.buttons["Tambah Dompet"].firstMatch.tap()
            let name = app.textFields["Nama Dompet"]
            XCTAssertTrue(name.waitForExistence(timeout: 5))
            name.tap()
            name.typeText("Uji")
            let amount = app.textFields["Saldo Sekarang"]
            amount.tap()
            amount.typeText("25000")
            app.buttons["Simpan Dompet"].tap()
            XCTAssertTrue(app.staticTexts["Dompet Ditambahkan"].waitForExistence(timeout: 5))
        }
    }

}
