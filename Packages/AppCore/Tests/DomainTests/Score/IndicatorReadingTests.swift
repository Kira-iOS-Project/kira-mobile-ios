import Testing

@testable import Domain

@Suite("IndicatorReading")
struct IndicatorReadingTests {
    private func fund(_ ratio: Double, essential: Int = 4_200_000, target: Int = 6) -> IndicatorMeasure {
        .emergencyFund(
            ratio: ratio, liquid: 4_800_000, essential: essential, targetMultiple: target, targetAmount: 25_200_000)
    }

    private func savings(_ percent: Int, income: Int = 7_500_000) -> IndicatorMeasure {
        .savingsRatio(percent: percent, monthlySavings: 600_000, income: income)
    }

    private func instalments(_ percent: Int, part: Int = 1_350_000, whole: Int = 7_500_000) -> IndicatorMeasure {
        .instalmentRatio(percent: percent, monthlyInstalments: part, income: whole)
    }

    private func debt(_ percent: Int, part: Int = 14_310_000) -> IndicatorMeasure {
        .debtToAsset(percent: percent, totalDebt: part, totalAssets: 44_700_000)
    }

    @Test("places the emergency fund in months, or as reached, short of a month, or unanswered")
    func emergencyFund() {
        #expect(fund(1.1).position == .monthsCovered(1))
        #expect(fund(2.6).position == .monthsCovered(3))
        #expect(fund(0.4).position == .belowGoal)
        #expect(fund(6).position == .reachedGoal)
        #expect(fund(0, essential: 0).position == .missingBase)
        #expect(fund(1.1).rowTarget == .multiple(6))
        #expect(fund(9, target: 9).rowTarget == nil)
    }

    @Test("places savings against 10% and 20% of income")
    func savingsRatio() {
        #expect(savings(8).position == .belowGoal)
        #expect(savings(12).position == .betweenGoals)
        #expect(savings(20).position == .reachedGoal)
        #expect(savings(0, income: 0).position == .missingBase)
        #expect(savings(8).rowTarget == .minimumPercent(10))
        #expect(savings(12).rowTarget == .targetPercent(20))
        #expect(savings(25).rowTarget == nil)
    }

    @Test("places instalments under 30% of income and debt under 50% of assets")
    func limits() {
        #expect(instalments(30).position == .withinLimit)
        #expect(instalments(31).position == .overLimit)
        #expect(debt(50).position == .withinLimit)
        #expect(debt(51).position == .overLimit)
        #expect(debt(0, part: 0).position == .nothingOwed)
        #expect(instalments(0, whole: 0).position == .missingBase)
        #expect(instalments(18).rowTarget == .limitPercent(30))
        #expect(debt(32).rowTarget == .limitPercent(50))
        #expect(instalments(0, part: 0).rowTarget == nil)
    }

    @Test("places consumer debt by platforms and payments, and protection by its covers")
    func rules() {
        let clear = IndicatorMeasure.consumerDebt(platforms: 0, anyLate: false, anyOverdue: false)
        #expect(clear.position == .nothingOwed)
        #expect(IndicatorMeasure.consumerDebt(platforms: 2, anyLate: false, anyOverdue: false).position == .withinLimit)
        #expect(IndicatorMeasure.consumerDebt(platforms: 1, anyLate: true, anyOverdue: false).position == .belowGoal)
        #expect(IndicatorMeasure.consumerDebt(platforms: 1, anyLate: true, anyOverdue: true).position == .overLimit)
        #expect(clear.rowTarget == nil)
        let both = IndicatorMeasure.protectionCover(health: true, income: true)
        #expect(both.position == .reachedGoal)
        #expect(IndicatorMeasure.protectionCover(health: false, income: true).position == .belowGoal)
        #expect(both.rowTarget == nil)
    }

    @Test("draws the bar against the target or the limit")
    func ribbon() {
        #expect(fund(1.1).ribbon == IndicatorRibbon(value: 4_800_000, target: 25_200_000, isLimit: false, isMonthly: false))
        #expect(savings(8).ribbon == IndicatorRibbon(value: 600_000, target: 1_500_000, isLimit: false, isMonthly: true))
        #expect(instalments(18).ribbon == IndicatorRibbon(value: 1_350_000, target: 2_250_000, isLimit: true, isMonthly: true))
        #expect(debt(32).ribbon == IndicatorRibbon(value: 14_310_000, target: 22_350_000, isLimit: true, isMonthly: false))
        #expect(IndicatorMeasure.protectionCover(health: true, income: false).ribbon == nil)
    }
}
