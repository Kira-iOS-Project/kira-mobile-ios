import Domain
import Testing

@testable import APIClient

@Suite("FinanceAPI bills")
struct FinanceAPIBillsTests {
    @Test("listBills keeps the session's 401 and undocumented failures")
    func problems() async {
        await expectProblems([401]) { _ = try await $0.listBills() }
    }

    @Test("every group maps; a paid one-off without a next due day is left out, a dated one is kept")
    func groupsAndOneOff() async throws {
        let json = """
            {"count":0,"monthlyTotal":0,"sections":[\
            {"group":"next7Days","bills":[]},{"group":"thisMonth","bills":[]},\
            {"group":"nextMonth","bills":[\(bill(next: "null")),\(bill(next: #""2026-11-01""#))]},{"group":"later","bills":[]}]}
            """
        let (api, _) = KiraAPI.canned(json: json)
        let overview = try await api.listBills()
        #expect(overview.sections.map(\.group) == [.nextSevenDays, .thisMonth, .nextMonth, .later])
        #expect(overview.sections[2].bills.map(\.repeats) == [.once])
    }

    @Test("a bill with a date the app cannot read is refused")
    func invalidDate() async {
        let sections = #"[{"group":"later","bills":["# + bill(next: #""2026-13-40""#) + "]}]"
        let json = #"{"count":1,"monthlyTotal":1,"sections":"# + sections + "}"
        let (api, _) = KiraAPI.canned(json: json)
        await #expect(throws: AppProblem()) { _ = try await api.listBills() }
    }

    private func bill(next: String) -> String {
        """
        {"id":"b","name":"Pulsa","kind":"bill","category":"other_expense","amount":50000,"isEstimate":false,\
        "repeats":"once","dueOn":"2026-10-01","dueDay":1,"nextDueOn":\(next),"daysUntil":null,"debtId":null,\
        "remainingInstalments":null,"paidThisPeriod":true,"lastPaidOn":"2026-10-01",\
        "createdAt":"2026-01-01T00:00:00.000Z"}
        """
    }
}
