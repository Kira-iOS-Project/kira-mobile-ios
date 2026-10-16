/**
 The words of a Catat failure: the connection's own sentence, a known problem's catalog message,
 or the generic one with the reference a person quotes to support (AGENTS.md Rule 12).
 */
import APIClient
import Domain
import Features
import SwiftUI

extension RecordFailure {
    /** The dialog's message. */
    var recordMessage: LocalizedStringResource {
        switch self {
        case .connection:
            "record.failure.connection"
        case .problem(let problem) where problem.knownCode == nil:
            "record.failure.reference \(problem.reference)"
        case .problem(let problem):
            LocalizedStringResource(String.LocalizationValue(problem.messageKey))
        }
    }

    /** The failure dialog: what happened and Tutup; the screen keeps what the person entered. */
    var dialog: KiraDialog {
        KiraDialog(
            "record.failure.title", message: recordMessage, art: .illustration(.umbrella),
            primary: KiraButton("ds.close", variant: .secondary) {})
    }
}

extension View {
    /** Shows `failure` as a dialog while it is set, and clears it when the dialog closes. */
    func recordFailureDialog(_ failure: Binding<RecordFailure?>) -> some View {
        kiraDialog(
            isPresented: Binding(get: { failure.wrappedValue != nil }, set: { if !$0 { failure.wrappedValue = nil } })
        ) {
            (failure.wrappedValue ?? .connection).dialog
        }
    }
}
