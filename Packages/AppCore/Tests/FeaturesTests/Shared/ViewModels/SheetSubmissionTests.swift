import APIClient
import Foundation
import Testing

@testable import Features

@Suite("SheetSubmission")
struct SheetSubmissionTests {
    @Test("a failed submit closes the sheet and keeps its problem for the dialog")
    func fail() {
        var sheet = SheetSubmission(isOpen: true)
        let problem = AppProblem(code: "VALIDATION_FAILED", requestId: "req-1")
        sheet.fail(problem)
        #expect(!sheet.isOpen && sheet.failure == problem)
        sheet.fail(URLError(.notConnectedToInternet))
        #expect(sheet.failure == .connectionLost)
    }

    @Test("Coba Lagi opens the sheet again and ends the failure; Tutup only ends it")
    func reopen() {
        var sheet = SheetSubmission()
        #expect(!sheet.isOpen)
        sheet.fail(AppProblem())
        sheet.open()
        #expect(sheet.isOpen && sheet.failure == nil)
        sheet.fail(AppProblem())
        sheet.dismissFailure()
        #expect(!sheet.isOpen && sheet.failure == nil)
        sheet.open()
        sheet.close()
        #expect(!sheet.isOpen)
    }
}
