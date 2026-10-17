import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Tagihan & Cicilan against the board's six bills on 15 October 2026 (lane AlurUang, UNG-06). */
@MainActor
@Suite("BillsModel")
struct BillsModelTests {
    private func model(_ service: FakeBillService = FakeBillService()) -> BillsModel {
        BillsModel(service: service, today: { BillFixtures.today })
    }

    @Test("loads the board's three groups, six bills and Rp2.150.000,00 a month")
    func loadsBoard() async throws {
        let model = model()
        #expect(model.phase.value == nil)
        await model.load()
        let overview = try #require(model.phase.value)
        #expect(overview.count == 6 && overview.monthlyTotal == 2_150_000)
        #expect(overview.sections.map(\.group) == [.nextSevenDays, .thisMonth, .nextMonth])
    }

    @Test("the board's tags: turmeric for a bill ≤5 days or an instalment ≤10, the date next month, paid")
    func boardTags() {
        let model = model()
        #expect(model.tag(for: BillFixtures.electricity, in: .nextSevenDays) == .daysLeft(5, urgent: true))
        #expect(model.tag(for: BillFixtures.internet, in: .nextSevenDays) == .daysLeft(7, urgent: false))
        #expect(model.tag(for: BillFixtures.paylaterA, in: .thisMonth) == .daysLeft(10, urgent: true))
        #expect(model.tag(for: BillFixtures.motorbike, in: .thisMonth) == .daysLeft(13, urgent: false))
        #expect(model.tag(for: BillFixtures.paylaterB, in: .nextMonth) == .date(CalendarDay(year: 2026, month: 11, day: 5)))
        #expect(model.tag(for: BillFixtures.bpjs, in: .nextMonth) == .paid(month: 10))
    }

    @Test("an overdue bill shows 0 days, urgent; a yearly bill later shows its date; paid yearly keeps its month")
    func edgeTags() {
        let model = model()
        let overdue = Bill(
            id: "late", name: "Air", kind: .bill, category: "bills", amount: 90_000,
            dueOn: CalendarDay(year: 2026, month: 1, day: 12), dueDay: 12, nextDueOn: CalendarDay(year: 2026, month: 10, day: 12))
        #expect(model.tag(for: overdue, in: .nextSevenDays) == .daysLeft(0, urgent: true))
        let yearly = Bill(
            id: "pbb", name: "PBB", kind: .bill, category: "bills", amount: 400_000, repeats: .yearly,
            dueOn: CalendarDay(year: 2026, month: 3, day: 1), dueDay: 1, nextDueOn: CalendarDay(year: 2027, month: 3, day: 1))
        #expect(model.tag(for: yearly, in: .later) == .date(CalendarDay(year: 2027, month: 3, day: 1)))
        let paidYearly = Bill(
            id: "stnk", name: "STNK", kind: .bill, category: "transport", amount: 600_000, repeats: .yearly,
            dueOn: CalendarDay(year: 2025, month: 12, day: 3), dueDay: 3, nextDueOn: CalendarDay(year: 2026, month: 12, day: 3),
            paidThisPeriod: true)
        #expect(model.tag(for: paidYearly, in: .nextMonth) == .paid(month: 12))
    }

    @Test("no bills is empty")
    func empty() async {
        let model = model(FakeBillService(overview: BillOverview(count: 0, monthlyTotal: 0, sections: [])))
        await model.load()
        guard case .empty = model.phase else {
            Issue.record("expected empty, got \(model.phase)")
            return
        }
    }

    @Test("offline or a refused load fails with the API's problem; a failed reload keeps the bills")
    func failures() async throws {
        let service = FakeBillService()
        await service.fail(with: AppProblem(code: "CONNECTION_LOST"))
        let model = model(service)
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failed")
            return
        }
        #expect(problem.code == "CONNECTION_LOST")
        await service.fail(with: nil)
        await model.load()
        #expect(model.phase.value?.count == 6)
        await service.fail(with: AppProblem(code: "INTERNAL_ERROR"))
        await model.load()
        #expect(model.phase.value?.count == 6)
    }

    @Test("an error that is not an AppProblem fails with the generic problem")
    func otherError() async {
        let model = BillsModel(service: ThrowingBillService(), today: { BillFixtures.today })
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failed")
            return
        }
        #expect(problem == AppProblem())
    }
}

private struct ThrowingBillService: BillService {
    struct Boom: Error {}
    func bills() async throws -> BillOverview { throw Boom() }
}
