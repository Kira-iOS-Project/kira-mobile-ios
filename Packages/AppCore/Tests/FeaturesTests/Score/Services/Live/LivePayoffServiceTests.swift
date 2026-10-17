import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LivePayoffService")
struct LivePayoffServiceTests {
    private let planJSON = #"""
        {"method":"avalanche","extraPayment":200000,"maxExtraPayment":1840000,"monthlyBudget":700000,\#
        "hasUnknownRate":true,\#
        "accounts":[{"id":"a-1","kind":"paylater","name":"Paylater A","remaining":420000,\#
        "monthlyInstalment":210000,"annualInterestRate":24,"dueDay":5,"position":1,"months":2,\#
        "payoffMonth":"2026-11","interest":6400}],\#
        "productive":[{"id":"p-1","kind":"vehicle","name":"Cicilan Motor","remaining":13000000,\#
        "monthlyInstalment":850000}],\#
        "totalInterest":6400,"allPaidMonths":2,"allPaidMonth":"2026-11",\#
        "comparison":{"otherMethod":"snowball","interestSaved":1200,"firstPayoffMonthsLater":null}}
        """#

    @Test("POST /payoff/simulate sends the method and the extra payment and becomes the Domain's simulation")
    func simulate() async throws {
        let (api, transport) = KiraAPI.routed(["POST /api/payoff/simulate": ok(planJSON)])
        let simulation = try await LivePayoffService(api: api).simulate(method: .avalanche, extraPayment: 200_000)
        #expect(await transport.sent.first?.json == ["method": .string("avalanche"), "extraPayment": .number(200_000)])
        #expect(simulation.method == .avalanche && simulation.extraPayment == 200_000)
        #expect(simulation.maxExtraPayment == 1_840_000)
        #expect(simulation.hasUnknownRate)
        #expect(simulation.allPaidMonth == "2026-11")
        #expect(
            simulation.accounts == [
                PayoffAccount(
                    id: "a-1", kind: .paylater, name: "Paylater A", remaining: 420_000, monthlyInstalment: 210_000,
                    position: 1, payoffMonth: "2026-11")
            ])
        #expect(
            simulation.productive == [
                ProductiveDebt(id: "p-1", kind: .vehicle, name: "Cicilan Motor", remaining: 13_000_000)
            ])
        #expect(
            simulation.comparison
                == PayoffComparison(interestSaved: 1_200, firstPayoffMonthsLater: nil))
    }

    @Test("the API's payoff days become calendar days, for the accounts, the productive debts and the last payoff")
    func days() async throws {
        let json =
            planJSON
            .replacingOccurrences(of: #""interest":6400}"#, with: #""interest":6400,"payoffDate":"2026-11-05"}"#)
            .replacingOccurrences(
                of: #""monthlyInstalment":850000}"#,
                with: #""monthlyInstalment":850000,"payoffMonth":"2027-12","payoffDate":"2027-12-28"}"#
            )
            .replacingOccurrences(
                of: #""allPaidMonth":"2026-11","#, with: #""allPaidMonth":"2026-11","allPaidDate":"2026-11-05","#)
        let (api, _) = KiraAPI.routed(["POST /api/payoff/simulate": ok(json)])
        let simulation = try await LivePayoffService(api: api).simulate(method: .avalanche, extraPayment: 200_000)
        #expect(simulation.accounts.first?.payoffDate == CalendarDay(year: 2026, month: 11, day: 5))
        #expect(simulation.productive.first?.payoffDate == CalendarDay(year: 2027, month: 12, day: 28))
        #expect(simulation.productive.first?.payoffMonth == "2027-12")
        #expect(simulation.allPaidDate == CalendarDay(year: 2026, month: 11, day: 5))
    }

    @Test("a payoff problem reaches the screen with its code")
    func problemCode() async {
        let (api, _) = KiraAPI.routed(["POST /api/payoff/simulate": problem("PAYOFF_EXTRA_TOO_HIGH")])
        await #expect(throws: AppProblem.self) {
            try await LivePayoffService(api: api).simulate(method: .snowball, extraPayment: 9_000_000)
        }
    }
}
