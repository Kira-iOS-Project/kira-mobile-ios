/**
 Dari Mana Hasilnya? (every Hasil Simulasi board): how much of the result is pokok and how much is
 imbal hasil, as the bar's proportion and as whole percents that add up to 100.
 */
package struct GoalShares: Equatable, Sendable {
    /** The pokok's part of the bar, 0 to 1. */
    package let principalShare: Double
    /** "Pokok · 18%". */
    package let principalPercent: Int
    /** "Imbal Hasil · 82%", so the two always make 100. */
    package let growthPercent: Int

    /** The shares of `principal` and `growth`; a result with neither is all pokok. */
    package init(principal: Int, growth: Int) {
        let total = principal + max(growth, 0)
        principalShare = total > 0 ? Double(principal) / Double(total) : 1
        principalPercent = Int((principalShare * 100).rounded())
        growthPercent = 100 - principalPercent
    }
}
