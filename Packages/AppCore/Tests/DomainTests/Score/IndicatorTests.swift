import Foundation
import Testing

@testable import Domain

@Suite("Indicator")
struct IndicatorTests {
    @Test("writes the emergency fund's exact ratio to two decimals and knows its target")
    func emergencyFund() {
        let fund = EmergencyFundMeasure(
            ratio: Decimal(string: "1.1") ?? 0, liquid: 4_800_000, essential: 4_200_000, targetMultiple: 6,
            targetAmount: 25_200_000)
        #expect(fund.exactRatio == Decimal(string: "1.14"))
        #expect(!fund.hasReachedTarget)
    }

    @Test("writes a ratio as a two-decimal fraction and works out a share of its whole")
    func ratio() {
        let ratio = RatioMeasure(percent: 18, part: 1_350_000, whole: 7_500_000)
        #expect(ratio.fraction == Decimal(string: "0.18"))
        #expect(ratio.share(15) == 1_125_000)
    }

    @Test("names the worst payment of consumer debt")
    func payment() {
        #expect(ConsumerDebtMeasure(platforms: 2, anyLate: false, anyOverdue: false).payment == .onTime)
        #expect(ConsumerDebtMeasure(platforms: 2, anyLate: true, anyOverdue: false).payment == .late)
    }

    @Test(
        "counts the active covers",
        arguments: [
            (true, true, ProtectionMeasure.Coverage.both, 2), (true, false, .healthOnly, 1),
            (false, true, .incomeOnly, 1), (false, false, .neither, 0),
        ])
    func protection(health: Bool, income: Bool, coverage: ProtectionMeasure.Coverage, count: Int) {
        let cover = ProtectionMeasure(health: health, income: income)
        #expect(cover.coverage == coverage)
        #expect(cover.activeCount == count)
    }

    @Test("keeps the engine's points and band")
    func members() {
        let indicator = Indicator(
            key: .protection, group: .protect, points: Score(50), band: .coping,
            measure: .protection(ProtectionMeasure(health: true, income: false)))
        #expect(indicator.points.value == 50)
        #expect(indicator.band == .coping)
        #expect(IndicatorGroup(rawValue: "save_group") == .save)
    }
}
