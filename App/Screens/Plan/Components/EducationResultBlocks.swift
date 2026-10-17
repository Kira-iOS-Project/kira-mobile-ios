/**
 The blocks only Hasil Simulasi · Pendidikan Anak draws (board HasilTujuanPendidikan): Rinciannya with
 "sampai lulus …", and Rincian Biaya (Pilih Tipe Target, Biaya per Jenjang, the parts of each stage,
 and the first stage's monthly fees as a share of income).
 */
import Domain
import Features
import SwiftUI

/** Rinciannya, with Lama Investasi "19 tahun · sampai lulus S1 / D4". */
struct EducationResultDetails: View {
    let content: GoalResultContent
    let lastStage: EducationStage?

    var body: some View {
        let projection = content.projection
        KiraListGroup("plan.result.details.group") {
            KiraListRow(Text("plan.result.present"), leading: .icon(.wallet), trailing: .none)
                .amount(KiraAmount(content.present.rupiah))
            KiraListRow(Text("plan.result.deposit.month"), leading: .icon(.calendar), trailing: .none)
                .amount(KiraAmount(content.deposit.rupiah))
            KiraListRow(Text("plan.result.return"), leading: .icon(.chart), trailing: .none)
                .subtitle(GoalCopy.yearlyRate(content.annualReturn))
            KiraListRow(Text("plan.result.horizon"), leading: .icon(.clock), trailing: .none)
                .subtitle(horizon)
            KiraListRow(Text("plan.result.outcome"), leading: .icon(.target), trailing: .none)
                .subtitle(Text("plan.result.outcome.subtitle")).amount(KiraAmount(projection.result.rupiah))
            if projection.shortfall > 0 {
                KiraListRow(Text("plan.result.shortfall"), leading: .icon(.alert), trailing: .none)
                    .subtitle(Text("plan.result.shortfall.subtitle"))
                    .amount(KiraAmount(projection.shortfall.rupiah))
            }
        }
    }

    private var horizon: Text {
        let years = if case .years(let years) = content.horizon { years } else { 0 }
        return Text("plan.education.result.horizon \(years) \(EducationCopy.text((lastStage ?? .bachelor).title))")
    }
}

/** Rincian Biaya: Pilih Tipe Target, Biaya per Jenjang, its parts, and the monthly fees' share of income. */
struct EducationCostBreakdown: View {
    let outcome: EducationGoalOutcome
    @Binding var targetKind: EducationTarget

    var body: some View {
        let plan = outcome.plan
        KiraSectionTitle("plan.education.result.costs").padding(.top, KiraSpacing.space2)
        EducationLabeled("plan.education.result.targetKind") {
            KiraSegmented(
                "plan.education.result.targetKind",
                options: [
                    .init(id: EducationTarget.entryOnly, title: "plan.education.result.target.entry"),
                    .init(id: .entryAndTuition, title: "plan.education.result.target.tuition"),
                    .init(id: .all, title: "plan.education.result.target.all"),
                ],
                selection: $targetKind)
        }
        KiraListGroup(
            "plan.education.result.perStage",
            footer: "plan.education.result.perStage.footer \(EducationCopy.number(plan.inflation * 100))"
        ) {
            ForEach(Array(plan.costs.enumerated()), id: \.offset) { index, cost in
                KiraListRow(Text(cost.stage.title), leading: .icon(.book), trailing: .none)
                    .subtitle(Text(EducationCopy.stageLine(cost, values: outcome.details[index])))
                    .amount(KiraAmount(cost.total.rupiah))
            }
        }
        KiraAccordion("plan.education.result.parts", subtitle: "plan.education.result.parts.subtitle", icon: .list) {
            EducationCostParts(costs: plan.costs)
        }
        if let first = plan.levels.first {
            KiraNotice(
                .info, title: "plan.education.result.monthly",
                message: EducationCopy.monthlyShare(plan.firstMonthlyShare, level: first))
        }
    }
}

/** Rincian Biaya per Jenjang: each stage's entry fee, fees and other costs. */
private struct EducationCostParts: View {
    let costs: [EducationCost]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(costs.enumerated()), id: \.offset) { _, cost in
                VStack(alignment: .leading, spacing: 2) {
                    Text(cost.stage.title).font(.caption.weight(.semibold)).kiraLineHeight(16, size: 12)
                        .foregroundStyle(.inkMuted)
                    line("plan.education.result.entry \(Text(cost.entry.rupiah, format: .rupiah))")
                    line("plan.education.result.tuition \(Text(cost.tuition.rupiah, format: .rupiah))")
                    line("plan.education.result.other \(Text(cost.other.rupiah, format: .rupiah))")
                }
                .foregroundStyle(.ink)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(KiraSpacing.space3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard(.surface, cornerRadius: KiraRadius.small)
    }

    private func line(_ key: LocalizedStringKey) -> some View {
        Text(key).kiraFont(.formula)
    }
}
