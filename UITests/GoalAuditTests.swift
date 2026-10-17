/**
 Rule 24 for Rencana's goals (REN-02f/g/h and REN-04g/h/i): each form opens through `-KiraScreen`
 on its board's figures and is audited; Hitung then opens its Hasil Simulasi, audited top to bottom.
 */
import XCTest

nonisolated final class GoalAuditTests: XCTestCase {
    @MainActor
    func testVehicleFormPassesTheAudit() throws {
        try auditScreen("goalVehicle")
    }

    @MainActor
    func testVehicleResultPassesTheAudit() throws {
        try auditScreen("goalVehicle") { app in calculate(in: app) }
    }

    @MainActor
    func testGoodsFormPassesTheAudit() throws {
        try auditScreen("goalGoods")
    }

    @MainActor
    func testGoodsResultPassesTheAudit() throws {
        try auditScreen("goalGoods") { app in calculate(in: app) }
    }

    @MainActor
    func testOtherFormPassesTheAudit() throws {
        try auditScreen("goalOther")
    }

    @MainActor
    func testOtherResultPassesTheAudit() throws {
        try auditScreen("goalOther") { app in calculate(in: app) }
    }

    /** Taps Hitung and waits for Hasil Simulasi. */
    @MainActor
    private func calculate(in app: XCUIApplication) {
        let button = app.buttons["Hitung"].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), "no Hitung")
        button.tap()
        XCTAssertTrue(app.buttons["Jadikan Pos Budget"].waitForExistence(timeout: 5), "no Hasil Simulasi")
    }
}
