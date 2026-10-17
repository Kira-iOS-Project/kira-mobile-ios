import Testing

@testable import Domain

@Suite("GoalRecommender")
struct GoalRecommenderTests {
    @Test("Menikah, Hampir Cocok: Rp7.000.000, 11%, and 3 years with the target at Rp202.584.375")
    func wedding() {
        let found = GoalRecommender.recommendations(
            cost: 175_000_000, inflation: 0.05, years: 2, present: 15_000_000, deposit: 6_500_000, annualReturn: 0.05)
        #expect(found == [.raiseDeposit(to: 7_000_000), .raiseReturn(to: 0.11), .extendYears(to: 3, target: 202_584_375)])
        let plan = GoalMath.project(
            target: GoalMath.inflatedAmount(175_000_000, rate: 0.05, years: 2), present: 15_000_000, deposit: 6_500_000,
            annualReturn: 0.05, months: 24)
        #expect(plan.target == 192_937_500 && plan.result == 180_964_722 && plan.fit == .nearlyFits)
    }

    @Test("Pensiun offers no Perpanjang Waktu: Rp2.950.000 and 12%")
    func retirement() {
        let found = GoalRecommender.recommendations(
            cost: 72_000_000 / 0.04, inflation: 0.04, years: 27, present: 25_000_000, deposit: 2_000_000,
            annualReturn: 0.10, offersYears: false)
        #expect(found == [.raiseDeposit(to: 2_950_000), .raiseReturn(to: 0.12)])
    }

    @Test("a plan that fits gets none")
    func fits() {
        #expect(
            GoalRecommender.recommendations(
                cost: 90_000_000, inflation: 0.05, years: 5, present: 10_000_000, deposit: 1_500_000, annualReturn: 0.06)
                .isEmpty)
        #expect(
            GoalRecommender.recommendations(
                cost: 15_000_000, inflation: 0.05, months: 12, present: 2_000_000, deposit: 1_150_000, annualReturn: 0.05)
                .isEmpty)
    }

    @Test("no return is offered when even the cap falls short; no years when the plan never gets there")
    func unreachable() {
        let found = GoalRecommender.recommendations(
            cost: 1_000_000_000, inflation: 0.05, years: 8, present: 0, deposit: 0, annualReturn: 0)
        #expect(found.count == 1)
        guard case .raiseDeposit = found.first else { return #expect(Bool(false)) }
    }

    @Test("Perpanjang Waktu past year 5 inflates at 3%, past 10 at 1%")
    func path() {
        #expect(GoalRecommender.yearlyInflation(year: 5, rate: 0.05) == 0.05)
        #expect(GoalRecommender.yearlyInflation(year: 6, rate: 0.05) == 0.03)
        #expect(GoalRecommender.yearlyInflation(year: 11, rate: 0.05) == 0.01)
        let factor = GoalRecommender.pathFactor(years: 12, rate: 0.05)
        #expect(abs(factor - 1.276_281_562_5 * 1.159_274_074_3 * 1.0201) < 1e-9)
        let found = GoalRecommender.recommendations(
            cost: 100_000_000, inflation: 0.05, years: 10, present: 0, deposit: 600_000, annualReturn: 0.06)
        guard case .extendYears(let years, _) = found.last else { return #expect(Bool(false)) }
        #expect(years > 10)
    }

    @Test("return caps: 15% under 6 years, 20% to 10, 30% beyond")
    func caps() {
        #expect(GoalRecommender.returnCap(years: 5.9) == 15)
        #expect(GoalRecommender.returnCap(years: 6) == 20)
        #expect(GoalRecommender.returnCap(years: 10) == 20)
        #expect(GoalRecommender.returnCap(years: 10.5) == 30)
    }

    @Test("Barang counts months: a month at a time, the target inflated by months ÷ 12; none when out of reach")
    func goods() {
        let found = GoalRecommender.recommendations(
            cost: 15_000_000, inflation: 0.05, months: 12, present: 2_000_000, deposit: 1_000_000, annualReturn: 0.05)
        guard case .extendMonths(let months) = found.last else { return #expect(Bool(false)) }
        #expect(months == 13 || months == 14)
        #expect(found.first == .raiseDeposit(to: 1_150_000))
        let never = GoalRecommender.recommendations(
            cost: 15_000_000, inflation: 0.05, months: 12, present: 0, deposit: 0, annualReturn: 0)
        #expect(never.count == 1)
    }
}
