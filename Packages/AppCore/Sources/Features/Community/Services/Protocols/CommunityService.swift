import APIClient
import Domain

/**
 What the Komunitas screens need from the API (CONTRACT-KOM-PED, Community). Each call throws an
 `AppProblem` for an answer the API refused, and any other error when there was no answer.
 Products (Etalase) have their own service.
 */
package protocol CommunityService: Sendable {
    /** `GET /community/groups`: the categories and every active group, in the curators' order. */
    func directory() async throws -> CommunityDirectory
    /** `GET /community/groups/{id}`; 404 `COMMUNITY_GROUP_NOT_FOUND`, also for a suspended group. */
    func group(id: String) async throws -> CommunityGroup
    /** `POST /community/rules/consent {version}`: accepts the rules in force. */
    func acceptRules(version: String) async throws
    /** `POST /community/groups/{id}/join`: the invite; 409 `COMMUNITY_RULES_NOT_ACCEPTED`. */
    func join(groupID: String) async throws -> GroupInvite
    /** `POST /community/groups/{id}/reports`; 409 `COMMUNITY_REPORT_DUPLICATE`, 422 for a bad story. */
    func report(groupID: String, reason: GroupReportReason, story: String?) async throws
}

/** Why an action of the Komunitas screens failed: no answer, or the API's problem. */
package enum CommunityFailure: Equatable, Sendable {
    /** The request got no answer: the connection dropped. */
    case connection
    /** The API answered with this problem. */
    case problem(AppProblem)

    /**
     The failure `error` stands for, read as `AppProblem(_:)` reads it: the API's problem (also
     wrapped by the client), no answer for a transport failure, else the generic problem.
     */
    package init(_ error: any Error) {
        let problem = AppProblem(error)
        self = problem.isConnectionLoss ? .connection : .problem(problem)
    }

    /** The problem to show on a screen that could not load: the API's, or the connection's. */
    package var screenProblem: AppProblem {
        if case .problem(let problem) = self { return problem }
        return .connectionLost
    }
}
