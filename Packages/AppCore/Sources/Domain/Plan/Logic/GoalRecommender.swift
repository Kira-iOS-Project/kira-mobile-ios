import Foundation

/**
 Rekomendasi when a plan falls short, as the site and the boards make them:
 - Naikkan Investasi: the deposit grows by Rp200.000 while the result is at most 20% of the
   target, then by Rp50.000, until it reaches it;
 - Pilih Return Lebih Tinggi: the return grows a point at a time, up to 15% under 6 years, 20%
   for 6 to 10 and 30% beyond; offered only when it gets there below that cap;
 - Perpanjang Waktu: a year at a time with the target inflated along the path (the goal's rate
   for years 1 to 5, 3% for 6 to 10, 1% after); for a goal counted in months (Barang), a month at
   a time with the target at (1 + rate)^(months ÷ 12).
 The steps compare unrounded amounts, as the site's loops do.
 */
package enum GoalRecommender {
    /** How far Perpanjang Waktu looks, in months: a plan that never gets there offers none. */
    static let longestExtension = 1_200

    /**
     For `deposit` a month over `years` from `present` at `annualReturn`, toward `cost` today
     inflated at `inflation`; none when the plan fits. `offersYears` is false where the board has
     no Perpanjang Waktu (Pensiun, whose date is an age).
     */
    package static func recommendations(
        cost: Double, inflation: Double, years: Int, present: Int, deposit: Int, annualReturn: Double,
        offersYears: Bool = true
    ) -> [GoalRecommendation] {
        let plan = SavingsPlan(present: present, deposit: deposit, annualReturn: annualReturn)
        let target = GoalMath.inflatedAmount(cost, rate: inflation, years: Double(years))
        var found = plan.common(target: target, months: years * 12)
        guard !found.isEmpty, offersYears else { return found }
        var year = years
        var extended: Double
        repeat {
            year += 1
            guard year * 12 <= years * 12 + longestExtension else { return found }
            extended = cost * pathFactor(years: year, rate: inflation)
        } while plan.result(months: year * 12) < extended
        found.append(.extendYears(to: year, target: Rupiah.rounded(extended)))
        return found
    }

    /** The inflation of `years` along the Perpanjang Waktu path, from year 1. */
    static func pathFactor(years: Int, rate: Double) -> Double {
        (0..<years).reduce(1) { factor, year in factor * (1 + yearlyInflation(year: year + 1, rate: rate)) }
    }

    /** For a goal counted in `months` (Barang): its Perpanjang Waktu adds months. */
    package static func recommendations(
        cost: Double, inflation: Double, months: Int, present: Int, deposit: Int, annualReturn: Double
    ) -> [GoalRecommendation] {
        let plan = SavingsPlan(present: present, deposit: deposit, annualReturn: annualReturn)
        let target = { (months: Int) in GoalMath.inflatedAmount(cost, rate: inflation, years: Double(months) / 12) }
        var found = plan.common(target: target(months), months: months)
        guard !found.isEmpty else { return found }
        if let longer = plan.months(from: months, reaching: target) { found.append(.extendMonths(to: longer)) }
        return found
    }

    /** The inflation of `year` on the Perpanjang Waktu path. */
    static func yearlyInflation(year: Int, rate: Double) -> Double {
        if year <= 5 { return rate }
        return year <= 10 ? 0.03 : 0.01
    }

    /** The highest return the site suggests for a horizon of `years`, in percent. */
    static func returnCap(years: Double) -> Int {
        if years > 10 { return 30 }
        return years >= 6 ? 20 : 15
    }
}

/** A plan of a monthly deposit the recommendations vary. */
struct SavingsPlan {
    let present: Int
    let deposit: Int
    let annualReturn: Double

    /** The result over `months`, with another `deposit` or return in percent. */
    func result(months: Int, deposit: Double? = nil, percent: Int? = nil) -> Double {
        let rate = percent.map { Double($0) / 100 } ?? annualReturn
        return GoalMath.futureValue(
            rate: rate / 12, periods: months, payment: deposit ?? Double(self.deposit), present: Double(present))
    }

    /** Naikkan Investasi and Pilih Return Lebih Tinggi; none when the plan fits in whole rupiah. */
    func common(target: Double, months: Int) -> [GoalRecommendation] {
        let result = result(months: months)
        guard Rupiah.rounded(result) < Rupiah.rounded(target) else { return [] }
        var deposit = Double(self.deposit)
        var reached = result
        while reached < target {
            deposit += reached > target * 0.2 ? 50_000 : 200_000
            reached = self.result(months: months, deposit: deposit)
        }
        var found: [GoalRecommendation] = [.raiseDeposit(to: Rupiah.rounded(deposit))]
        let cap = GoalRecommender.returnCap(years: Double(months) / 12)
        /** The site reads the typed return as a whole percent (`parseInt`). */
        var percent = Int((annualReturn * 100 + 1e-9).rounded(.down))
        reached = result
        while reached < target, percent < cap {
            percent += 1
            reached = self.result(months: months, percent: percent)
        }
        if percent < cap { found.append(.raiseReturn(to: Double(percent) / 100)) }
        return found
    }

    /** The first month count from `start` at which the plan reaches `target(months)`. */
    func months(from start: Int, reaching target: (Int) -> Double) -> Int? {
        var months = start
        while result(months: months) < target(months) {
            months += 1
            guard months <= start + GoalRecommender.longestExtension else { return nil }
        }
        return months
    }
}
