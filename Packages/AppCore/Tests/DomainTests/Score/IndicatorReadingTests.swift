import Foundation
import Testing

@testable import Domain

@Suite("IndicatorReading")
struct IndicatorReadingTests {
    private func fund(_ ratio: String, essential: Decimal = 4_200_000, target: Int = 6) -> IndicatorMeasure {
        .emergencyFund(
            EmergencyFundMeasure(
                ratio: Decimal(string: ratio) ?? 0, liquid: 4_800_000, essential: essential, targetMultiple: target,
                targetAmount: 25_200_000))
    }

    private func ratio(_ percent: Int, part: Decimal = 600_000, whole: Decimal = 7_500_000) -> RatioMeasure {
        RatioMeasure(percent: percent, part: part, whole: whole)
    }

    @Test("places the emergency fund in months, or as reached, short of a month, or unanswered")
    func emergencyFund() {
        #expect(fund("1.1").position == .monthsCovered(1))
        #expect(fund("2.6").position == .monthsCovered(3))
        #expect(fund("0.4").position == .belowGoal)
        #expect(fund("6.0").position == .reachedGoal)
        #expect(fund("0", essential: 0).position == .missingBase)
        #expect(fund("1.1").rowTarget == .multiple(6))
        #expect(fund("9.0", target: 9).rowTarget == nil)
    }

    @Test("places savings against 10% and 20% of income")
    func savings() {
        #expect(IndicatorMeasure.savingsRatio(ratio(8)).position == .belowGoal)
        #expect(IndicatorMeasure.savingsRatio(ratio(12)).position == .betweenGoals)
        #expect(IndicatorMeasure.savingsRatio(ratio(20)).position == .reachedGoal)
        #expect(IndicatorMeasure.savingsRatio(ratio(0, whole: 0)).position == .missingBase)
        #expect(IndicatorMeasure.savingsRatio(ratio(8)).rowTarget == .minimumPercent(10))
        #expect(IndicatorMeasure.savingsRatio(ratio(12)).rowTarget == .targetPercent(20))
        #expect(IndicatorMeasure.savingsRatio(ratio(25)).rowTarget == nil)
    }

    @Test("places instalments under 30% of income and debt under 50% of assets")
    func limits() {
        #expect(IndicatorMeasure.instalmentRatio(ratio(30)).position == .withinLimit)
        #expect(IndicatorMeasure.instalmentRatio(ratio(31)).position == .overLimit)
        #expect(IndicatorMeasure.debtToAsset(ratio(50)).position == .withinLimit)
        #expect(IndicatorMeasure.debtToAsset(ratio(51)).position == .overLimit)
        #expect(IndicatorMeasure.debtToAsset(ratio(0, part: 0)).position == .nothingOwed)
        #expect(IndicatorMeasure.instalmentRatio(ratio(0, whole: 0)).position == .missingBase)
        #expect(IndicatorMeasure.instalmentRatio(ratio(18)).rowTarget == .limitPercent(30))
        #expect(IndicatorMeasure.debtToAsset(ratio(32)).rowTarget == .limitPercent(50))
        #expect(IndicatorMeasure.instalmentRatio(ratio(0, part: 0)).rowTarget == nil)
    }

    @Test("places consumer debt by platforms and payments, and protection by its covers")
    func rules() {
        let clear = IndicatorMeasure.consumerDebt(ConsumerDebtMeasure(platforms: 0, anyLate: false, anyOverdue: false))
        let onTime = ConsumerDebtMeasure(platforms: 2, anyLate: false, anyOverdue: false)
        let late = ConsumerDebtMeasure(platforms: 1, anyLate: true, anyOverdue: false)
        let overdue = ConsumerDebtMeasure(platforms: 1, anyLate: true, anyOverdue: true)
        #expect(clear.position == .nothingOwed)
        #expect(IndicatorMeasure.consumerDebt(onTime).position == .withinLimit)
        #expect(IndicatorMeasure.consumerDebt(late).position == .belowGoal)
        #expect(IndicatorMeasure.consumerDebt(overdue).position == .overLimit)
        #expect(overdue.payment == .overdue)
        #expect(clear.rowTarget == nil)
        let both = IndicatorMeasure.protection(ProtectionMeasure(health: true, income: true))
        #expect(both.position == .reachedGoal)
        #expect(IndicatorMeasure.protection(ProtectionMeasure(health: false, income: true)).position == .belowGoal)
        #expect(both.rowTarget == nil)
    }

    @Test("draws the bar against the target or the limit")
    func ribbon() {
        #expect(
            fund("1.1").ribbon
                == IndicatorRibbon(value: 4_800_000, target: 25_200_000, isLimit: false, isMonthly: false))
        #expect(
            IndicatorMeasure.savingsRatio(ratio(8)).ribbon
                == IndicatorRibbon(value: 600_000, target: 1_500_000, isLimit: false, isMonthly: true))
        #expect(
            IndicatorMeasure.instalmentRatio(ratio(18, part: 1_350_000)).ribbon
                == IndicatorRibbon(value: 1_350_000, target: 2_250_000, isLimit: true, isMonthly: true))
        #expect(
            IndicatorMeasure.debtToAsset(ratio(32, part: 14_310_000, whole: 44_700_000)).ribbon
                == IndicatorRibbon(value: 14_310_000, target: 22_350_000, isLimit: true, isMonthly: false))
        #expect(IndicatorMeasure.protection(ProtectionMeasure(health: true, income: false)).ribbon == nil)
        #expect(
            IndicatorMeasure.consumerDebt(ConsumerDebtMeasure(platforms: 1, anyLate: false, anyOverdue: false)).ribbon
                == nil)
    }
}
