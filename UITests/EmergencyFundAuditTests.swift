/**
 Rule 24 for Hasil Simulasi · Dana Darurat (REN-04, and REN-04b with Gimana Ngitungnya? open): the
 Kalkulator Dana Darurat opens through `-KiraScreen goalEmergency` on its board's figures, Hitung
 opens the result, and each state is audited top to bottom.
 */
import XCTest

nonisolated final class EmergencyFundAuditTests: XCTestCase {
    @MainActor
    func testEmergencyFundResultPassesTheAudit() throws {
        try auditScreen("goalEmergency") { app in calculate(in: app) }
    }

    @MainActor
    func testEmergencyFundResultWorkingOpenPassesTheAudit() throws {
        try auditScreen("goalEmergency") { app in
            calculate(in: app)
            /** The accordion's button reads its title and subtitle together. */
            let working = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Gimana Ngitungnya?'")).firstMatch
            XCTAssertTrue(working.waitForExistence(timeout: 5), "no Gimana Ngitungnya?")
            working.tap()
        }
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
