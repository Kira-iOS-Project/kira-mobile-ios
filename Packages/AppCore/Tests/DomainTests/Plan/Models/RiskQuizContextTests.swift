import Foundation
import Testing

@testable import Domain

@Suite("RiskQuizContext")
struct RiskQuizContextTests {
    @Test("the ladder notice shows while the fund is below its target: 1,1× of 6×")
    func ladder() throws {
        let board = RiskQuizContext(emergencyMultiple: 1.1, emergencyTarget: 6, monthlyIncome: 7_500_000)
        let ladder = try #require(board.ladder)
        #expect(ladder.multiple == 1.1 && ladder.target == 6)
        #expect(RiskQuizContext(emergencyMultiple: 6, emergencyTarget: 6, monthlyIncome: nil).ladder == nil)
        #expect(RiskQuizContext(emergencyMultiple: 1.1, emergencyTarget: nil, monthlyIncome: nil).ladder == nil)
        #expect(RiskQuizContext.unknown.ladder == nil)
    }

    @Test("read from the plan: the emergency-fund step's multiples and the prefill's income")
    func plan() {
        let plan = PlanOverview(
            ladder: [
                LadderStep(step: 1, key: .expensiveDebt, status: .current),
                LadderStep(
                    step: 2, key: .emergencyFund, status: .todo,
                    detail: LadderDetail(multiple: 1.1, targetMultiple: 6)),
            ],
            goals: [], prefill: PlanPrefill(monthlyIncome: 7_500_000))
        #expect(
            RiskQuizContext(plan: plan)
                == RiskQuizContext(emergencyMultiple: 1.1, emergencyTarget: 6, monthlyIncome: 7_500_000))
        let none = PlanOverview(ladder: [], goals: [], prefill: PlanPrefill())
        #expect(RiskQuizContext(plan: none) == .unknown)
    }

    @Test("the ranges come from the income, or the board's Rp7.500.000,00 while it is unknown")
    func ranges() {
        let income = RiskQuizContext(emergencyMultiple: nil, emergencyTarget: nil, monthlyIncome: 10_000_000)
        #expect(income.depositRanges.low == 500_000)
        #expect(RiskQuizContext.unknown.depositRanges == MonthlyDepositRanges(income: 7_500_000))
    }
}
