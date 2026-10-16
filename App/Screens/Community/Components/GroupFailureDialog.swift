/**
 The failure dialog over Detail Grup: a sheet's submit that failed closed the sheet, and this says
 why. A report shows the board's "Laporan Belum Terkirim" (KOM-05c); joining says it could not join.
 Coba Lagi reopens the sheet with what was entered and repeats; Tutup closes.
 */
import APIClient
import Features
import SwiftUI

enum GroupFailureDialog {
    /** The dialog for the model's current failure. */
    @MainActor
    static func dialog(for model: GroupDetailModel) -> KiraDialog {
        let failure = model.failure?.failure ?? .connection
        let isReport = model.failure?.attempt == .report
        let title: LocalizedStringResource = isReport ? "community.report.failed.title" : "community.join.failed"
        let message: LocalizedStringResource =
            isReport && failure == .connection ? "community.report.failed.body" : failure.message
        let close = KiraButton("ds.close", variant: .secondary) {}
        guard model.canRetry else {
            return KiraDialog(title, message: message, art: .illustration(.umbrella), primary: close)
        }
        return KiraDialog(
            title, message: message, art: .illustration(.umbrella),
            primary: KiraButton("community.retry") { Task { await model.retry() } }, secondary: close)
    }
}

extension CommunityFailure {
    /** The failure's sentence: the connection's own, or the API problem's catalog message. */
    var message: LocalizedStringResource {
        switch self {
        case .connection: "community.failure.connection"
        case .problem(let problem) where problem.knownCode == nil: "community.failure.reference \(problem.reference)"
        case .problem(let problem): problem.message
        }
    }
}
