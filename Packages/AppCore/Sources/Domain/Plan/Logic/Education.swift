/**
 Pendidikan Anak (REN-02c, REN-02i, REN-04d): each school stage costs its entry fee and its fees
 for all its years, inflated (15% by default) to the year the child starts it, plus a share for
 other costs; the plan compounds yearly, twelve deposits a year at its start, from now until the
 last stage ends. The site plans a target per stage; the board sums them, and this follows it.
 */
package enum EducationStage: CaseIterable, Equatable, Sendable {
    /** SD / MI. */
    case primary
    /** SMP / MTs. */
    case juniorHigh
    /** SMA / SMK / MA. */
    case seniorHigh
    /** S1 / D4. */
    case bachelor

    /** The age a child starts it. */
    package var entryAge: Int {
        switch self {
        case .primary: 6
        case .juniorHigh: 12
        case .seniorHigh: 15
        case .bachelor: 18
        }
    }

    /** How many years it lasts. */
    package var years: Int {
        switch self {
        case .primary: 6
        case .juniorHigh, .seniorHigh: 3
        case .bachelor: 4
        }
    }
}

/** How often the school fee is paid. */
package enum FeePeriod: Equatable, Sendable {
    /** Per bulan. */
    case month
    /** Per semester. */
    case semester
    /** Per tahun. */
    case year

    /** How many times a year. */
    package var perYear: Int {
        switch self {
        case .month: 12
        case .semester: 2
        case .year: 1
        }
    }
}

/** One stage of the plan at today's prices (Atur Jenjang). */
package struct EducationLevel: Equatable, Sendable {
    package let stage: EducationStage
    /** Uang Pangkal. */
    package let entryFee: Int
    /** Uang Sekolah per `feePeriod`. */
    package let fee: Int
    package let feePeriod: FeePeriod
    /** Biaya Lain as a share of the entry fee and fees (0.10). */
    package let otherRate: Double

    /** A stage at today's prices. */
    package init(stage: EducationStage, entryFee: Int, fee: Int, feePeriod: FeePeriod, otherRate: Double) {
        self.stage = stage
        self.entryFee = entryFee
        self.fee = fee
        self.feePeriod = feePeriod
        self.otherRate = otherRate
    }

    /** Its cost when a child now `childAge` starts it, at `inflation` a year. */
    package func cost(childAge: Int, inflation: Double) -> EducationCost {
        let startsIn = max(stage.entryAge - childAge, 0)
        let growth = GoalMath.inflatedAmount(1, rate: inflation, years: Double(startsIn))
        let entry = Double(entryFee) * growth
        let tuition = Double(fee * feePeriod.perYear * stage.years) * growth
        let other = otherRate * (entry + tuition)
        return EducationCost(
            stage: stage, startsInYears: startsIn, years: stage.years, entryAmount: entry, tuitionAmount: tuition,
            otherAmount: other)
    }
}

/** What one stage costs when the child starts it. */
package struct EducationCost: Equatable, Sendable {
    package let stage: EducationStage
    /** Years until the child starts it. */
    package let startsInYears: Int
    package let years: Int
    let entryAmount: Double
    let tuitionAmount: Double
    let otherAmount: Double

    /** Uang pangkal, inflated. */
    package var entry: Int { Rupiah.rounded(entryAmount) }
    /** Uang sekolah for all its years, inflated. */
    package var tuition: Int { Rupiah.rounded(tuitionAmount) }
    /** Biaya lain. */
    package var other: Int { Rupiah.rounded(otherAmount) }
    /** All three. */
    package var total: Int { Rupiah.rounded(totalAmount) }

    var totalAmount: Double { entryAmount + tuitionAmount + otherAmount }

    /** What Pilih Tipe Target counts of it. */
    func amount(for kind: EducationTarget) -> Double {
        switch kind {
        case .entryOnly: entryAmount
        case .entryAndTuition: entryAmount + tuitionAmount
        case .all: totalAmount
        }
    }
}

/** Pilih Tipe Target: Uang Pangkal, UP + SPP, Semua. */
package enum EducationTarget: Equatable, Sendable {
    case entryOnly
    case entryAndTuition
    case all
}
