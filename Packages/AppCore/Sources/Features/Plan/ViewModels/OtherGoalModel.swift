import Domain
import Foundation
import Observation

/**
 Tujuan Baru · Lainnya (REN-02h): a goal the person names, with the amount to reach (never
 inflated), the years to it, what is set aside, and the strategy, deposited every month or year,
 at the start or the end of each. Hitung works out Hasil Simulasi (REN-04i).
 */
@MainActor @Observable
package final class OtherGoalModel {
    /** The goal's name: "Barang yang Mau Kamu Beli" or "Nama Tujuan". */
    package var name: String
    /** "Jumlah Uang yang Ingin Dicapai", in rupiah as typed. */
    package var amount: String
    /** "Tercapai dalam": years or months ahead, as typed. */
    package var duration: String
    /** What is already set aside, in rupiah as typed. */
    package var present: String
    /** "Menabung Setiap": every month or every year. */
    package var period: DepositPeriod
    /** "Tambah Dana di": the start or the end of each period. */
    package var timing: DepositTiming
    /** "Target Investasi" per period, in rupiah as typed. */
    package var deposit: String
    /** "Return Investasi", in percent per year as typed. */
    package var annualReturn: String

    /** A form with `values`: monthly deposits at the start of each month unless they say otherwise. */
    package init(values: OtherGoalValues = OtherGoalValues()) {
        name = values.name
        amount = values.amount
        duration = values.duration
        present = values.present
        period = values.period
        timing = values.timing
        deposit = values.deposit
        annualReturn = values.annualReturn
    }

    /** Whether everything Hitung needs is filled in. */
    package var canCalculate: Bool { outcome != nil }

    /** Hitung: the projection and what goes with it; nil while something is missing. */
    package var outcome: OtherGoalOutcome? {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let target = GoalFieldInput.rupiah(amount), target > 0,
            let years = GoalFieldInput.count(duration), let deposit = GoalFieldInput.rupiah(deposit),
            let annualReturn = GoalFieldInput.percent(annualReturn)
        else { return nil }
        let present = GoalFieldInput.rupiah(present) ?? 0
        let projection = GoalMath.project(
            target: Double(target), present: present, deposit: deposit, annualReturn: annualReturn,
            months: years * 12, period: period, timing: timing)
        return OtherGoalOutcome(
            name: name, years: years, present: present, period: period, timing: timing, deposit: deposit,
            annualReturn: annualReturn, projection: projection,
            recommendations: GoalRecommender.recommendations(
                cost: .init(target), inflation: 0, years: years, present: present, deposit: deposit,
                annualReturn: annualReturn),
            assetClasses: GoalMath.assetClasses(years: Double(years)))
    }
}

/** What Lainnya's form opens with. */
package struct OtherGoalValues: Equatable, Sendable {
    /** The goal's name: "Barang yang Mau Kamu Beli" or "Nama Tujuan". */
    package var name = ""
    /** "Jumlah Uang yang Ingin Dicapai", in rupiah as typed. */
    package var amount = ""
    /** "Tercapai dalam": years or months ahead, as typed. */
    package var duration = ""
    /** What is already set aside, in rupiah as typed. */
    package var present = ""
    /** "Menabung Setiap": every month or every year. */
    package var period = DepositPeriod.month
    /** "Tambah Dana di": the start or the end of each period. */
    package var timing = DepositTiming.start
    /** "Target Investasi" per period, in rupiah as typed. */
    package var deposit = ""
    /** "Return Investasi", in percent per year as typed. */
    package var annualReturn = ""

    /** Nothing filled in but the defaults. */
    package init() {}
}

/** Hasil Simulasi · Lainnya: the figures the form gave and what the engine made of them. */
package struct OtherGoalOutcome: Equatable, Sendable {
    /** The goal's name, trimmed. */
    package let name: String
    /** The horizon in years. */
    package let years: Int
    /** What is already set aside. */
    package let present: Int
    /** "Menabung Setiap": every month or every year. */
    package let period: DepositPeriod
    /** "Tambah Dana di": the start or the end of each period. */
    package let timing: DepositTiming
    /** The deposit per period. */
    package let deposit: Int
    /** The yearly return, a fraction. */
    package let annualReturn: Double
    /** What the engine worked out. */
    package let projection: GoalProjection
    /** "Supaya Tercapai": what would reach the target, while it is short. */
    package let recommendations: [GoalRecommendation]
    /** The asset classes for the horizon. */
    package let assetClasses: [GoalAssetClass]
}
