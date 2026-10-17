/**
 What a savings plan reaches against its goal (Hasil Simulasi, REN-04): the target, the plan's
 future value, how much of it is the money put in and how much the returns, and whether it fits.
 Mirrors the calculators of feliciaputritjiasaka.com, which the owner chose as the reference.
 */
package struct GoalProjection: Equatable, Sendable {
    /** The money the goal needs on its date, in whole rupiah. */
    package let target: Int
    /** What the savings grow to by then ("Hasil Investasi"). */
    package let result: Int
    /** The money put in: what is saved already plus every deposit ("Pokok"). */
    package let principal: Int
    /** `result` less `principal` ("Imbal Hasil"). */
    package let growth: Int
    /** How much is still missing ("Kurang"); 0 once the plan fits. */
    package let shortfall: Int
    /** `result` over `target` in whole rupiah; the bar shows it capped at 100%. */
    package let share: Double
    /** Cocok, Hampir Cocok or Belum Cocok. */
    package let fit: GoalFit

    /** The projection of a plan reaching `result` against `target`, with `principal` put in. */
    package init(target: Double, result: Double, principal: Double) {
        self.target = Rupiah.rounded(target)
        self.result = Rupiah.rounded(result)
        self.principal = Rupiah.rounded(principal)
        growth = Rupiah.rounded(result - principal)
        shortfall = max(self.target - self.result, 0)
        share = self.target > 0 ? Double(self.result) / Double(self.target) : 1
        fit = GoalFit(result: self.result, target: self.target)
    }
}

/** The three states of Hasil Simulasi, compared in whole rupiah as the boards do. */
package enum GoalFit: Equatable, Sendable {
    /** Cocok: the plan reaches the target. */
    case fits
    /** Hampir Cocok: at least 90% of it. */
    case nearlyFits
    /** Belum Cocok: below 90%. */
    case short

    /** The state of reaching `result` against `target`. */
    package init(result: Int, target: Int) {
        if result >= target {
            self = .fits
        } else if Double(result) >= Double(target) * 0.9 {
            self = .nearlyFits
        } else {
            self = .short
        }
    }
}

/** Whole rupiah from the engines' unrounded amounts. */
package enum Rupiah {
    /**
     `amount` to the nearest rupiah, a half to the even one: the boards' fixtures were computed so,
     and it differs from the site's `toFixed(0)` only on an exact half.
     */
    package static func rounded(_ amount: Double) -> Int {
        Int(amount.rounded(.toNearestOrEven))
    }
}
