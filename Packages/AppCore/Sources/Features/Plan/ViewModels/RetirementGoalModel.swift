import Domain
import Foundation
import Observation

/**
 Tujuan Baru · Dana Pensiun (REN-02e, board TujuanPensiun): the monthly expenses today, the age now
 and the age to retire at, the yearly inflation (4% by default), the fund already there, and the
 strategy. Hitung works out a year of those expenses inflated to retirement day, the fund that pays
 them at a 4% yearly withdrawal (feliciaputritjiasaka.com), and what the strategy reaches by then,
 for Hasil Simulasi (REN-04f).
 */
@MainActor @Observable
package final class RetirementGoalModel {
    /** "Pengeluaran per Bulan". */
    package var expense: String
    /** "Usiamu Sekarang". */
    package var age: String
    /** "Pensiun di Usia". */
    package var retirementAge: String
    /** "Asumsi Inflasi Tahunan". */
    package var inflation: String
    /** "Dana Pensiun yang Sudah Ada". */
    package var present: String
    /** "Target Investasi per Bulan". */
    package var deposit: String
    /** "Return Investasi". */
    package var annualReturn: String

    /** A form with the inflation default (4%) and anything in `values`. */
    package init(values: RetirementGoalValues = RetirementGoalValues()) {
        expense = values.expense
        age = values.age
        retirementAge = values.retirementAge
        inflation = values.inflation
        present = values.present
        deposit = values.deposit
        annualReturn = values.annualReturn
    }

    /** "Setara Rp72.000.000,00 per tahun": the monthly expenses × 12; nil while nothing is typed. */
    package var annualExpense: Int? {
        RetirementGoalModel.rupiah(expense).map { $0 * 12 }
    }

    /** "Kamu Pensiun dalam N tahun lagi"; nil until both ages are typed and retirement comes later. */
    package var years: Int? {
        guard let age = RetirementGoalModel.count(age), let retirementAge = RetirementGoalModel.count(retirementAge),
            retirementAge > age
        else { return nil }
        return retirementAge - age
    }

    /** Whether everything Hitung needs is filled in. */
    package var canCalculate: Bool { outcome != nil }

    /** Hitung: the projection and what goes with it; nil while something is missing. */
    package var outcome: RetirementGoalOutcome? {
        guard let expense = RetirementGoalModel.rupiah(expense), expense > 0, let years,
            let age = RetirementGoalModel.count(age),
            let inflation = RetirementGoalModel.percent(inflation), let deposit = RetirementGoalModel.rupiah(deposit),
            let annualReturn = RetirementGoalModel.percent(annualReturn)
        else { return nil }
        let present = RetirementGoalModel.rupiah(present) ?? 0
        let need = GoalMath.retirementTarget(monthlyExpense: expense, inflation: inflation, years: years)
        let projection = GoalMath.project(
            target: Double(need.target), present: present, deposit: deposit, annualReturn: annualReturn,
            months: years * 12)
        /**
         The fund today is 25 years of expenses (1 ÷ 4%), so inflating it over the years is the target.
         `.init` fits the engine's cost, whole or fractional rupiah. The board has no Perpanjang Waktu:
         the date is an age.
         */
        let recommendations = GoalRecommender.recommendations(
            cost: .init(expense * 12 * 25), inflation: inflation, years: years, present: present, deposit: deposit,
            annualReturn: annualReturn, offersYears: false)
        return RetirementGoalOutcome(
            monthlyExpense: expense, age: age, years: years, inflation: inflation, annualExpense: need.annualExpense,
            present: present, deposit: deposit, annualReturn: annualReturn, projection: projection,
            recommendations: recommendations, assetClasses: GoalMath.assetClasses(years: Double(years)))
    }

    /** Whole rupiah, grouped while typing; nil when nothing is typed. */
    private static func rupiah(_ text: String) -> Int? {
        AmountInput.value(of: text)
    }

    /** A whole count above zero (an age); nil otherwise. */
    private static func count(_ text: String) -> Int? {
        guard let value = Int(text.filter(\.isNumber)), value > 0 else { return nil }
        return value
    }

    /** A percent written with a comma or a dot ("4,5"), as a fraction; nil outside 0 to 100%. */
    private static func percent(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value >= 0, value <= 100 else { return nil }
        return value / 100
    }
}

/** What Dana Pensiun's form opens with: the inflation default, or a previous result's figures. */
package struct RetirementGoalValues: Equatable, Sendable {
    /** "Pengeluaran per Bulan". */
    package var expense = ""
    /** "Usiamu Sekarang". */
    package var age = ""
    /** "Pensiun di Usia". */
    package var retirementAge = ""
    /** "Asumsi Inflasi Tahunan". */
    package var inflation = "4"
    /** "Dana Pensiun yang Sudah Ada". */
    package var present = ""
    /** "Target Investasi per Bulan". */
    package var deposit = ""
    /** "Return Investasi". */
    package var annualReturn = ""

    /** An empty form with the 4% default. */
    package init() {}
}

/** Hasil Simulasi · Dana Pensiun: the figures the form gave and what the engine made of them. */
package struct RetirementGoalOutcome: Equatable, Sendable {
    /** "Pengeluaran per Bulan". */
    package let monthlyExpense: Int
    /** "Usiamu Sekarang"; retirement comes at `age + years` (for the goal POST /goals stores). */
    package let age: Int
    /** Years until retirement. */
    package let years: Int
    /** "Asumsi Inflasi Tahunan", as a fraction. */
    package let inflation: Double
    /** A year of expenses on retirement day, inflated ("= Rp207.602.537,00"). */
    package let annualExpense: Int
    /** "Uangmu Saat Ini": the fund already there, 0 when blank. */
    package let present: Int
    /** "Investasi per Bulan". */
    package let deposit: Int
    /** "Return Investasi", as a fraction. */
    package let annualReturn: Double
    /** What the strategy reaches against the target. */
    package let projection: GoalProjection
    /** "Supaya Tercapai": a higher deposit or return, while short. */
    package let recommendations: [GoalRecommendation]
    /** "Kelas Aset untuk Jangka Ini". */
    package let assetClasses: [GoalAssetClass]
}
