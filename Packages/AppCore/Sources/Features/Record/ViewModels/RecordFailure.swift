import APIClient

/**
 Why a Catat action did not go through: the connection (the request never got an answer: CAT-04c
 "Koneksi terputus"), or a problem the API answered with, which shows its own message.
 */
package enum RecordFailure: Equatable, Sendable {
    /** The request got no answer. */
    case connection
    /** The API answered with this problem. */
    case problem(AppProblem)

    /** The failure an error from `RecordService` stands for. */
    package init(_ error: any Error) {
        let problem = AppProblem(error)
        self = problem.isConnectionLoss ? .connection : .problem(problem)
    }
}
