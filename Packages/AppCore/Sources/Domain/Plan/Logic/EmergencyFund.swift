/**
 Kalkulator Dana Darurat (REN-03, REN-04): the fund is the month's essential spending times 6
 when single or 9 when married, 3 more per dependant, at most 15; saved over months without
 inflation, then split 50:50 between a bank account and a low-risk liquid instrument.
 */
package struct EmergencyFund: Equatable, Sendable {
    /** Pengeluaran Pokok per Bulan. */
    package let monthlyEssential: Int
    /** Sudah Menikah? */
    package let married: Bool
    /** Jumlah Tanggungan. */
    package let dependants: Int
    /** Terkumpul dalam … Bulan Lagi. */
    package let months: Int
    /** What is saved already (Tabungan saat ini). */
    package let present: Int
    /** The deposit each month. */
    package let deposit: Int
    /** The return a year, as a fraction (0.06). */
    package let annualReturn: Double

    /** A fund for `monthlyEssential` a month, saved over `months`. */
    package init(
        monthlyEssential: Int, married: Bool, dependants: Int, months: Int, present: Int, deposit: Int,
        annualReturn: Double
    ) {
        self.monthlyEssential = monthlyEssential
        self.married = married
        self.dependants = dependants
        self.months = months
        self.present = present
        self.deposit = deposit
        self.annualReturn = annualReturn
    }

    /** The most months of spending the fund covers. */
    package static let largestMultiplier = 15

    /** How many months of spending the fund covers. */
    package var multiplier: Int { min((married ? 9 : 6) + 3 * max(dependants, 0), Self.largestMultiplier) }

    /** Dana Darurat yang Kamu Butuhkan. */
    package var target: Int { monthlyEssential * multiplier }

    /** The plan against that target. */
    package var projection: GoalProjection {
        GoalMath.project(
            target: Double(target), present: present, deposit: deposit, annualReturn: annualReturn, months: months)
    }

    /** Kelas Aset untuk Dana Darurat, the site's list: easy to cash and stable. */
    package static let assetClasses: [GoalAssetClass] = [
        .shortTermDeposit, .gold, .usDollar, .moneyMarket, .fixedIncomeFund,
    ]

    /** Each half of Tempat Menyimpannya: Tabungan Bank and Instrumen Likuid Berisiko Rendah. */
    package var half: Int { Rupiah.rounded(Double(target) / 2) }

    /** Naikkan Investasi and Perpanjang Waktu (in months) when the plan falls short. */
    package var recommendations: [GoalRecommendation] {
        let plan = SavingsPlan(present: present, deposit: deposit, annualReturn: annualReturn)
        let goal = Double(target)
        guard Rupiah.rounded(plan.result(months: months)) < target else { return [] }
        var found: [GoalRecommendation] = []
        if let raised = plan.common(target: goal, months: months).first { found.append(raised) }
        if let longer = plan.months(from: months, reaching: { _ in goal }) { found.append(.extendMonths(to: longer)) }
        return found
    }
}
