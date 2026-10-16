import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Counts `activate()` calls and fails the first `failures` of them. */
actor FakeDebtEmergencyService: DebtEmergencyService {
    private let failures: Int
    private(set) var calls = 0

    init(failures: Int = 0) {
        self.failures = failures
    }

    func activate() throws {
        calls += 1
        if calls <= failures { throw AppProblem() }
    }
}

/** Records each wait; throws on the wait numbered `cancelAt` (1-based), as a closed screen does. */
actor SleepLog {
    private let cancelAt: Int?
    private(set) var waits: [Duration] = []

    init(cancelAt: Int? = nil) {
        self.cancelAt = cancelAt
    }

    func wait(_ delay: Duration) throws {
        waits.append(delay)
        if waits.count == cancelAt { throw CancellationError() }
    }
}

@MainActor
@Suite("DebtEmergencyModel")
struct DebtEmergencyModelTests {
    private func model(
        _ service: FakeDebtEmergencyService, sleeps: SleepLog = SleepLog(),
        care: FakeCareService = FakeCareService()
    ) -> DebtEmergencyModel {
        DebtEmergencyModel(
            care: care, service: service, retryDelays: [.seconds(5), .seconds(30)],
            sleep: { try await sleeps.wait($0) })
    }

    @Test("opening turns the mode on once; opening again does not call twice")
    func activatesOnce() async {
        let service = FakeDebtEmergencyService()
        let sleeps = SleepLog()
        let model = model(service, sleeps: sleeps)
        await model.activate()
        await model.activate()
        #expect(await service.calls == 1)
        #expect(await sleeps.waits.isEmpty)
    }

    @Test("a failed activation is retried quietly after each delay until it succeeds")
    func retries() async {
        let service = FakeDebtEmergencyService(failures: 2)
        let sleeps = SleepLog()
        await model(service, sleeps: sleeps).activate()
        #expect(await service.calls == 3)
        #expect(await sleeps.waits == [.seconds(5), .seconds(30)])
    }

    @Test("after the last retry it stops, and the next opening tries again")
    func givesUpThenRetriesOnReopen() async {
        let service = FakeDebtEmergencyService(failures: 3)
        let model = model(service)
        await model.activate()
        #expect(await service.calls == 3)
        await model.activate()
        #expect(await service.calls == 4)
    }

    @Test("closing the screen during a wait stops the retries")
    func stopsWhenClosed() async {
        let service = FakeDebtEmergencyService(failures: 5)
        let sleeps = SleepLog(cancelAt: 1)
        await model(service, sleeps: sleeps).activate()
        #expect(await service.calls == 1)
    }

    @Test("the contacts and their links come from the server's list")
    func serverContacts() async {
        let ojk = CareContact(key: .ojk157, name: "OJK", phone: "157", whatsApp: "08111", note: "n")
        let list = CareContactList(verifiedOn: CalendarDay(year: 2026, month: 11, day: 1), contacts: [ojk])
        let model = model(FakeDebtEmergencyService(), care: FakeCareService(result: .success(list)))
        #expect(model.phase.value == nil)
        await model.load()
        #expect(model.phase.value == list)
        #expect(model.contact(.ojk157)?.whatsApp == "08111")
        #expect(model.callURL(.ojk157)?.absoluteString == "tel:157")
        #expect(model.website(.satgasPasti)?.absoluteString == "https://sipasti.ojk.go.id")
        #expect(model.siteName(.iasc) == "iasc.ojk.go.id")
    }

    @Test("an unreachable server still shows the screen, on the shipped contacts")
    func shippedOnFailure() async {
        let model = model(FakeDebtEmergencyService(), care: FakeCareService(result: .failure(AppProblem())))
        await model.load()
        #expect(model.phase.value == .shipped)
        #expect(model.callURL(.ojk157)?.absoluteString == "tel:157")
        #expect(model.callURL(.satgasPasti) == nil)
    }

    @Test("the default sleep really waits before the retry")
    func defaultSleep() async {
        let service = FakeDebtEmergencyService(failures: 1)
        let model = DebtEmergencyModel(care: FakeCareService(), service: service, retryDelays: [.milliseconds(1)])
        await model.activate()
        #expect(await service.calls == 2)
        #expect(model.siteName(.lapsSjk) == "lapssjk.id")
    }

    @Test("Beasiswa Kira waits for one try while the mode is off, and for none once it is on")
    func ensuresActiveBeforeScholarship() async {
        let failing = FakeDebtEmergencyService(failures: 1)
        let sleeps = SleepLog(cancelAt: 1)
        let model = model(failing, sleeps: sleeps)
        await model.activate()
        #expect(await failing.calls == 1)
        await model.ensureActive()
        #expect(await failing.calls == 2)
        await model.ensureActive()
        #expect(await failing.calls == 2)
    }

    @Test("Beasiswa Kira's try is a PUT /care/debt-emergency; a refused one stays quiet")
    func ensuresActiveThroughTheRoute() async {
        let (api, transport) = KiraAPI.routed([
            "PUT /api/care/debt-emergency": ok(#"{"activatedAt":"2026-10-17T03:00:00.000Z"}"#)
        ])
        let model = DebtEmergencyModel(care: FakeCareService(), service: LiveDebtEmergencyService(api: api))
        await model.ensureActive()
        await model.ensureActive()
        #expect(await transport.routes == ["PUT /api/care/debt-emergency"])

        let (down, downTransport) = KiraAPI.routed([
            "PUT /api/care/debt-emergency": problem("INTERNAL_ERROR", status: 500)
        ])
        let offline = DebtEmergencyModel(care: FakeCareService(), service: LiveDebtEmergencyService(api: down))
        await offline.ensureActive()
        await offline.ensureActive()
        #expect(await downTransport.routes.count == 2)
    }
}
