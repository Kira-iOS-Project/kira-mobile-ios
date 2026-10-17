import Domain
import Foundation
import Observation

/**
 Tujuan Baru for something with a price (REN-02f Kendaraan, in years; REN-02g Barang Impian, in
 months and named): its price today, the DP share (100% is cash), the yearly price inflation, what
 is already set aside, and the strategy. Hitung works out the projection against the DP's share of
 the inflated price (feliciaputritjiasaka.com), for Hasil Simulasi (REN-04g, REN-04h).
 */
@MainActor @Observable
package final class PriceGoalModel {
    /** How the horizon is typed. */
    package enum Horizon: Sendable {
        /** "Tahun Lagi" (Kendaraan). */
        case years
        /** "Bulan Lagi" (Barang Impian). */
        case months
    }

    /** The goal's kind. */
    package let kind: GoalKind
    /** Whether the horizon is in years or months. */
    package let horizon: Horizon
    /** "Barang yang Mau Kamu Beli" (Barang Impian only). */
    package var name: String
    /** "Tercapai dalam": years or months ahead, as typed. */
    package var duration: String
    /** Today's price, in rupiah as typed. */
    package var price: String
    /** "DP", in percent as typed (100 is cash). */
    package var downPayment: String
    /** "Inflasi Harga", in percent per year as typed. */
    package var inflation: String
    /** What is already set aside, in rupiah as typed. */
    package var present: String
    /** "Target Investasi" per period, in rupiah as typed. */
    package var deposit: String
    /** "Return Investasi", in percent per year as typed. */
    package var annualReturn: String

    /** A form for `kind`, with the inflation default (5%) and anything in `values`. */
    package init(kind: GoalKind, horizon: Horizon, values: PriceGoalValues = PriceGoalValues()) {
        self.kind = kind
        self.horizon = horizon
        name = values.name
        duration = values.duration
        price = values.price
        downPayment = values.downPayment
        inflation = values.inflation
        present = values.present
        deposit = values.deposit
        annualReturn = values.annualReturn
    }

    /** "DP Kamu Setara": the DP share of today's price. */
    package var downPaymentAmount: Int? {
        guard let price = GoalFieldInput.rupiah(price), let share = GoalFieldInput.percent(downPayment) else {
            return nil
        }
        return Int((Double(price) * share).rounded())
    }

    /** "Pokok KKB": the rest of today's price, nil when bought in cash. */
    package var loanPrincipal: Int? {
        guard let price = GoalFieldInput.rupiah(price), let share = GoalFieldInput.percent(downPayment), share < 1
        else {
            return nil
        }
        return price - Int((Double(price) * share).rounded())
    }

    /** Whether everything Hitung needs is filled in. */
    package var canCalculate: Bool { outcome != nil }

    /** Hitung: the projection and what goes with it; nil while something is missing. */
    package var outcome: PriceGoalOutcome? {
        guard let months = months, let price = GoalFieldInput.rupiah(price), price > 0,
            let share = GoalFieldInput.percent(downPayment), share > 0,
            let inflation = GoalFieldInput.percent(inflation),
            let deposit = GoalFieldInput.rupiah(deposit), let annualReturn = GoalFieldInput.percent(annualReturn),
            kind != .goods || !name.trimmingCharacters(in: .whitespaces).isEmpty
        else { return nil }
        let present = GoalFieldInput.rupiah(present) ?? 0
        let cost = Int((Double(price) * share).rounded())
        let target = GoalMath.inflatedAmount(cost, rate: inflation, years: Double(months) / 12)
        let projection = GoalMath.project(
            target: target, present: present, deposit: deposit, annualReturn: annualReturn, months: months)
        return PriceGoalOutcome(
            name: name.trimmingCharacters(in: .whitespaces), price: price, downPayment: share, inflation: inflation,
            months: months, horizon: horizon, present: present, deposit: deposit, annualReturn: annualReturn,
            projection: projection,
            recommendations: recommendations(
                cost: cost, inflation: inflation, months: months,
                strategy: Strategy(present: present, deposit: deposit, annualReturn: annualReturn)),
            assetClasses: GoalMath.assetClasses(years: Double(months) / 12))
    }

    private var months: Int? {
        guard let count = GoalFieldInput.count(duration) else { return nil }
        return horizon == .years ? count * 12 : count
    }

    /** The engine's recommendations: by the year for Kendaraan, by the month for Barang Impian. */
    private func recommendations(
        cost: Int, inflation: Double, months: Int, strategy: Strategy
    ) -> [GoalRecommendation] {
        horizon == .years
            ? GoalRecommender.recommendations(
                cost: .init(cost), inflation: inflation, years: months / 12, present: strategy.present,
                deposit: strategy.deposit, annualReturn: strategy.annualReturn)
            : GoalRecommender.recommendations(
                cost: .init(cost), inflation: inflation, months: months, present: strategy.present,
                deposit: strategy.deposit, annualReturn: strategy.annualReturn)
    }

    /** What the person puts in: set aside, deposited, and the return. */
    private struct Strategy {
        let present: Int
        let deposit: Int
        let annualReturn: Double
    }

}

/** What a price goal's form opens with: the inflation default, or a previous result's figures. */
package struct PriceGoalValues: Equatable, Sendable {
    /** The goal's name: "Barang yang Mau Kamu Beli" or "Nama Tujuan". */
    package var name = ""
    /** "Tercapai dalam": years or months ahead, as typed. */
    package var duration = ""
    /** Today's price, in rupiah as typed. */
    package var price = ""
    /** "DP", in percent as typed (100 is cash). */
    package var downPayment = ""
    /** "Inflasi Harga", in percent per year as typed. */
    package var inflation = "5"
    /** What is already set aside, in rupiah as typed. */
    package var present = ""
    /** "Target Investasi" per period, in rupiah as typed. */
    package var deposit = ""
    /** "Return Investasi", in percent per year as typed. */
    package var annualReturn = ""

    /** Nothing filled in but the defaults. */
    package init() {}
}

/** Hasil Simulasi of a price goal: the figures the form gave and what the engine made of them. */
package struct PriceGoalOutcome: Equatable, Sendable {
    /** The goal's name, trimmed. */
    package let name: String
    /** Today's price. */
    package let price: Int
    /** The DP share, 0 to 1. */
    package let downPayment: Double
    /** Yearly price inflation, a fraction. */
    package let inflation: Double
    /** The horizon in months. */
    package let months: Int
    /** Whether the form asked for years or months. */
    package let horizon: PriceGoalModel.Horizon
    /** What is already set aside. */
    package let present: Int
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
