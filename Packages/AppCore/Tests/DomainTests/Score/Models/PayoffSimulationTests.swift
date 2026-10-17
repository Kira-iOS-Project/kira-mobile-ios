import Testing

@testable import Domain

@Suite("PayoffComparison")
struct PayoffSimulationTests {
    private func comparison(saved: Int?, later: Int?) -> PayoffComparison {
        PayoffComparison(otherMethod: .snowball, interestSaved: saved, firstPayoffMonthsLater: later)
    }

    @Test(
        "the interest is saved, cost or the same, unsigned, or unknown without a known rate",
        arguments: [
            (1_200 as Int?, PayoffComparison.InterestOutcome.saves(1_200)), (-800, .costs(800)), (0, .same),
            (nil, .unknown),
        ])
    func interest(saved: Int?, outcome: PayoffComparison.InterestOutcome) {
        #expect(comparison(saved: saved, later: nil).interest == outcome)
    }

    @Test(
        "the first payoff is sooner when the other method's comes later, and the reverse",
        arguments: [
            (2 as Int?, PayoffComparison.FirstPayoffOutcome.sooner(2)), (-1, .later(1)), (0, .same), (nil, .unknown),
        ])
    func firstPayoff(later: Int?, outcome: PayoffComparison.FirstPayoffOutcome) {
        #expect(comparison(saved: nil, later: later).firstPayoff == outcome)
    }
}
