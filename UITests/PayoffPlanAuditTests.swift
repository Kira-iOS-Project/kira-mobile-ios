/**
 Rule 24 for Rencanaku (SKR-04) and Perayaan Lunas (SKR-05): the plan, the plan before one is made,
 the failure dialog after a payment that fails, and the celebration Tandai Sudah Bayar opens, with an
 account to go on to and after the last one. Each opens through `-KiraScreen <name>` and, where it
 says so, a tap (ScreenAudit.swift).
 */
import XCTest

nonisolated final class PayoffPlanAuditTests: XCTestCase {
    @MainActor
    func testPlanPassesTheAudit() throws {
        try auditScreen("myPlan")
    }

    @MainActor
    func testEmptyPlanPassesTheAudit() throws {
        try auditScreen("myPlanEmpty")
    }

    /** PerayaanLunas: Tandai Sudah Bayar settles Paylater A and opens the celebration over the plan. */
    @MainActor
    func testCelebrationFromThePlanPassesTheAudit() throws {
        try auditScreen("myPlan") { app in
            Self.tap(app.buttons["Tandai Sudah Bayar"])
            XCTAssertTrue(app.staticTexts["Paylater A Lunas!"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.buttons["Lanjut ke Paylater B"].exists)
        }
    }

    /** The failure dialog of a payment that does not go through: Coba Lagi and Tutup. */
    @MainActor
    func testPaymentFailurePassesTheAudit() throws {
        try auditScreen(
            "myPlanFailing",
            prepare: { app in
                Self.tap(app.buttons["Tandai Sudah Bayar"])
                XCTAssertTrue(app.staticTexts["Pembayaran Belum Tercatat"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.buttons["Coba Lagi"].exists && app.buttons["Tutup"].exists)
            },
            accepting: { issue in
                /** Accepted, as for every presented dialog (docs/design-system.md): text behind its scrim. */
                issue.auditType == .elementDetection && issue.element == nil
            })
    }

    @MainActor
    func testCelebrationPassesTheAudit() throws {
        try auditScreen("payoffCelebration")
    }

    /** After the last account the primary button is Lihat Kira Score. */
    @MainActor
    func testLastCelebrationPassesTheAudit() throws {
        try auditScreen("payoffCelebrationLast") { app in
            XCTAssertTrue(app.buttons["Lihat Kira Score"].waitForExistence(timeout: 10))
        }
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
