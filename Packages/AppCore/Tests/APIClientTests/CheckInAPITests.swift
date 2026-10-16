/** Kira Peduli's crisis signals and check-ins: what is sent, what is read, every problem. */
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private let checkInJSON = #"{"id":"6f1c2a8e-4b1d-4d7a-9c3e-2f5b8a1d0e74","dueAt":"2026-10-16T12:00:00.000Z"}"#

private struct SignalBody: Decodable { let level: String, source: String }
private struct ScheduleBody: Decodable { let afterHours: Int }

@Suite("CheckInAPI")
struct CheckInAPITests {
    @Test("records a signal with its level and source only")
    func recordsSignal() async throws {
        let (api, transport) = KiraAPI.canned(status: 204)
        try await api.recordCareSignal(level: .danger, source: .checkIn)
        let request = try #require(await transport.request)
        #expect(request.method == .post && request.path.hasSuffix("care/signals"))
        let body = try request.decoded(SignalBody.self)
        #expect(body.level == "danger" && body.source == "check_in")
        #expect(!request.text.contains("text") && !request.text.contains("message"))
    }

    @Test("schedules a check-in after the chosen hours")
    func schedules() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: checkInJSON)
        let checkIn = try await api.scheduleCheckIn(afterHours: 48)
        #expect(checkIn.id == "6f1c2a8e-4b1d-4d7a-9c3e-2f5b8a1d0e74")
        #expect(checkIn.dueAt == Date(timeIntervalSince1970: 1_792_152_000))
        let request = try #require(await transport.request)
        #expect(request.path.hasSuffix("care/check-ins"))
        #expect(try request.decoded(ScheduleBody.self).afterHours == 48)
    }

    @Test("reads the due check-in, or none")
    func readsDue() async throws {
        let due = try await KiraAPI.canned(json: #"{"checkIn":\#(checkInJSON)}"#).api.getDueCheckIn()
        #expect(due?.id == "6f1c2a8e-4b1d-4d7a-9c3e-2f5b8a1d0e74")
        let none = try await KiraAPI.canned(json: #"{"checkIn":null}"#).api.getDueCheckIn()
        #expect(none == nil)
    }

    @Test("marks a check-in seen")
    func marksSeen() async throws {
        let (api, transport) = KiraAPI.canned(status: 204)
        try await api.markCheckInSeen(id: "c-1")
        let request = try #require(await transport.request)
        #expect(request.method == .post && request.path.hasSuffix("care/check-ins/c-1/seen"))
    }

    @Test("throws every problem the care routes answer")
    func problems() async {
        await expectProblems([401, 422]) { try await $0.recordCareSignal(level: .concern, source: .chat) }
        await expectProblems([401, 422]) { _ = try await $0.scheduleCheckIn(afterHours: 24) }
        await expectProblems([401]) { _ = try await $0.getDueCheckIn() }
        await expectProblems([401, 404, 422]) { try await $0.markCheckInSeen(id: "c-1") }
    }
}
