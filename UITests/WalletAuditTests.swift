/** Rule 24 for the Dompet overview. */
import XCTest

nonisolated final class WalletAuditTests: XCTestCase {
    @MainActor
    func testWalletsPassesTheAudit() throws {
        try auditScreen("profile") { app in
            app.buttons["Dompet & Akun Utang"].tap()
        }
    }

}
