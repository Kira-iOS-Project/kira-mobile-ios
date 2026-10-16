/**
 Rule 24 for Naskah Pengajuan Keringanan (PED-09): the screen, the lender list over its fields
 (09b), the contract number's sheet, and Naskah Disalin (09c) after Salin Naskah. Each opens through
 `-KiraScreen negotiationScript` and a tap (ScreenAudit.swift).
 */
import XCTest

nonisolated final class CareToolsAuditTests: XCTestCase {
    @MainActor
    func testNegotiationScriptPassesTheAudit() throws {
        try auditScreen("negotiationScript")
    }

    /** NaskahNegosiasiDropdown: Pemberi Pinjaman opens the list of the person's lenders. */
    @MainActor
    func testLenderListPassesTheAudit() throws {
        try auditScreen("negotiationScript") { app in
            Self.tap(app.buttons["Pemberi Pinjaman"])
            XCTAssertTrue(app.buttons["Paylater B"].waitForExistence(timeout: 5))
        }
    }

    /** The contract number's sheet, opened from the script's coloured phrase. */
    @MainActor
    func testContractSheetPassesTheAudit() throws {
        try auditScreen(
            "negotiationScript",
            prepare: { app in
                Self.tap(app.links["nomor kontrak"])
                XCTAssertTrue(app.staticTexts["Nomor Kontrak"].waitForExistence(timeout: 5))
            },
            accepting: { issue in
                /** Accepted, as for the drafts sheet (ChatAuditTests): text behind the sheet's scrim. */
                issue.auditType == .elementDetection && issue.element == nil
            })
    }

    /** NaskahNegosiasiDialogBerhasil: Salin Naskah once Kemampuan Bayar is filled. */
    @MainActor
    func testCopiedDialogPassesTheAudit() throws {
        try auditScreen(
            "negotiationScript",
            prepare: { app in
                let affordable = app.textFields["Kemampuan Bayar per Bulan"]
                Self.tap(affordable)
                affordable.typeText("150000")
                Self.tap(app.buttons["Salin Naskah"])
                XCTAssertTrue(app.staticTexts["Naskah Disalin"].waitForExistence(timeout: 5))
            },
            accepting: { issue in
                /** Accepted, as for every presented dialog (docs/design-system.md): text behind its scrim. */
                issue.auditType == .elementDetection && issue.element == nil
            })
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
