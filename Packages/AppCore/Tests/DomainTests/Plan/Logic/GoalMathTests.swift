import Testing

@testable import Domain

/** The site's FV, targets and classes, pinned to the HasilTujuan boards (QA-R's fixtures). */
@Suite("GoalMath")
struct GoalMathTests {
    @Test("Lainnya: Rp1.000.000 a month at 5% for 24 months, no inflation, is Cocok")
    func other() {
        let plan = GoalMath.project(target: 25_000_000, present: 0, deposit: 1_000_000, annualReturn: 0.05, months: 24)
        #expect(plan.target == 25_000_000 && plan.result == 25_290_862)
        #expect(plan.principal == 24_000_000 && plan.growth == 1_290_862 && plan.shortfall == 0)
        #expect(plan.fit == .fits && plan.share > 1)
    }

    @Test("Kendaraan and Barang inflate their DP; Barang by months ÷ 12")
    func vehicleAndGoods() {
        let vehicle = GoalMath.inflatedAmount(30_000_000 * 0.25, rate: 0.05, years: 2)
        let car = GoalMath.project(target: vehicle, present: 2_000_000, deposit: 300_000, annualReturn: 0.05, months: 24)
        #expect(car.target == 8_268_750 && car.result == 9_797_141 && car.principal == 9_200_000 && car.fit == .fits)
        let goods = GoalMath.inflatedAmount(15_000_000, rate: 0.05, years: 12.0 / 12)
        let laptop = GoalMath.project(target: goods, present: 2_000_000, deposit: 1_150_000, annualReturn: 0.05, months: 12)
        #expect(laptop.target == 15_750_000 && laptop.result == 16_281_844 && laptop.growth == 481_844)
        #expect(GoalMath.inflated(90_000_000, rate: 0.05, years: 5) == 114_865_341)
    }

    @Test("Pensiun: Rp6.000.000 a month, 27 years at 4%, ÷ 4% is Belum Cocok at 71%")
    func retirement() {
        let goal = GoalMath.retirementTarget(monthlyExpense: 6_000_000, inflation: 0.04, years: 27)
        #expect(goal.annualExpense == 207_602_537 && goal.target == 5_190_063_437)
        let plan = GoalMath.project(
            target: Double(goal.target), present: 25_000_000, deposit: 2_000_000, annualReturn: 0.10, months: 324)
        #expect(plan.result == 3_686_687_857 && plan.principal == 673_000_000 && plan.growth == 3_013_687_857)
        #expect(plan.fit == .short && Int(plan.share * 100) == 71)
    }

    @Test("FV without a return adds up; a deposit at the end grows a period less; yearly plans compound yearly")
    func futureValue() {
        #expect(GoalMath.futureValue(rate: 0, periods: 10, payment: 100, present: 50) == 1_050)
        let start = GoalMath.futureValue(rate: 0.1, periods: 1, payment: 100, present: 0)
        let end = GoalMath.futureValue(rate: 0.1, periods: 1, payment: 100, present: 0, timing: .end)
        #expect(Rupiah.rounded(start) == 110 && Rupiah.rounded(end) == 100)
        let yearly = GoalMath.project(
            target: 0, present: 20_000_000, deposit: 24_000_000, annualReturn: 0.08, months: 228, period: .year)
        #expect(yearly.result == 1_160_601_164 && yearly.principal == 476_000_000 && yearly.share == 1)
    }

    @Test("Hampir Cocok from 90%, Belum below; whole rupiah decide, a half to even")
    func fit() {
        #expect(GoalFit(result: 90, target: 100) == .nearlyFits)
        #expect(GoalFit(result: 89, target: 100) == .short)
        #expect(GoalFit(result: 100, target: 100) == .fits)
        #expect(Rupiah.rounded(25_398_612.5) == 25_398_612 && Rupiah.rounded(2.5) == 2 && Rupiah.rounded(3.5) == 4)
        #expect(GoalProjection(target: 99.6, result: 99.6, principal: 0).fit == .fits)
    }

    @Test("asset classes by horizon: under a year, up to 5, up to 10, beyond")
    func classes() {
        #expect(GoalMath.assetClasses(years: 0.5) == [.moneyMarket, .shortTermDeposit])
        #expect(GoalMath.assetClasses(years: 1) == [.fixedIncomeFund, .governmentBond])
        #expect(GoalMath.assetClasses(years: 5) == [.fixedIncomeFund, .governmentBond])
        #expect(GoalMath.assetClasses(years: 10) == [.stocks, .indexFund, .balancedFund, .etf, .gold])
        #expect(GoalMath.assetClasses(years: 19) == [.stocks, .crypto, .indexFund, .etf])
        #expect(GoalAssetClass.allCases.count == 10)
    }
}
