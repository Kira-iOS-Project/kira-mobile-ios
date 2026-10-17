/**
 What every Hasil Simulasi board (HasilTujuanDP … HasilTujuanLainnya) shows, as one goal's result
 screen fills it in for `GoalResultFrame`: the kind's own words (overline, caption, formulas,
 footnote) and the engine's figures. The frame draws the rest the boards share.
 */
import Domain
import SwiftUI

struct GoalResultContent {
    /** The nav bar's subtitle: the kind ("Dana Pensiun") or the goal's own name ("Laptop Baru"). */
    let goal: LocalizedStringResource
    /** The hero's overline, such as "Total uang yang kamu butuhkan". */
    let overline: LocalizedStringResource
    /** The hero amount's size: `.extraLarge`, or `.large` for Dana Pensiun's ten digits. */
    var amountSize = KiraAmount.Size.extraLarge
    /** The hero's line under the amount, such as "DP 25% kendaraan 2 tahun lagi, …". */
    let caption: Text
    /** What the engine worked out. */
    let projection: GoalProjection
    /** "Uangmu Saat Ini". */
    let present: Int
    /** The deposit, and whether it is per month or per year. */
    let deposit: Int
    var period = DepositPeriod.month
    /** "Return Investasi", as a fraction (0.05). */
    let annualReturn: Double
    /** "Lama Investasi". */
    let horizon: GoalHorizon
    /** "Supaya Tercapai", shown only while the strategy falls short. */
    var recommendations: [GoalRecommendation] = []
    /** "Kelas Aset untuk Jangka Ini". */
    let assetClasses: [GoalAssetClass]
    /** "Gimana Ngitungnya?": the target's and the result's working. */
    let formulas: [GoalFormula]
    /** The muted paragraph under the formulas. */
    var footnote: LocalizedStringResource = "plan.result.footnote"
}

/** How long a goal runs: in years for most kinds, in months for Barang Impian. */
enum GoalHorizon: Equatable {
    case years(Int)
    case months(Int)
}

/** One working in "Gimana Ngitungnya?": its muted title, then its formula lines. */
struct GoalFormula {
    let title: LocalizedStringResource
    let lines: [Text]
}
