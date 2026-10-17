/**
 How every screen words a problem (AGENTS.md Rule 12): the catalog's message for its code
 (`problem.<CODE>`), or the generic one with the reference a person quotes to support, and the
 sentence every failure dialog shows.
 */
import APIClient
import Foundation

extension AppProblem {
    /** The catalog's message for this problem: its code's, or `problem.unknown`. */
    var message: LocalizedStringResource {
        LocalizedStringResource(String.LocalizationValue(messageKey))
    }

    /**
     The sentence of a failure dialog, worded as a sheet's failure is (SubmissionSheet): the
     connection's for a request that got no answer, the generic one with its reference for a problem
     this app does not know, or else the problem's own (`problem.<CODE>`).
     */
    var failureMessage: LocalizedStringResource {
        if isConnectionLoss { return "problem.connection" }
        if showsReference { return "sheet.failure.reference \(reference)" }
        return message
    }
}
