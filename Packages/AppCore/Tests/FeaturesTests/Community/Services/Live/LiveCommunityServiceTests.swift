import APIClient
import Domain
import Foundation
import Testing

@testable import Features

private let groupID = "6f1c2a9e-0000-4000-8000-000000000001"
private let groupRoute = "community/groups/\(groupID)"

@Suite("LiveCommunityService")
struct LiveCommunityServiceTests {
    @Test("the directory: categories in order, groups in the curators' order, an unknown icon generic")
    func directory() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/community/groups": ok(communityGroupsJSON)])
        let directory = try await LiveCommunityService(api: api).directory()
        #expect(directory.categories == [.debtFree, .crypto])
        #expect(directory.groups.map(\.name) == ["Lunas Bareng Jakarta", "Kripto Aman 101"])
        #expect(directory.groups[0].platform == .whatsapp && directory.groups[0].memberCount == 1240)
        #expect(directory.groups[0].icon == .paylater && directory.groups[1].icon == .other)
        #expect(directory.groups[1].educationOnly)
        #expect(await transport.routes == ["GET /api/community/groups"])
    }

    @Test("one group in full: the admin's month, the rules, the day the link was checked")
    func group() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/\(groupRoute)": ok(communityGroupJSON)])
        let group = try await LiveCommunityService(api: api).group(id: groupID)
        #expect(
            group.admin
                == CommunityAdmin(
                    name: "Rani A.", initials: "RA", verifiedSince: CalendarDay(year: 2026, month: 3, day: 1)))
        #expect(group.rules.count == 3 && group.about.hasPrefix("Saling dukung"))
        #expect(group.linkCheckedOn == CalendarDay(year: 2026, month: 10, day: 12))
        #expect(group.adminUnchanged && !group.rulesAccepted)
    }

    @Test("a gone or suspended group is 404 COMMUNITY_GROUP_NOT_FOUND")
    func notFound() async {
        let (api, _) = KiraAPI.routed(["GET /api/\(groupRoute)": problem("COMMUNITY_GROUP_NOT_FOUND", status: 404)])
        await expectProblem("COMMUNITY_GROUP_NOT_FOUND") {
            _ = try await LiveCommunityService(api: api).group(id: groupID)
        }
    }

    @Test("accepting sends the rules' version; joining returns the invite")
    func acceptAndJoin() async throws {
        let (api, transport) = KiraAPI.routed([
            "POST /api/community/rules/consent": empty(),
            "POST /api/\(groupRoute)/join": ok(communityJoinJSON),
        ])
        let service = LiveCommunityService(api: api)
        try await service.acceptRules(version: CommunityRules.version)
        #expect(await transport.sent[0].json == ["version": .string("community-2026-10-01")])
        let invite = try await service.join(groupID: groupID)
        #expect(invite.url.absoluteString == "https://chat.whatsapp.com/LunasBarengJakarta")
        #expect(invite.platform == .whatsapp && invite.linkCheckedOn.day == 12)
    }

    @Test("an old rules version is refused here; the server's 422 is thrown too")
    func oldVersion() async {
        let (api, transport) = KiraAPI.routed([
            "POST /api/community/rules/consent": problem("VALIDATION_FAILED", status: 422)
        ])
        await #expect(throws: AppProblem()) {
            try await LiveCommunityService(api: api).acceptRules(version: "community-2025")
        }
        #expect(await transport.routes.isEmpty)
    }

    @Test(
        "joining is refused for rules not accepted, a link being checked, a gone group, a bad request",
        arguments: [
            ("COMMUNITY_RULES_NOT_ACCEPTED", 409), ("COMMUNITY_LINK_UNAVAILABLE", 409),
            ("COMMUNITY_GROUP_NOT_FOUND", 404), ("VALIDATION_FAILED", 422),
        ])
    func joinRefused(code: String, status: Int) async {
        let (api, _) = KiraAPI.routed(["POST /api/\(groupRoute)/join": problem(code, status: status)])
        await expectProblem(code) { _ = try await LiveCommunityService(api: api).join(groupID: groupID) }
    }

    @Test("an invite that is not an https link is a problem without a code")
    func badInvite() async {
        let (api, _) = KiraAPI.routed([
            "POST /api/\(groupRoute)/join": ok(
                #"{"inviteUrl":"whatsapp://x","platform":"whatsapp","linkCheckedOn":"2026-10-12"}"#)
        ])
        await #expect(throws: AppProblem()) { try await LiveCommunityService(api: api).join(groupID: groupID) }
    }

    @Test("offline, every call fails without an answer, which the screens read as the connection")
    func offline() async {
        let service = LiveCommunityService(api: .offline)
        await expectConnection { _ = try await service.directory() }
        await expectConnection { _ = try await service.group(id: groupID) }
        await expectConnection { try await service.acceptRules(version: CommunityRules.version) }
        await expectConnection { _ = try await service.join(groupID: groupID) }
    }

    private func expectConnection(_ call: () async throws -> Void) async {
        do {
            try await call()
            Issue.record("answered")
        } catch {
            #expect(CommunityFailure(error) == .connection)
        }
    }
}

/** Expects `call` to throw an `AppProblem` with `code`. */
private func expectProblem(_ code: String, _ call: () async throws -> Void) async {
    let problem = await #expect(throws: AppProblem.self) { try await call() }
    #expect(problem?.code == code)
}
