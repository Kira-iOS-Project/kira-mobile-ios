/** The community directory: groups, one group, the rules' consent, joining and reporting. */
extension KiraAPI {
    /** The categories and the active groups (`GET /api/community/groups`). */
    package func listCommunityGroups() async throws -> CommunityGroupsDTO {
        try await client.listCommunityGroups().groups()
    }

    /** One group (`GET /api/community/groups/{id}`); 404 `COMMUNITY_GROUP_NOT_FOUND`. */
    package func getCommunityGroup(id: String) async throws -> CommunityGroupDTO {
        try await client.getCommunityGroup(path: .init(id: id)).group()
    }

    /** Accepts the rules of `version` (`POST /api/community/rules/consent`). */
    package func acceptCommunityRules(version: String) async throws {
        guard let accepted = Components.Schemas.CommunityRulesConsentRequest.VersionPayload(rawValue: version) else {
            throw AppProblem()
        }
        try await client.acceptCommunityRules(body: .json(.init(version: accepted))).done()
    }

    /** The invite (`POST /api/community/groups/{id}/join`); 409 when the rules or the link are missing. */
    package func joinCommunityGroup(id: String) async throws -> CommunityGroupJoinDTO {
        try await client.joinCommunityGroup(path: .init(id: id)).invite()
    }

    /** Reports the group (`POST /api/community/groups/{id}/reports`); `story` is sent only when given. */
    package func reportCommunityGroup(id: String, reason: GroupReportReasonDTO, story: String?) async throws {
        let body = Components.Schemas.CommunityReportRequest(reason: try bridged(reason), story: story)
        try await client.reportCommunityGroup(path: .init(id: id), body: .json(body)).done()
    }
}

extension Operations.ListCommunityGroups.Output {
    func groups() throws -> CommunityGroupsDTO {
        switch self {
        case .ok(let response): return try CommunityGroupsDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetCommunityGroup.Output {
    func group() throws -> CommunityGroupDTO {
        switch self {
        case .ok(let response): return try CommunityGroupDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.AcceptCommunityRules.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.JoinCommunityGroup.Output {
    func invite() throws -> CommunityGroupJoinDTO {
        switch self {
        case .ok(let response): return try CommunityGroupJoinDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.ReportCommunityGroup.Output {
    func done() throws {
        switch self {
        case .created: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
