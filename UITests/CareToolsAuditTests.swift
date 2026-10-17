/**
 Rule 24 for Naskah Pengajuan Keringanan (PED-09): the screen, the lender list over its fields
 (09b), the contract number's sheet, and Naskah Disalin (09c) after Salin Naskah. Each opens through
 `-KiraScreen negotiationScript` and a tap (ScreenAudit.swift).
 */
import XCTest

nonisolated final class CareToolsAuditTests: XCTestCase {
    @MainActor
    func testNegotiationScriptPassesTheAudit() throws {
        try auditScreen("negotiationScript", accepting: Self.isBoardSecondaryText)
    }

    /** NaskahNegosiasiDropdown: Pemberi Pinjaman opens the list of the person's lenders. */
    @MainActor
    func testLenderListPassesTheAudit() throws {
        try auditScreen(
            "negotiationScript",
            prepare: { app in
                Self.tap(app.buttons["Pemberi Pinjaman"])
                XCTAssertTrue(app.buttons["Paylater B"].waitForExistence(timeout: 5))
            },
            accepting: Self.isBoardSecondaryText)
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

    /**
     Accepted, owner's decision (design precise to the board): contrast on the script card's "untuk
     <lender>" (care.script.for) and a lender row's "Cicilan Rp… per bulan" (care.script.lenderInfo),
     and nothing else. Both are drawn as NaskahNegosiasi and NaskahNegosiasiDropdown draw them (12 px,
     weight 500, and 13 px, both var(--ink-muted)), and their tokens pass AA: ink-muted on the card
     5.9 : 1, on pandan-soft 5.2 : 1, in light and dark. Apple's audit samples the pixels of these
     thin 12-13 pt strokes and reads them below 4.5 at some positions only (the same label passes at
     one scroll offset and fails at the next).
     */
    @MainActor
    private static func isBoardSecondaryText(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
        return label.hasPrefix("untuk ") || (label.hasPrefix("Cicilan Rp") && label.hasSuffix(" per bulan"))
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
