import Domain
import Foundation
import Testing

@testable import APIClient

@Suite("Finance API bill list")
struct FinanceBillListAPITests {
    @Test("maps ordinary bills and linked installments from the owner list")
    func lists() async throws {
        let json =
            #"{"items":[{"id":"bill-1","kind":"bill","name":"Internet Rumah","amount":350000,"category":"bills","nextDueDate":"2026-10-22","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":null,"linkedDebtName":null,"dueSoon":true,"paidThisPeriod":false},{"id":"debt-1","kind":"debtInstallment","name":"Paylater A","amount":105000,"category":"paylater_instalment","nextDueDate":"2026-10-24","repeatInterval":"monthly","installmentsTotal":6,"installmentsRemaining":2,"linkedDebtAccountId":"account-1","linkedDebtName":"Paylater A","dueSoon":true,"paidThisPeriod":true}]}"#
        let (api, transport) = KiraAPI.canned(json: json)

        let bills = try await api.getBills()

        #expect(bills.count == 2)
        #expect(bills[0].kind == .bill && bills[0].amount == 350_000)
        #expect(bills[0].nextDueDate == CalendarDay(year: 2026, month: 10, day: 22))
        #expect(bills[0].isDueSoon && !bills[0].isPaidThisPeriod)
        #expect(bills[1].kind == .debtInstallment && bills[1].installmentsRemaining == 2)
        #expect(bills[1].linkedDebtAccountID == "account-1" && bills[1].isPaidThisPeriod)
        #expect(await transport.request?.path == "/api/bills")
    }

    @Test("preserves the documented authentication error and maps unknown statuses")
    func failures() async {
        await expectProblems([401]) { _ = try await $0.getBills() }
    }

    @Test("rejects a response with an invalid calendar date")
    func invalidDate() async {
        let json =
            #"{"items":[{"id":"bill-1","kind":"bill","name":"Internet","amount":1,"category":"bills","nextDueDate":"2026-02-30","repeatInterval":"monthly","installmentsTotal":null,"installmentsRemaining":null,"linkedDebtAccountId":null,"linkedDebtName":null,"dueSoon":false,"paidThisPeriod":false}]}"#
        let (api, _) = KiraAPI.canned(json: json)
        await #expect(throws: AppProblem()) { _ = try await api.getBills() }
    }
}
