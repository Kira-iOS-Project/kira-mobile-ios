/**
 Rule 24 for Kenali Profil Risikomu (REN-06 to REN-06e), Hasil Kuis (REN-07) and Cek Legalitas
 (REN-09), each opened through `-KiraScreen` (App/Launch/PlanRiskLaunch.swift), and the quiz's
 behaviour: a choice turns Lanjut on, Kembali keeps the answer, Lihat Hasil shows the profile, a
 failed save shows its dialog and Coba Lagi sends the answers again.
 */
import XCTest

nonisolated final class PlanRiskAuditTests: XCTestCase {
    @MainActor
    func testQuestionsPassTheAudit() throws {
        for screen in ["riskQuiz", "riskQuizUnreadablePlan", "riskDrawdown", "riskHorizon", "riskExperience", "riskDeposit"] {
            try auditScreen(screen)
        }
    }

    @MainActor
    func testResultsPassTheAudit() throws {
        for screen in ["riskResult", "riskResultConservative", "riskResultAggressive"] {
            try auditScreen(screen)
        }
    }

    @MainActor
    func testLegalityCheckPassesTheAudit() throws {
        try auditScreen("legalityCheck")
    }

    /** Kontak OJK 157's sheet: the call and the WhatsApp chat. */
    @MainActor
    func testContactSheetPassesTheAudit() throws {
        try auditScreen(
            "legalityCheck",
            prepare: { app in
                Self.scrollTo(app.buttons["Kontak OJK 157"], in: app)
                Self.tap(app.buttons["Kontak OJK 157"])
                XCTAssertTrue(app.buttons["WhatsApp 081157157157"].waitForExistence(timeout: 5))
            },
            accepting: { issue in
                /** Accepted, as for every Kira sheet (ChatAuditTests): text behind the sheet's scrim. */
                issue.auditType == .elementDetection && issue.element == nil
            })
    }

    /** The failure dialog after Lihat Hasil's save failed. */
    @MainActor
    func testSaveFailureDialogPassesTheAudit() throws {
        try auditScreen(
            "riskSaveFailing",
            prepare: { app in
                Self.tap(app.buttons["Lihat Hasil"])
                XCTAssertTrue(app.staticTexts["Belum Berhasil Menyimpan"].waitForExistence(timeout: 5))
            },
            accepting: { issue in
                /** Accepted, as for every presented dialog (docs/design-system.md): text behind its scrim. */
                issue.auditType == .elementDetection && issue.element == nil
            })
    }

    /** Lanjut waits for a choice; Kembali keeps it; the persona's five answers show Moderat. */
    @MainActor
    func testChoosingKeepsAnswersAndShowsTheResult() {
        let app = Self.launch("riskQuiz")
        let next = app.buttons["Lanjut"]
        XCTAssertTrue(next.waitForExistence(timeout: 10))
        XCTAssertFalse(next.isEnabled)
        Self.tap(app.buttons["Menambah Dana Pelan-pelan"])
        XCTAssertTrue(next.isEnabled)
        Self.tap(next)
        XCTAssertTrue(app.staticTexts["Pertanyaan 2 dari 5"].waitForExistence(timeout: 5))
        Self.tap(app.buttons["Kembali"])
        XCTAssertTrue(app.buttons["Menambah Dana Pelan-pelan"].isSelected)
        Self.tap(next)
        for option in ["Diam dan Tunggu Pulih", "1 sampai 3 Tahun", "Belum Pernah Sama Sekali"] {
            Self.tap(app.buttons[option])
            Self.tap(app.buttons["Lanjut"])
        }
        Self.tap(app.buttons["Rp375.000,00 sampai Rp750.000,00"])
        Self.tap(app.buttons["Lihat Hasil"])
        XCTAssertTrue(app.staticTexts["Moderat"].firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Hasil Kuis"].exists)
    }

    /** A failed save keeps the answers; Coba Lagi sends them again and Hasil Kuis shows. */
    @MainActor
    func testFailedSaveRetries() {
        let app = Self.launch("riskSaveFailing")
        Self.tap(app.buttons["Lihat Hasil"])
        XCTAssertTrue(app.staticTexts["Belum Berhasil Menyimpan"].waitForExistence(timeout: 5))
        Self.tap(app.buttons["Coba Lagi"])
        XCTAssertTrue(app.staticTexts["Hasil Kuis"].waitForExistence(timeout: 10))
    }

    @MainActor
    private static func launch(_ screen: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", screen]
        app.launch()
        return app
    }

    @MainActor
    private static func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        var swipes = 0
        while !element.isHittable, swipes < 5 {
            app.swipeUp()
            swipes += 1
        }
    }

    @MainActor
    private static func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        element.tap()
    }
}
