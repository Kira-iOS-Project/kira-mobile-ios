import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/**
 PED-05 "Bisa dibatalkan kapan saja": a scheduled check-in opens again with its delay chosen, and
 Tidak Perlu cancels it, quietly, sent again later when it does not arrive.
 */
@MainActor
@Suite("Catat check-in cancel")
struct CareOutboxTests {
    /** Catat with a check-in scheduled for `delay` (c-1). */
    private func scheduled(
        _ checkIns: FakeCheckInService, delay: CheckInDelay = .threeDays
    ) async throws -> RecordModel {
        let record = RecordModel(dependencies: Fixtures.dependencies(service: FakeRecordService(), checkIns: checkIns))
        await record.load()
        record.care.helpClosed()
        let offer = try #require(record.care.checkIn)
        offer.delay = delay
        await offer.schedule()
        return record
    }

    /** Aku Aman under a new crisis reply: the offer again. */
    private func offerAgain(_ record: RecordModel) async throws -> CheckInModel {
        record.composerText = "putus asa"
        await record.send()
        await record.care.choose(.safe, in: try #require(record.care.entries.last))
        return try #require(record.care.checkIn)
    }

    @Test("a scheduled check-in opens with its delay chosen; Tidak Perlu cancels it, once")
    func cancels() async throws {
        let checkIns = FakeCheckInService()
        let record = try await scheduled(checkIns)
        let offer = try await offerAgain(record)
        #expect(offer.delay == .threeDays)
        await offer.decline()
        #expect(checkIns.cancelled == ["c-1"] && record.care.checkIn == nil)
        let next = try await offerAgain(record)
        #expect(next.delay == .tomorrow)
        await next.decline()
        #expect(checkIns.cancelled == ["c-1"])
    }

    @Test("a cancel that does not arrive is quiet, is sent again, and its greeting never shows")
    func cancelFails() async throws {
        let checkIns = FakeCheckInService()
        let record = try await scheduled(checkIns)
        checkIns.cancelResult = .failure(OfflineError())
        try await offerAgain(record).decline()
        #expect(checkIns.cancelled == ["c-1"] && record.failure == nil && record.care.checkInFailure == nil)
        checkIns.dueResult = .success(CheckIn(id: "c-1", dueAt: Fixtures.noon))
        await record.load()
        #expect(checkIns.cancelled == ["c-1", "c-1"] && checkIns.seen.isEmpty)
        #expect(!record.care.entries.contains { $0.id == "check-in-c-1" })
        checkIns.cancelResult = .failure(problem("CARE_CHECK_IN_NOT_FOUND"))
        checkIns.dueResult = .success(nil)
        await record.load()
        await record.load()
        #expect(checkIns.cancelled == ["c-1", "c-1", "c-1"])
    }

    @Test("a greeting that came clears the schedule: the next offer starts at Besok")
    func greetingClears() async throws {
        let checkIns = FakeCheckInService()
        let record = try await scheduled(checkIns, delay: .dayAfterTomorrow)
        checkIns.dueResult = .success(CheckIn(id: "c-1", dueAt: Fixtures.noon))
        await record.load()
        #expect(record.care.entries.contains { $0.id == "check-in-c-1" })
        let offer = try await offerAgain(record)
        #expect(offer.delay == .tomorrow)
        await offer.decline()
        #expect(checkIns.cancelled.isEmpty)
    }
}
