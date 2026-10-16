import APIClient
import Domain
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
        #expect(simulation.maxExtraPayment == 1_840_000 && simulation.monthlyBudget == 700_000)
        #expect(simulation.hasUnknownRate && simulation.totalInterest == 6_400)
        #expect(simulation.allPaidMonths == 2 && simulation.allPaidMonth == "2026-11")
        #expect(
            simulation.accounts == [
                PayoffAccount(
                    id: "a-1", kind: .paylater, name: "Paylater A", remaining: 420_000, monthlyInstalment: 210_000,
                    annualInterestRate: 24, position: 1, months: 2, payoffMonth: "2026-11", interest: 6_400)
            ])
        #expect(
            simulation.productive == [
                ProductiveDebt(
                    id: "p-1", kind: .vehicle, name: "Cicilan Motor", remaining: 13_000_000, monthlyInstalment: 850_000)
            ])
        #expect(
            simulation.comparison
                == PayoffComparison(otherMethod: .snowball, interestSaved: 1_200, firstPayoffMonthsLater: nil))
    }

    @Test("a payoff problem reaches the screen with its code")
    func problemCode() async {
        let (api, _) = KiraAPI.routed(["POST /api/payoff/simulate": problem("PAYOFF_EXTRA_TOO_HIGH")])
        await #expect(throws: AppProblem.self) {
            try await LivePayoffService(api: api).simulate(method: .snowball, extraPayment: 9_000_000)
        }
    }
}
