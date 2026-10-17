import Testing

@testable import Domain

/** Simulasi KPR and DP Rumah on the HasilTujuanDP board. */
@Suite("Mortgage and HouseDownPayment")
struct MortgageTests {
    private let mortgage = Mortgage(
        price: 450_000_000, loan: 360_000_000, tenorYears: 20, fixRate: 0.065, floatRate: 0.11, fixYears: 3,
        income: 12_000_000, njopTkp: 60_000_000)

    @Test("DP 20% of Rp450.000.000 in 5 years at 5% is Cocok")
    func downPayment() {
        let house = HouseDownPayment(
            price: 450_000_000, downPaymentRate: 0.20, inflation: 0.05, years: 5, present: 10_000_000,
            deposit: 1_500_000, annualReturn: 0.06)
        #expect(house.downPaymentNow == 90_000_000 && house.loanNow == 360_000_000 && house.target == 114_865_341)
        let plan = house.projection
        #expect(plan.result == 118_666_823 && plan.principal == 100_000_000 && plan.growth == 18_666_823)
        #expect(plan.fit == .fits && house.recommendations.isEmpty)
    }

    @Test("fixed 6,5% for 3 years, then 11% on the rest: Sehat at 29,9%")
    func instalments() {
        #expect(mortgage.fixInstalment == 2_684_063 && mortgage.floatInstalment == 3_591_610)
        #expect(mortgage.remainingAfterFix == 330_907_835 && mortgage.totalInterest == 469_314_635)
        #expect(Int(mortgage.interestShare * 1_000) == 1_303)
        #expect(Int(mortgage.highestShare * 1_000) == 299 && mortgage.health == .healthy)
    }

    @Test("Biaya Lain: BPHTB, AJB, Balik Nama, Notaris, Provisi, Appraisal, Administrasi")
    func costs() {
        let costs = mortgage.costs
        #expect(costs.bphtb == 19_500_000 && costs.deed == 4_500_000 && costs.transfer == 4_500_000)
        #expect(costs.notary == 6_750_000 && costs.provision == 3_600_000)
        #expect(costs.appraisal == 1_000_000 && costs.admin == 1_000_000 && costs.total == 40_850_000)
        #expect(BuyingCosts(price: 90_000_000, loan: 0, njopTkp: 100_000_000).bphtb == 0)
        #expect(BuyingCosts(price: 90_000_000, loan: 0, njopTkp: 0).notary == 2_250_000)
        #expect(BuyingCosts(price: 2_000_000_000, loan: 0, njopTkp: 0).notary == 20_000_000)
    }

    @Test("no fixed period floats from the start; a fixed period over the whole tenor never floats")
    func periods() {
        let floating = Mortgage(
            price: 0, loan: 120_000_000, tenorYears: 10, fixRate: 0, floatRate: 0.12, fixYears: 0, income: 1,
            njopTkp: 0)
        #expect(floating.fixInstalment == 0 && floating.remainingAfterFix == 120_000_000)
        #expect(floating.floatInstalment == Rupiah.rounded(Mortgage.annuity(120_000_000, rate: 0.01, months: 120)))
        let fixed = Mortgage(
            price: 0, loan: 120_000_000, tenorYears: 10, fixRate: 0, floatRate: 0.12, fixYears: 12, income: 1_000_000,
            njopTkp: 0)
        #expect(fixed.fixInstalment == 1_000_000 && fixed.floatInstalment == 0 && fixed.totalInterest == 0)
    }

    @Test("health: under 15%, up to 30%, up to 50%, above")
    func health() {
        #expect(MortgageHealth(share: 0.149) == .veryHealthy)
        #expect(MortgageHealth(share: 0.30) == .healthy)
        #expect(MortgageHealth(share: 0.50) == .unhealthy)
        #expect(MortgageHealth(share: 0.51) == .dangerous)
    }
}
