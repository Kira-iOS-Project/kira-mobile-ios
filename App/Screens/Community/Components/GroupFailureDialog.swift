/**
 The failure dialog over Detail Grup: a sheet's submit that failed closed the sheet, and this says
 why. A report shows the board's "Laporan Belum Terkirim" (KOM-05c), or "Grup Ini Sudah Kamu
 Laporkan" for a report already open; joining says it could not join, and an old rules version
 asks for an update. Coba Lagi reopens the sheet with what was entered and repeats, only where
 sending again can work; Tutup closes and drops it.
 */
import APIClient
import Features
import SwiftUI

enum GroupFailureDialog {
    /** The dialog for `failure` of `attempt`; Coba Lagi runs `onRetry`. */
    static func dialog(
        _ failure: CommunityFailure, of attempt: GroupDetailModel.Attempt, onRetry: @escaping () -> Void
    ) -> KiraDialog {
        let close = KiraButton("ds.close", variant: .secondary) {}
        let title = title(failure, of: attempt)
        let message = message(failure, of: attempt)
        guard failure.kind?.allowsRetry ?? true else {
            return KiraDialog(title, message: message, art: .illustration(.umbrella), primary: close)
        }
        return KiraDialog(
            title, message: message, art: .illustration(.umbrella),
            primary: KiraButton("community.retry", action: onRetry), secondary: close)
    }

    private static func title(_ failure: CommunityFailure, of attempt: GroupDetailModel.Attempt)
        -> LocalizedStringResource
    {
        switch attempt {
        case .report:
            failure.kind == .reportDuplicate ? "community.report.duplicate.title" : "community.report.failed.title"
        case .acceptRules, .join: "community.join.failed"
        }
    }

    private static func message(_ failure: CommunityFailure, of attempt: GroupDetailModel.Attempt)
        -> LocalizedStringResource
    {
        switch (attempt, failure.kind) {
        case (.report, nil): "community.report.failed.body"
        case (.acceptRules, .refused): "community.rules.outdated"
        default: failure.message
        }
    }
}

extension CommunityFailure {
    /** The failure's sentence: the connection's own, or the API problem's catalog message. */
    var message: LocalizedStringResource {
        switch self {
        case .connection: "community.failure.connection"
        case .problem(let problem) where problem.showsReference: "community.failure.reference \(problem.reference)"
        case .problem(let problem): problem.message
        }
    }
}
