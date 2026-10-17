/**
 The whole Pendidikan Anak plan: the stages chosen, what is saved already, a monthly deposit and a
 yearly return (none when the person does not invest yet), weighed against the parents' income.
 Its Naikkan Investasi follows the site: Rp300.000 more while the result is at most 20% of the
 target, then Rp100.000, up to a share of income (20% up to Rp3 juta, 30% up to Rp15 juta, 50% up
 to Rp50 juta, else 60%); still short there, the return rises a point at a time to the cap.
 */
package struct EducationPlan: Equatable, Sendable {
    package let childAge: Int
    /** The stages chosen, youngest first. */
    package let levels: [EducationLevel]
    package let inflation: Double
    /** Penghasilan Orang Tua per Bulan. */
    package let income: Int
    package let present: Int
    /** The monthly deposit; twelve go in at the start of each year. */
    package let deposit: Int
    /** The yearly return, nil for "Belum" (0%). */
    package let annualReturn: Double?

    /** A plan for a child now `childAge`. */
    package init(
        childAge: Int, levels: [EducationLevel], inflation: Double, income: Int, present: Int, deposit: Int,
        annualReturn: Double?
    ) {
        self.childAge = childAge
        self.levels = levels
        self.inflation = inflation
        self.income = income
        self.present = present
        self.deposit = deposit
        self.annualReturn = annualReturn
    }

    /** Each stage's cost when the child starts it. */
    package var costs: [EducationCost] { levels.map { $0.cost(childAge: childAge, inflation: inflation) } }

    /** The target of Pilih Tipe Target. */
    package func target(for kind: EducationTarget = .all) -> Int { Rupiah.rounded(targetAmount(for: kind)) }

    /** Years from now to the first stage, plus every stage's years. */
    package var yearsInvesting: Int {
        guard let first = levels.first else { return 0 }
        return max(first.stage.entryAge - childAge, 0) + levels.reduce(0) { $0 + $1.stage.years }
    }

    /** The plan against the target of `kind`, compounding yearly. */
    package func projection(for kind: EducationTarget = .all) -> GoalProjection {
        GoalMath.project(
            target: targetAmount(for: kind), present: present, deposit: deposit * 12, annualReturn: annualReturn ?? 0,
            months: yearsInvesting * 12, period: .year)
    }

    /** The most Naikkan Investasi suggests: the income bracket's share. */
    package var depositCap: Int {
        let share: Double =
            switch income {
            case ...3_000_000: 0.2
            case ...15_000_000: 0.3
            case ...50_000_000: 0.5
            default: 0.6
            }
        return Rupiah.rounded(Double(income) * share)
    }

    /** The first stage's fees a month with its other costs, as a share of income. */
    package var firstMonthlyShare: Double {
        guard let level = levels.first, income > 0 else { return 0 }
        let first = level.cost(childAge: childAge, inflation: inflation)
        let monthly = first.tuitionAmount / 12 / Double(first.years)
        return monthly * (1 + level.otherRate) / Double(income)
    }

    /** Naikkan Investasi, and Pilih Return Lebih Tinggi when the income share is not enough. */
    package func recommendations(for kind: EducationTarget = .all) -> [GoalRecommendation] {
        let target = targetAmount(for: kind)
        var percent = Int(((annualReturn ?? 0) * 100 + 1e-9).rounded(.down))
        var monthly = Double(deposit)
        var reached = result(monthly: monthly, percent: percent)
        guard Rupiah.rounded(reached) < Rupiah.rounded(target) else { return [] }
        let cap = Double(depositCap)
        while reached < target, monthly < cap {
            monthly = min(monthly + (reached > target * 0.2 ? 100_000 : 300_000), cap)
            reached = result(monthly: monthly, percent: percent)
        }
        var found: [GoalRecommendation] = [.raiseDeposit(to: Rupiah.rounded(monthly))]
        guard reached < target else { return found }
        let returnCap = GoalRecommender.returnCap(years: Double(yearsInvesting))
        while reached < target, percent < returnCap {
            percent += 1
            reached = result(monthly: monthly, percent: percent)
        }
        found.append(.raiseReturn(to: Double(percent) / 100))
        return found
    }

    private func targetAmount(for kind: EducationTarget) -> Double {
        costs.reduce(0) { $0 + $1.amount(for: kind) }
    }

    private func result(monthly: Double, percent: Int) -> Double {
        GoalMath.futureValue(
            rate: Double(percent) / 100, periods: yearsInvesting, payment: monthly * 12, present: Double(present))
    }
}
