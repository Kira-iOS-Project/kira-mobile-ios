import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** `POST /community/groups/{id}/reports` through the generated client, every answer the route gives. */
@Suite("LiveCommunityService.report")
struct LiveCommunityReportTests {
    private let route = "POST /api/community/groups/g-lunas/reports"

    private func service(_ reply: RoutedTransport.Reply) -> (LiveCommunityService, RoutedTransport) {
        let (api, transport) = KiraAPI.routed([route: reply])
        return (LiveCommunityService(api: api), transport)
    }

    @Test("a reason and a story are sent as the API's values; 201 is done")
    func sent() async throws {
        let (service, transport) = service(ok(#"{"id":"r-1"}"#, status: 201))
        try await service.report(groupID: "g-lunas", reason: .dataOrJockey, story: "Menawarkan joki skor.")
        #expect(await transport.routes == [route])
        #expect(
            await transport.sent.first?.json == [
                "reason": .string("data_or_jockey"), "story": .string("Menawarkan joki skor."),
            ])
    }

    @Test("every reason travels as its backend value", arguments: GroupReportReason.allCases)
    func reasons(reason: GroupReportReason) async throws {
        let (service, transport) = service(ok(#"{"id":"r-1"}"#, status: 201))
        try await service.report(groupID: "g-lunas", reason: reason, story: nil)
        #expect(await transport.sent.first?.json["reason"] == .string(reason.rawValue))
    }

    @Test(
        "a refusal reaches the screen as its problem code",
        arguments: [
            ("COMMUNITY_REPORT_DUPLICATE", 409, ProblemCode.communityReportDuplicate),
            ("COMMUNITY_GROUP_NOT_FOUND", 404, .communityGroupNotFound),
            ("VALIDATION_FAILED", 422, .validationFailed),
            ("AUTH_UNAUTHENTICATED", 401, .authUnauthenticated),
        ])
    func refused(code: String, status: Int, known: ProblemCode) async throws {
        let (service, _) = service(problem(code, status: status))
        let error = await #expect(throws: AppProblem.self) {
            try await service.report(groupID: "g-lunas", reason: .other, story: "Admin meminta transfer.")
        }
        #expect(error?.knownCode == known)
        #expect(CommunityFailure(try #require(error)) == .problem(try #require(error)))
    }

    @Test("no connection is a connection failure, not a problem")
    func offline() async throws {
        do {
            try await LiveCommunityService(api: .offline).report(groupID: "g-lunas", reason: .scam, story: nil)
            Issue.record("the report should not have been sent")
        } catch {
            #expect(!(error is AppProblem))
            #expect(CommunityFailure(error) == .connection)
        }
    }
}
