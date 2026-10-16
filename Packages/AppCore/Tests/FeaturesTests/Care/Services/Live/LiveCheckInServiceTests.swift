import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveCheckInService")
struct LiveCheckInServiceTests {
    private let checkInJSON = #"{"id":"6f1c2a8e-4b1d-4d7a-9c3e-2f5b8a1d0e74","dueAt":"2026-10-16T12:00:00.000Z"}"#

    @Test("a signal sends its level and source only")
    func signal() async throws {
        let (api, transport) = KiraAPI.routed(["POST /api/care/signals": empty()])
        try await LiveCheckInService(api: api).recordSignal(.concern, source: .checkIn)
        let sent = try #require(await transport.sent.first)
        #expect(sent.json == ["level": .string("concern"), "source": .string("check_in")])
    }

    @Test("schedules, reads the due check-in and marks it seen")
    func checkIns() async throws {
        let id = "6f1c2a8e-4b1d-4d7a-9c3e-2f5b8a1d0e74"
        let (api, transport) = KiraAPI.routed([
            "POST /api/care/check-ins": ok(checkInJSON, status: 201),
            "GET /api/care/check-ins/due": ok(#"{"checkIn":\#(checkInJSON)}"#),
            "POST /api/care/check-ins/\(id)/seen": empty(),
            "DELETE /api/care/check-ins/\(id)": empty(),
        ])
        let service = LiveCheckInService(api: api)
        let scheduled = try await service.schedule(after: .tomorrow)
        #expect(scheduled == CheckIn(id: id, dueAt: Date(timeIntervalSince1970: 1_792_152_000)))
        #expect(try await service.due() == scheduled)
        try await service.markSeen(id: id)
        try await service.cancel(id: id)
        let sent = await transport.sent
        #expect(sent.first?.json == ["afterHours": .number(24)])
        let routes = ["POST /api/care/check-ins/\(id)/seen", "DELETE /api/care/check-ins/\(id)"]
        #expect(Array(sent.map(\.route).suffix(2)) == routes)
    }

    @Test("no due check-in is nil")
    func noneDue() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/care/check-ins/due": ok(#"{"checkIn":null}"#)])
        #expect(try await LiveCheckInService(api: api).due() == nil)
    }

    @Test("every problem the routes answer reaches the caller by its code")
    func problems() async {
        let (api, _) = KiraAPI.routed([
            "POST /api/care/signals": problem("VALIDATION_FAILED", status: 422),
            "POST /api/care/check-ins": problem("AUTH_UNAUTHENTICATED", status: 401),
            "GET /api/care/check-ins/due": problem("AUTH_UNAUTHENTICATED", status: 401),
            "POST /api/care/check-ins/c-1/seen": problem("CARE_CHECK_IN_NOT_FOUND", status: 404),
            "DELETE /api/care/check-ins/c-2": problem("CARE_CHECK_IN_NOT_FOUND", status: 404),
        ])
        let service = LiveCheckInService(api: api)
        #expect(await code { try await service.recordSignal(.danger, source: .chat) } == .validationFailed)
        #expect(await code { _ = try await service.schedule(after: .threeDays) } == .authUnauthenticated)
        #expect(await code { _ = try await service.due() } == .authUnauthenticated)
        #expect(await code { try await service.markSeen(id: "c-1") } == .careCheckInNotFound)
        #expect(await code { try await service.cancel(id: "c-2") } == .careCheckInNotFound)
    }

    /** The code of the problem `call` throws, or nil when it throws none. */
    private func code(_ call: () async throws -> Void) async -> ProblemCode? {
        do {
            try await call()
            return nil
        } catch {
            return (error as? AppProblem)?.knownCode
        }
    }
}
