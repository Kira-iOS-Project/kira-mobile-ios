/**
 The sentence of a Kira Peduli failure dialog, worded as a sheet's failure is (SubmissionSheet): the
 connection's for a request that got no answer, the generic one with its reference for a problem
 this app does not know, or else the problem's own (`problem.<CODE>`).
 */
import APIClient
import Foundation

extension AppProblem {
    var failureMessage: LocalizedStringResource {
        if isConnectionLoss { return "problem.connection" }
        if showsReference { return "sheet.failure.reference \(reference)" }
        return message
    }
}
