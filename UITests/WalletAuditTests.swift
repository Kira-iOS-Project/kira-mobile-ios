/** Rule 24 for the Dompet overview. */
import XCTest

nonisolated final class WalletAuditTests: XCTestCase {
    @MainActor
    func testWalletsPassesTheAudit() throws {
        try auditScreen("wallets")
    }

}
