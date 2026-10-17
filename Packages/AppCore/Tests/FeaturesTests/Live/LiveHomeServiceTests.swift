import APIClient
import Domain
import Testing

@testable import Features

/** What the services handed to the app lock. */
@MainActor
final class HideBalancesRecorder {
    private(set) var values: [Bool] = []

    /** The sync closure the services take. */
    var sync: HideBalancesSync { { [self] in values.append($0) } }
}

@MainActor
@Suite("LiveHomeService")
struct LiveHomeServiceTests {
    @Test("GET /home becomes Beranda's overview with every part")
    func overview() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/home": ok(overviewJSON)])
        let home = try await LiveHomeService(api: api, onHideBalances: HideBalancesRecorder().sync).home()
        #expect(home.variant == .overview && home.displayName == "Dinda" && !home.hideBalances)
        #expect(home.today == CalendarDay(year: 2026, month: 10, day: 16).date)
        #expect(home.period.start == CalendarDay(year: 2026, month: 9, day: 25) && home.period.daysUntilPayday == 9)
        #expect(
            home.money
                == PeriodMoney(
                    income: 7_500_000, spent: 5_660_000, remaining: 1_840_000, perDay: 204_444, spentPercent: 75))
        #expect(home.step?.kind == .payOffDebt && home.stepPosition == StepPosition(index: 1, total: 3))
        #expect(home.score == ScoreSummary(score: 66, band: .coping, delta: 4, isInitial: false))
        #expect(home.weeklySummary?.first == CalendarDay(year: 2026, month: 10, day: 9))
        #expect(home.checklist == FirstStepsChecklist(healthCheck: true, firstTransaction: false, paydaySet: true))
        #expect(
            home.debtPlan == DebtPlanProgress(paidOff: 1_600_000, total: 20_000_000, remaining: 18_400_000, percent: 8))
        #expect(home.microTarget == MicroTarget(kind: .oneWeek, current: 120_000, target: 350_000))
    }

    @Test("a first-steps Beranda leaves out what it has not got yet")
    func firstSteps() async throws {
        let (api, _) = KiraAPI.routed(["GET /api/home": ok(firstStepsJSON)])
        let home = try await LiveHomeService(api: api, onHideBalances: HideBalancesRecorder().sync).home()
        #expect(home.variant == .firstSteps && home.hideBalances)
        #expect(home.money == nil && home.step == nil && home.score == nil && home.weeklySummary == nil)
    }

    @Test("loads bills for Beranda from the generated bill-list operation")
    func bills() async throws {
        let json =
            #"{"items":[{"id":"bill-1","kind":"bill","name":"Internet Rumah","amount":350000,"category":"bills","nextDueDate":"2026-10-22","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":null,"linkedDebtName":null,"dueSoon":true,"paidThisPeriod":false}]}"#
        let (api, transport) = KiraAPI.routed(["GET /api/bills": ok(json)])

        let bills = try await LiveHomeService(api: api, onHideBalances: HideBalancesRecorder().sync).bills()

        #expect(bills.map(\.id) == ["bill-1"])
        #expect(await transport.routes == ["GET /api/bills"])
    }

    @Test("the eye saves hideBalances to the account and hands it to the lock")
    func hideBalances() async throws {
        let recorder = HideBalancesRecorder()
        let (api, transport) = KiraAPI.routed(["PATCH /api/me": ok(meJSON(hideBalances: true))])
        try await LiveHomeService(api: api, onHideBalances: recorder.sync).setHideBalances(true)
        #expect(await transport.sent.first?.json["hideBalances"] == .bool(true))
        #expect(recorder.values == [true])
    }
}
