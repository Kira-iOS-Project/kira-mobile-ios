import APIClient
import Domain

/** Komunitas's calls over the API client (KOM-01 to KOM-05). */
package struct LiveCommunityService: CommunityService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /community/groups`. */
    package func directory() async throws -> CommunityDirectory {
        try CommunityDirectory(try await api.listCommunityGroups())
    }

    /** `GET /community/groups/{id}`. */
    package func group(id: String) async throws -> CommunityGroup {
        try CommunityGroup(try await api.getCommunityGroup(id: id))
    }

    /** `POST /community/rules/consent`. */
    package func acceptRules(version: String) async throws {
        try await api.acceptCommunityRules(version: version)
    }

    /** `POST /community/groups/{id}/join`. */
    package func join(groupID: String) async throws -> GroupInvite {
        try GroupInvite(try await api.joinCommunityGroup(id: groupID))
    }

    /** `POST /community/groups/{id}/reports`. */
    package func report(groupID: String, reason: GroupReportReason, story: String?) async throws {
        try await api.reportCommunityGroup(id: groupID, reason: try Bridge.value(reason), story: story)
    }
}
