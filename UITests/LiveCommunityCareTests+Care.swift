/**
 Kira Peduli in the live walk (LiveCommunityCareTests.swift): the contacts, a crisis phrase in
 Catat (the help sheet, a check-in, then Tidak Perlu), Mode Darurat Utang and Beasiswa, Naskah Keringanan on the
 health check's debt, Rencana Keselamatanku saved and loaded again, Latihan Menenangkan Diri, and
 Komunitas and Kira Peduli with the server down (`KIRA_LIVE_SERVER_DOWN`, set by the driver).
 */
import XCTest

extension LiveCommunityCareTests {
    @MainActor
    func test13CareContacts() throws {
        let app = try openCare()
        LiveFlow.expect(rowStarting("Telepon Healing119", app), in: self, timeout: 20, app: app)
        XCTAssertFalse(app.buttons["Hubungi Layanan Kira. Pesan pembuka sudah disiapkan"].exists)
        LiveFlow.shot("ped-01-care", in: self)
    }

    @MainActor
    func test14CrisisPhraseOpensTheHelpSheet() throws {
        let app = try sendCrisisMessage()
        LiveFlow.shot("ped-02-crisis-reply", in: self)
        tap(app.buttons["Aku Tidak Aman"], app)
        LiveFlow.expect(app.staticTexts["Bicara dengan Orang Sekarang"], in: self, app: app)
        LiveFlow.shot("ped-03-help-sheet", in: self)
        tap(app.buttons["Kembali ke Chat"], app)
    }

    @MainActor
    func test15CrisisPhraseThenACheckIn() throws {
        let app = try sendCrisisMessage()
        tap(app.buttons["Aku Aman"].firstMatch, app)
        LiveFlow.expect(app.staticTexts["Boleh Aku Menyapamu Lagi?"], in: self, app: app)
        LiveFlow.shot("ped-04-check-in", in: self)
        tap(app.buttons["Ya, Sapa Aku"], app)
        LiveFlow.shot("ped-05-check-in-scheduled", in: self)
        /** A second crisis reply reopens the check-in with its delay chosen; Tidak Perlu cancels it. */
        sendCrisisPhrase(in: app)
        tap(app.buttons["Aku Aman"].firstMatch, app)
        tap(app.buttons["Tidak Perlu"], app, timeout: 15)
        LiveFlow.shot("ped-05b-check-in-cancelled", in: self)
    }

    @MainActor
    func test16DebtEmergencyThenScholarship() throws {
        let app = try openCare()
        tap(rowStarting("Mode Darurat Utang", app), app, timeout: 20)
        LiveFlow.expect(app.staticTexts["Apa yang Sedang Terjadi?"], in: self, app: app)
        LiveFlow.shot("ped-06-debt-emergency", in: self)
        let scholarship = rowStarting("Beasiswa Kira", app)
        for _ in 0..<5 where !scholarship.isHittable { app.swipeUp() }
        tap(scholarship, app)
        LiveFlow.shot("ped-07-scholarship", in: self)
    }

    @MainActor
    func test17NegotiationScriptOnTheHealthCheckDebt() throws {
        let app = try openCare()
        tap(rowStarting("Mode Darurat Utang", app), app, timeout: 20)
        tap(rowStarting("Cicilan Tidak Sanggup Dibayar", app), app)
        tap(app.buttons["Pemberi Pinjaman"], app, timeout: 20)
        tap(rowStarting("Paylater B", app), app)
        LiveFlow.type("150000", into: app.textFields["Kemampuan Bayar per Bulan"], in: self, app: app)
        LiveFlow.shot("ped-08-script", in: self)
        let copy = app.buttons["Salin Naskah"]
        if !copy.isHittable { app.swipeUp() }
        tap(copy, app)
        LiveFlow.expect(app.staticTexts["Naskah Disalin"], in: self, app: app)
        LiveFlow.shot("ped-09-script-copied", in: self)
    }

    @MainActor
    func test18SafetyPlanSavedThenLoaded() throws {
        var app = try openCare()
        tap(rowStarting("Rencana Keselamatanku", app), app, timeout: 20)
        tap(app.buttons["Ubah Tanda Aku Mulai Berat"], app, timeout: 20)
        let field = app.textViews.firstMatch.exists ? app.textViews.firstMatch : app.textFields.firstMatch
        LiveFlow.type("Susah tidur dan menghindari teman", into: field, in: self, app: app)
        /** The form's Simpan Rencana, then the plan's own when the form only fills it in. */
        tap(app.buttons["Simpan Rencana"].firstMatch, app)
        if !app.staticTexts["Rencana Tersimpan"].waitForExistence(timeout: 5) {
            tap(app.buttons["Simpan Rencana"].firstMatch, app, timeout: 20)
        }
        LiveFlow.expect(app.staticTexts["Rencana Tersimpan"], in: self, timeout: 20, app: app)
        LiveFlow.shot("ped-10-plan-saved", in: self)
        app.terminate()
        app = try openCare()
        tap(rowStarting("Rencana Keselamatanku", app), app, timeout: 20)
        let saved = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Susah tidur'")).firstMatch
        LiveFlow.expect(saved, in: self, timeout: 20, app: app)
        LiveFlow.shot("ped-11-plan-loaded", in: self)
    }

    @MainActor
    func test19Breathing() throws {
        let app = try openCare()
        tap(rowStarting("Latihan Menenangkan Diri", app), app, timeout: 20)
        LiveFlow.expect(app.buttons["Tutup latihan"], in: self, app: app)
        LiveFlow.shot("ped-12-breathing", in: self)
        tap(app.buttons["Tutup latihan"], app)
    }

    @MainActor
    func test20CommunityAndCareWhileTheServerIsDown() throws {
        let app = LiveFlow.launch(try LiveFlow.requireServer())
        try XCTSkipUnless(ProcessInfo.processInfo.environment["KIRA_LIVE_SERVER_DOWN"] != nil, "the server is up")
        LiveFlow.unlock(app)
        tap(app.buttons["Komunitas"], app, timeout: 20)
        LiveFlow.expect(app.buttons["Coba Lagi"], in: self, timeout: 30, app: app)
        LiveFlow.shot("neg-v7-01-community-offline", in: self)
        tap(app.buttons["Butuh Bantuan Sekarang"].firstMatch, app)
        LiveFlow.expect(rowStarting("Telepon Healing119", app), in: self, timeout: 30, app: app)
        LiveFlow.shot("neg-v7-02-care-offline", in: self)
    }
}
