/** Rule 24 for the Dompet overview. */
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

}
