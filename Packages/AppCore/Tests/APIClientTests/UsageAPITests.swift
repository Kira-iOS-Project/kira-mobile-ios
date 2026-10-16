/** GET /usage through a canned transport. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

@Suite("UsageAPI")
struct UsageAPITests {
    @Test("reads the usage of the current quota period")
    func readsUsage() async throws {
        let (api, transport) = KiraAPI.canned(json: usageJSON)

        let usage = try await api.getUsage()

        #expect(usage.aiMessages.used == 1)
        #expect(usage.aiMessages.limit == 30)
        #expect(usage.resetsOn == "2026-11-01")
        let sent = try #require(await transport.request)
        #expect(sent.method == .get)
        #expect(sent.path.hasSuffix("usage"))
    }

    @Test(
        "throws the problem of a failure",
        arguments: failureCases("getUsage", statuses: [401]) { _ = try await $0.getUsage() })
    func throwsProblems(failure: FailureCase) async {
        let (api, _) = KiraAPI.canned(status: failure.status, json: problemJSON("X_CODE"))
        await #expect(throws: failure.expectedProblem) {
            try await failure.call(api)
        }
    }
}
