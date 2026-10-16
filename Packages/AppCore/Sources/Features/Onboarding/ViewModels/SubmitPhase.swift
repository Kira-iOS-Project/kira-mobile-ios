import APIClient

/**
 The phase of a screen that sends one thing and moves on (a code request, a consent, an answer):
 editing, sending, or failed with the API's problem, which the screen shows until the next try.
 */
package enum SubmitPhase: Hashable, Sendable {
    /** Waiting for the person. */
    case editing
    /** The request is on its way; the main button waits. */
    case submitting
    /** The API refused or could not be reached. */
    case failed(AppProblem)

    /** Whether the request is on its way. */
    package var isSubmitting: Bool { self == .submitting }

    /** The problem to show, nil unless failed. */
    package var problem: AppProblem? {
        if case .failed(let problem) = self { return problem }
        return nil
    }

    /** The phase after `error`: its `AppProblem`, or a problem without a code for anything else. */
    package static func failure(_ error: any Error) -> Self {
        .failed(error as? AppProblem ?? AppProblem())
    }
}
