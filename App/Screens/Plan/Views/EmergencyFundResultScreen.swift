/**
 Hasil Simulasi · Dana Darurat (REN-04, board HasilSimulasi; REN-04b HasilSimulasiTerbuka with the
 working open): the fund the spending and the household need, against what the strategy reaches,
 split 50:50 between a bank account and a low-risk liquid instrument, in the frame every result
 shares. Pushed by Kalkulator Dana Darurat (REN-03).
 */
import Domain
import Features
import SwiftUI

struct EmergencyFundResultScreen: View {
    let outcome: EmergencyFundOutcome
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget: the caller saves the goal (POST /goals) and goes back to Rencana. */
    var onBudget: () -> Void = {}
    /** "Gimana Ngitungnya?" starts open (REN-04b). */
    var opensFormulas = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GoalResultFrame(
            content: content, onEdit: { _ in dismiss() }, onBudget: onBudget, onHelp: { onOpen(.care) },
            extra: { EmergencyFundSplitSection(outcome: outcome) }
        )
    }

    private var content: GoalResultContent {
        GoalResultContent(
            goal: "plan.kind.emergencyFund", overline: "plan.emergency.overline", caption: caption,
            projection: outcome.projection, present: outcome.present, deposit: outcome.deposit,
            annualReturn: outcome.annualReturn, horizon: .months(outcome.months),
            recommendations: outcome.recommendations, assetClasses: outcome.assetClasses,
            assetsTitle: "plan.emergency.assets", assetsNote: "plan.emergency.assets.note",
            formulas: EmergencyFundResultBlocks.formulas(outcome), footnote: EmergencyFundResultBlocks.footnote,
            opensFormulas: opensFormulas)
    }

    /** "6× pengeluaran pokok, karena belum menikah dan tanpa tanggungan". */
    private var caption: Text {
        let multiplier = outcome.multiplier
        switch (outcome.married, outcome.dependants > 0) {
        case (false, false): return Text("plan.emergency.caption.single \(multiplier)")
        case (false, true): return Text("plan.emergency.caption.singleWith \(multiplier) \(outcome.dependants)")
        case (true, false): return Text("plan.emergency.caption.married \(multiplier)")
        case (true, true): return Text("plan.emergency.caption.marriedWith \(multiplier) \(outcome.dependants)")
        }
    }
}
