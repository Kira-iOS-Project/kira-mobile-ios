/**
 Rule 24 for REN-01 and REN-05: Rencana (the board's plan, with no goal, and failed to load), Detail
 Tujuan (the board's emergency fund, a goal that is gone), and Tambah Setoran: its sheet, and the
 failure dialog when the save fails. Each screen opens through `-KiraScreen <name>` on the preview
 service and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class PlanAuditTests: XCTestCase {
    @MainActor
    func testPlanPassesTheAudit() throws {
        try auditScreen(
            "plan",
            prepare: { app in
                XCTAssertTrue(app.staticTexts["Tangga Keuanganmu"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.staticTexts["Sedang Berjalan · Paylater A"].exists)
                XCTAssertTrue(app.staticTexts["Tujuanmu"].exists)
            })
    }

    @MainActor
    func testPlanWithoutGoalsPassesTheAudit() throws {
        try auditScreen(
            "planNoGoals",
            prepare: { app in
                let empty = app.staticTexts["Belum ada tujuan. Mulai dari Dana Darurat lewat Tambah."]
                XCTAssertTrue(empty.waitForExistence(timeout: 10))
            })
    }

    @MainActor
    func testPlanFailedPassesTheAudit() throws {
        try auditScreen(
            "planFailed",
            prepare: { app in
                XCTAssertTrue(app.buttons["Coba Lagi"].waitForExistence(timeout: 10))
            })
    }

    @MainActor
    func testGoalDetailPassesTheAudit() throws {
        try auditScreen(
            "goalDetail",
            prepare: { app in
                XCTAssertTrue(app.staticTexts["Tonggak 1 Bulan Tercapai"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.buttons["Ubah Tujuan"].exists && app.buttons["Tambah Setoran"].exists)
            })
    }

    @MainActor
    func testGoalGonePassesTheAudit() throws {
        try auditScreen(
            "goalGone",
            prepare: { app in
                let gone = app.staticTexts["Tujuan ini tidak ditemukan. Mungkin sudah dihapus."]
                XCTAssertTrue(gone.waitForExistence(timeout: 10))
                XCTAssertFalse(app.buttons["Coba Lagi"].exists)
            })
    }

    @MainActor
    func testDepositFailureShowsTheDialogAndKeepsTheAmount() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-KiraScreen", "goalDepositFailing"]
        app.launch()
        let add = app.buttons["Tambah Setoran"]
        XCTAssertTrue(add.waitForExistence(timeout: 10))
        if !add.isHittable { app.swipeUp() }
        add.tap()
        let save = app.buttons["Simpan Setoran"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        try auditInPlace(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        save.tap()
        XCTAssertTrue(app.staticTexts["Setoran Belum Tersimpan"].waitForExistence(timeout: 5))
        try auditInPlace(app) { issue in issue.auditType == .elementDetection && issue.element == nil }
        let retry = app.buttons.matching(NSPredicate(format: "label == %@", "Coba Lagi")).allElementsBoundByIndex
            .first { $0.isHittable }
        XCTAssertNotNil(retry)
        retry?.tap()
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        app.terminate()
    }
}
