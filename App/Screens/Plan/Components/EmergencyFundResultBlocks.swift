/**
 The parts only Hasil Simulasi · Dana Darurat draws (boards HasilSimulasi, REN-04, and
 HasilSimulasiTerbuka, REN-04b, its working open): the working of Gimana Ngitungnya? (the multiplier,
 the target and the investment's result) and Tempat Menyimpannya, the target split in two.
 */
import Features
import SwiftUI

/** Gimana Ngitungnya? for the emergency fund: Pengali, Target and Hasil investasi, then the footnote. */
enum EmergencyFundResultBlocks {
    /**
     "6× (belum menikah)" and "+ 3× × 0 tanggungan = 6×"; "6 × Rp4.200.000,00" and
     "= Rp25.200.000,00"; "FV(4% ÷ 12, 30 bulan," "Rp650.000,00, Rp4.800.000,00)" and
     "= Rp25.844.674,00".
     */
    static func formulas(_ outcome: EmergencyFundOutcome) -> [GoalFormula] {
        let base: LocalizedStringResource =
            outcome.married ? "plan.emergency.formula.base.married" : "plan.emergency.formula.base.single"
        return [
            GoalFormula(
                title: "plan.emergency.formula.multiplier",
                lines: [
                    Text(base),
                    Text("plan.emergency.formula.dependants \(outcome.dependants) \(outcome.multiplier)"),
                ]),
            GoalFormula(
                title: "plan.formula.target",
                lines: [
                    Text("plan.emergency.formula.target \(outcome.multiplier) \(GoalCopy.rupiah(outcome.essential))"),
                    Text("plan.formula.equals \(GoalCopy.rupiah(outcome.target))"),
                ]),
            GoalFormula(
                title: "plan.formula.result",
                lines: [
                    Text("plan.formula.fv.head \(GoalCopy.percent(outcome.annualReturn)) \(outcome.months)"),
                    amounts(outcome),
                    Text("plan.formula.equals \(GoalCopy.rupiah(outcome.projection.result))"),
                ]),
        ]
    }

    /** "Rp650.000,00, Rp4.800.000,00)": the monthly deposit and the money saved already. */
    private static func amounts(_ outcome: EmergencyFundOutcome) -> Text {
        let deposit = GoalCopy.rupiah(outcome.deposit)
        return Text("plan.formula.fv.amounts \(deposit) \(GoalCopy.rupiah(outcome.present))")
    }

    /** How the deposits grow and how the multiplier is set, under the working. */
    static let footnote: LocalizedStringResource = "plan.emergency.formula.footnote"
}

/** Tempat Menyimpannya: split in two, kept apart from the everyday account, half in each place. */
struct EmergencyFundSplitSection: View {
    let outcome: EmergencyFundOutcome

    var body: some View {
        KiraSectionTitle("plan.emergency.split.title").padding(.top, KiraSpacing.space2)
        Text("plan.emergency.split.lead")
            .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
            .padding(.horizontal, KiraSpacing.space1)
        place(.bank, title: "plan.emergency.split.bank", detail: "plan.emergency.split.bank.detail")
        place(.mutualFunds, title: "plan.emergency.split.liquid", detail: "plan.emergency.split.liquid.detail")
    }

    private func place(
        _ category: KiraCategory, title: LocalizedStringResource, detail: LocalizedStringResource
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            KiraCategoryIcon(category, size: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text("plan.emergency.split.share")
                    .font(KiraFont.display(13, .heavy, relativeTo: .footnote)).monospacedDigit()
                    .foregroundStyle(.pandan)
                Text(title).kiraFont(.headline).foregroundStyle(.ink)
                Text(detail).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                KiraAmount(outcome.half.rupiah, size: .small).padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(KiraSpacing.space4)
        .kiraCard()
        .accessibilityElement(children: .combine)
    }
}
