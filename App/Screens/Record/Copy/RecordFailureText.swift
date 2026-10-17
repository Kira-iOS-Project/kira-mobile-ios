/**
 The words of a Catat failure: the connection's own sentence, a known problem's catalog message,
 or the generic one with the reference a person quotes to support (AGENTS.md Rule 12).
 */
import APIClient
import Features
import SwiftUI

extension RecordFailure {
    /** The dialog's message. */
    var recordMessage: LocalizedStringResource {
        switch self {
        case .connection:
            "record.failure.connection"
        case .problem(let problem) where problem.showsReference:
            "record.failure.reference \(problem.reference)"
        case .problem(let problem):
            problem.message
        }
    }

    /** The failure dialog: what happened, Coba Lagi on top and Tutup; the screen keeps what was entered. */
    func dialog(onRetry: @escaping () -> Void) -> KiraDialog {
        KiraDialog(
            "record.failure.title", message: recordMessage, art: .illustration(.umbrella),
            primary: KiraButton("record.retry", action: onRetry),
            secondary: KiraButton("ds.close", variant: .secondary) {})
    }
}

extension View {
    /** Shows `failure` as a dialog while it is set, and clears it when the dialog closes; Coba Lagi runs `onRetry`. */
    func recordFailureDialog(_ failure: Binding<RecordFailure?>, onRetry: @escaping () -> Void) -> some View {
        kiraDialog(
            isPresented: Binding(get: { failure.wrappedValue != nil }, set: { if !$0 { failure.wrappedValue = nil } })
        ) {
            (failure.wrappedValue ?? .connection).dialog(onRetry: onRetry)
        }
    }
}
