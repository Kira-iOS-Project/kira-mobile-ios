import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** PED-05 Check-in Lanjutan and PED-06 the greeting when Catat opens. */
@MainActor
@Suite("Catat check-in")
struct CheckInChatTests {
    private func model(_ checkIns: FakeCheckInService, service: FakeRecordService = FakeRecordService()) -> RecordModel {
        RecordModel(dependencies: Fixtures.dependencies(service: service, checkIns: checkIns))
    }

    private func offered(_ checkIns: FakeCheckInService) -> (RecordModel, CheckInModel?) {
        let record = model(checkIns)
        record.care.helpClosed()
        return (record, record.care.checkIn)
    }

    @Test("Ya, Sapa Aku schedules the chosen delay and closes")
    func schedules() async throws {
        let checkIns = FakeCheckInService()
        let (record, offer) = offered(checkIns)
        let checkIn = try #require(offer)
        #expect(checkIn.delay == .tomorrow)
        checkIn.delay = .threeDays
        await checkIn.schedule()
        #expect(checkIns.scheduled == [.threeDays] && record.care.checkIn == nil)
    }

    @Test("Tidak Perlu schedules nothing")
    func declines() throws {
        let checkIns = FakeCheckInService()
        let (record, offer) = offered(checkIns)
        try #require(offer).decline()
        #expect(checkIns.scheduled.isEmpty && record.care.checkIn == nil)
    }

    @Test(
        "a failed request closes the offer; the dialog's Coba Lagi reopens it with the choice kept",
        arguments: [
            (OfflineError() as any Error, RecordFailure.connection),
            (problem("VALIDATION_FAILED") as any Error, RecordFailure.problem(problem("VALIDATION_FAILED"))),
        ] as [(any Error, RecordFailure)])
    func fails(error: any Error, expected: RecordFailure) async throws {
        let checkIns = FakeCheckInService()
        checkIns.scheduleResult = .failure(error)
        let (record, offer) = offered(checkIns)
        let checkIn = try #require(offer)
        checkIn.delay = .dayAfterTomorrow
        await checkIn.schedule()
        #expect(record.care.checkIn == nil && !checkIn.isSaving)
        #expect(record.care.checkInFailure == CheckInFailure(failure: expected, delay: .dayAfterTomorrow))
        record.care.retryCheckIn()
        let again = try #require(record.care.checkIn)
        #expect(again.delay == .dayAfterTomorrow && record.care.checkInFailure == nil)
        checkIns.scheduleResult = .success(CheckIn(id: "c-2", dueAt: Fixtures.noon))
        await again.schedule()
        #expect(checkIns.scheduled == [.dayAfterTomorrow, .dayAfterTomorrow] && record.care.checkIn == nil)
        record.care.retryCheckIn()
        #expect(record.care.checkIn == nil)
    }

    @Test("a due check-in greets by name when Catat opens, once, and is marked shown")
    func greets() async {
        let checkIns = FakeCheckInService()
        checkIns.dueResult = .success(CheckIn(id: "c-9", dueAt: Fixtures.noon))
        let record = model(checkIns)
        await record.load()
        await record.load()
        #expect(record.care.entries.map(\.kind) == [.checkInGreeting(name: "dinda", isAnswered: false)])
        #expect(checkIns.seen == ["c-9", "c-9"])
    }

    @Test("no greeting when none is due, the call fails, or the chat did not load")
    func noGreeting() async {
        let none = model(FakeCheckInService())
        await none.load()
        #expect(none.care.entries.isEmpty)
        let failing = FakeCheckInService()
        failing.dueResult = .failure(OfflineError())
        let offline = model(failing)
        await offline.load()
        #expect(offline.care.entries.isEmpty && offline.phase.value != nil)
        let due = FakeCheckInService()
        due.dueResult = .success(CheckIn(id: "c-9", dueAt: Fixtures.noon))
        let broken = FakeRecordService()
        broken.profileResult = .failure(OfflineError())
        let unloaded = model(due, service: broken)
        await unloaded.load()
        #expect(unloaded.care.entries.isEmpty && due.seen.isEmpty)
    }

    @Test("the greeting shows even when marking it shown fails")
    func seenFails() async {
        let checkIns = FakeCheckInService()
        checkIns.dueResult = .success(CheckIn(id: "c-9", dueAt: Fixtures.noon))
        checkIns.seenResult = .failure(problem("CARE_CHECK_IN_NOT_FOUND"))
        let record = model(checkIns)
        await record.load()
        #expect(record.care.entries.count == 1)
    }

    @Test("Sedikit Lebih Baik answers; Masih Berat opens the help; Mau Bahas Utangnya opens Mode Darurat Utang")
    func greetingReplies() async throws {
        let checkIns = FakeCheckInService()
        checkIns.dueResult = .success(CheckIn(id: "c-9", dueAt: Fixtures.noon))
        let record = model(checkIns)
        var opened: [AppRoute] = []
        record.onOpen = { opened.append($0) }
        await record.load()
        let greeting = try #require(record.care.entries.first)
        await record.care.choose(.talkAboutDebt, in: greeting)
        #expect(opened == [.unavailable(.debtEmergency)] && record.care.entries.count == 1)
        await record.care.choose(.better, in: greeting)
        #expect(
            record.care.entries.map(\.kind) == [
                .checkInGreeting(name: "dinda", isAnswered: true), .personChoice(.better), .checkInBetter,
            ])
        record.care.openDebtEmergency()
        #expect(opened.count == 2)
        await record.care.choose(.stillHeavy, in: greeting)
        #expect(record.care.isHelpPresented)
        #expect(checkIns.signals.map(\.level) == [.concern] && checkIns.signals.map(\.source) == [.checkIn])
    }
}
