import Testing

@testable import Domain

@Suite("IndicatorMeasure reading")
struct IndicatorMeasureReadingTests {
    @Test("divides a ratio's part by its whole, and leaves the rule-based indicators out")
    func division() {
        let fund = IndicatorMeasure.emergencyFund(
            ratio: 1.1, liquid: 4_800_000, essential: 4_200_000, targetMultiple: 6, targetAmount: 25_200_000)
        #expect(fund.division == Division(part: 4_800_000, whole: 4_200_000))
        #expect(abs((fund.division?.quotient ?? 0) - 1.142_857) < 0.000_001)
        #expect(
            IndicatorMeasure.savingsRatio(percent: 8, monthlySavings: 1, income: 2).division
                == Division(part: 1, whole: 2))
        #expect(
            IndicatorMeasure.instalmentRatio(percent: 18, monthlyInstalments: 3, income: 4).division
                == Division(part: 3, whole: 4))
        #expect(
            IndicatorMeasure.debtToAsset(percent: 32, totalDebt: 5, totalAssets: 6).division
                == Division(part: 5, whole: 6))
        #expect(IndicatorMeasure.consumerDebt(platforms: 1, anyLate: false, anyOverdue: false).division == nil)
        #expect(IndicatorMeasure.protectionCover(health: true, income: true).division == nil)
        #expect(Division(part: 1, whole: 0).quotient == 0)
        #expect(Division(part: 0, whole: 7_500_000).share(15) == 1_125_000)
        #expect(Division(part: 0, whole: 5).share(30) == 2)
    }

    @Test("names the worst payment of consumer debt")
    func payment() {
        #expect(IndicatorMeasure.consumerDebt(platforms: 2, anyLate: false, anyOverdue: false).payment == .onTime)
        #expect(IndicatorMeasure.consumerDebt(platforms: 2, anyLate: true, anyOverdue: false).payment == .late)
        #expect(IndicatorMeasure.consumerDebt(platforms: 2, anyLate: true, anyOverdue: true).payment == .overdue)
        #expect(IndicatorMeasure.protectionCover(health: false, income: false).payment == .onTime)
    }

    @Test(
        "counts the active covers",
        arguments: [
            (true, true, Coverage.both, 2), (true, false, .healthOnly, 1), (false, true, .incomeOnly, 1),
            (false, false, .neither, 0),
        ])
    func protection(health: Bool, income: Bool, coverage: Coverage, count: Int) {
        let cover = IndicatorMeasure.protectionCover(health: health, income: income)
        #expect(cover.coverage == coverage)
        #expect(cover.coverage.activeCount == count)
    }

    @Test("has no cover outside protection")
    func noCover() {
        #expect(IndicatorMeasure.consumerDebt(platforms: 0, anyLate: false, anyOverdue: false).coverage == .neither)
    }
}
