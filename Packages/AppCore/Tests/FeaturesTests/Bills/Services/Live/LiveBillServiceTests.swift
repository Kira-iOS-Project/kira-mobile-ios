import APIClient
import Domain
import Testing

@testable import Features

@Suite("LiveBillService")
struct LiveBillServiceTests {
    @Test("reads the groups, the totals and each bill's schedule, debt and payment")
    func readsBills() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/bills": ok(billsJSON)])

        let overview = try await LiveBillService(api: api).bills()

        #expect(overview.count == 2 && overview.monthlyTotal == 560_000)
        #expect(overview.sections.map(\.group) == [.nextSevenDays, .later])
        let instalment = try #require(overview.sections.first?.bills.first)
        #expect(instalment.kind == .instalment && instalment.debtId == "debt-1")
        #expect(instalment.category == "paylater_instalment" && instalment.remainingInstalments == 4)
        #expect(instalment.nextDueOn == CalendarDay(year: 2026, month: 10, day: 20) && instalment.dueDay == 20)
        let yearly = try #require(overview.sections.last?.bills.first)
        #expect(yearly.repeats == .yearly && yearly.isEstimate && yearly.paidThisPeriod)
        #expect(yearly.dueOn == CalendarDay(year: 2026, month: 3, day: 1))
        #expect(await transport.routes == ["GET /api/bills"])
    }
}

private let billsJSON = """
    {"count":2,"monthlyTotal":560000,"sections":[{"group":"next7Days","bills":[\(instalmentJSON)]},\
    {"group":"later","bills":[\(yearlyJSON)]}]}
    """

private let instalmentJSON = """
    {"id":"b1","name":"Paylater A","kind":"instalment","category":"paylater_instalment","amount":210000,\
    "isEstimate":false,"repeats":"monthly","dueOn":"2026-06-20","dueDay":20,"nextDueOn":"2026-10-20",\
    "daysUntil":5,"debtId":"debt-1","remainingInstalments":4,"paidThisPeriod":false,"lastPaidOn":null,\
    "createdAt":"2026-01-01T00:00:00.000Z"}
    """

private let yearlyJSON = """
    {"id":"b2","name":"PBB","kind":"bill","category":"bills","amount":350000,"isEstimate":true,\
    "repeats":"yearly","dueOn":"2026-03-01","dueDay":1,"nextDueOn":"2027-03-01","daysUntil":134,\
    "debtId":null,"remainingInstalments":null,"paidThisPeriod":true,"lastPaidOn":"2026-03-01",\
    "createdAt":"2026-01-01T00:00:00.000Z"}
    """
