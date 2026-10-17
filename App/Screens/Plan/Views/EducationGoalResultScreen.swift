/**
 Hasil Simulasi · Pendidikan Anak (REN-04d, board HasilTujuanPendidikan): the shared result blocks in
 the board's order, with Rincian Biaya after Supaya Tercapai: Pilih Tipe Target (which sets the
 target the whole result weighs), each stage's inflated cost and its parts, and the first stage's
 monthly fees against the parents' income. The plan compounds yearly, as the board does.
 */
import Domain
import Features
import SwiftUI

struct EducationGoalResultScreen: View {
    let outcome: EducationGoalOutcome
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget: the caller saves the goal (POST /goals) and goes back to Rencana. */
    var onBudget: () -> Void = {}
    @State private var targetKind = EducationTarget.all
    @State private var chosen: GoalRecommendation?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let content = content
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "plan.result.title", subtitle: "plan.education.title",
                    leading: .back("plan.result.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                GoalResultHero(content: content)
                GoalResultStatus(fit: content.projection.fit)
                KiraSectionTitle("plan.result.details", trailing: .note("plan.result.details.note"))
                    .padding(.top, KiraSpacing.space2)
                EducationResultDetails(content: content, lastStage: outcome.plan.levels.last?.stage)
                GoalComposition(projection: content.projection)
                if content.projection.fit != .fits, !content.recommendations.isEmpty {
                    GoalRecommendations(content: content, chosen: $chosen)
                }
                EducationCostBreakdown(outcome: outcome, targetKind: $targetKind)
                GoalAssetClasses(classes: content.assetClasses)
                KiraNotice(.education, title: "plan.result.education.title", message: "plan.result.education")
                GoalFormulas(formulas: content.formulas, footnote: content.footnote)
                KiraNotice(.simulation, title: "plan.goal.simulation.title", message: "plan.result.simulation")
                WeightedRow(weights: [1, 1.3], spacing: 10) {
                    KiraButton("plan.result.edit", variant: .secondary, size: .small) { dismiss() }.block()
                    KiraButton("plan.result.budget", size: .small, action: onBudget).block()
                }
                .padding(.top, KiraSpacing.space1)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.vertical, KiraSpacing.space2)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var content: GoalResultContent {
        let plan = outcome.plan
        let projection = plan.projection(for: targetKind)
        let rate = plan.annualReturn ?? 0
        let first = plan.levels.first?.stage ?? .primary
        let last = plan.levels.last?.stage ?? .bachelor
        let startsIn = max(first.entryAge - plan.childAge, 0)
        return GoalResultContent(
            goal: "plan.education.title", overline: "plan.education.result.overline \(outcome.childName)",
            amountSize: .large,
            caption: Text(
                "plan.education.result.caption \(String(localized: first.title)) \(String(localized: last.title)) \(startsIn)"
            ),
            projection: projection, present: plan.present, deposit: plan.deposit, annualReturn: rate,
            horizon: .years(plan.yearsInvesting), recommendations: plan.recommendations(for: targetKind),
            assetClasses: GoalMath.assetClasses(years: Double(plan.yearsInvesting)),
            formulas: [
                GoalFormula(
                    title: "plan.education.formula.cost",
                    lines: [
                        Text("plan.education.formula.cost.line \(Text(plan.inflation * 100, format: .kiraMultiple))"),
                        Text("plan.education.formula.cost.until"),
                    ]),
                GoalFormula(
                    title: "plan.formula.result",
                    lines: [
                        Text(
                            "plan.education.formula.fv \(Text(rate * 100, format: .kiraMultiple)) \(plan.yearsInvesting) \(Text((plan.deposit * 12).rupiah, format: .rupiah))"
                        ),
                        Text("plan.education.formula.fv.present \(Text(plan.present.rupiah, format: .rupiah))"),
                        Text("plan.formula.equals \(Text(projection.result.rupiah, format: .rupiah))"),
                    ]),
            ],
            footnote: "plan.education.result.footnote")
    }
}

/** Rinciannya, with Lama Investasi "19 tahun · sampai lulus S1 / D4". */
private struct EducationResultDetails: View {
    let content: GoalResultContent
    let lastStage: EducationStage?

    var body: some View {
        let projection = content.projection
        let years = if case .years(let years) = content.horizon { years } else { 0 }
        KiraListGroup("plan.result.details.group") {
            KiraListRow(Text("plan.result.present"), leading: .icon(.wallet), trailing: .none)
                .amount(KiraAmount(content.present.rupiah))
            KiraListRow(Text("plan.result.deposit.month"), leading: .icon(.calendar), trailing: .none)
                .amount(KiraAmount(content.deposit.rupiah))
            KiraListRow(Text("plan.result.return"), leading: .icon(.chart), trailing: .none)
                .subtitle(GoalCopy.yearlyRate(content.annualReturn))
            KiraListRow(Text("plan.result.horizon"), leading: .icon(.clock), trailing: .none)
                .subtitle(
                    Text("plan.education.result.horizon \(years) \(String(localized: (lastStage ?? .bachelor).title))"))
            KiraListRow(Text("plan.result.outcome"), leading: .icon(.target), trailing: .none)
                .subtitle(Text("plan.result.outcome.subtitle")).amount(KiraAmount(projection.result.rupiah))
            if projection.shortfall > 0 {
                KiraListRow(Text("plan.result.shortfall"), leading: .icon(.alert), trailing: .none)
                    .subtitle(Text("plan.result.shortfall.subtitle"))
                    .amount(KiraAmount(projection.shortfall.rupiah))
            }
        }
    }
}

/** Rincian Biaya: Pilih Tipe Target, Biaya per Jenjang, its parts, and the monthly fees' share of income. */
private struct EducationCostBreakdown: View {
    let outcome: EducationGoalOutcome
    @Binding var targetKind: EducationTarget

    var body: some View {
        let plan = outcome.plan
        let costs = plan.costs
        KiraSectionTitle("plan.education.result.costs").padding(.top, KiraSpacing.space2)
        VStack(alignment: .leading, spacing: 6) {
            Text("plan.education.result.targetKind").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
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
            footer: "plan.education.result.perStage.footer \((plan.inflation * 100).formatted(.number.locale(Locale(identifier: "id_ID"))))"
        ) {
            ForEach(Array(costs.enumerated()), id: \.offset) { index, cost in
                let details = outcome.details[index]
                KiraListRow(Text(cost.stage.title), leading: .icon(.book), trailing: .none)
                    .subtitle(
                        Text(
                            "plan.education.result.stage \(cost.startsInYears) \(cost.years) \(String(localized: details.school.title)) \(String(localized: details.region.title))"
                        )
                    )
                    .amount(KiraAmount(cost.total.rupiah))
            }
        }
        KiraAccordion("plan.education.result.parts", subtitle: "plan.education.result.parts.subtitle", icon: .list) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(costs.enumerated()), id: \.offset) { _, cost in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cost.stage.title).font(.caption.weight(.semibold)).kiraLineHeight(16, size: 12)
                            .foregroundStyle(.inkMuted)
                        Text("plan.education.result.entry \(Text(cost.entry.rupiah, format: .rupiah))").kiraFont(.formula)
                        Text("plan.education.result.tuition \(Text(cost.tuition.rupiah, format: .rupiah))").kiraFont(.formula)
                        Text("plan.education.result.other \(Text(cost.other.rupiah, format: .rupiah))").kiraFont(.formula)
                    }
                    .foregroundStyle(.ink)
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(KiraSpacing.space3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .kiraCard(.surface, cornerRadius: KiraRadius.small)
        }
        if let first = plan.levels.first {
            KiraNotice(
                .info, title: "plan.education.result.monthly",
                message: "plan.education.result.monthly.body \(plan.firstMonthlyShare.formatted(.percent.precision(.fractionLength(1)).locale(Locale(identifier: "id_ID")))) \(String(localized: first.stage.title)) \((first.otherRate * 100).formatted(.number.locale(Locale(identifier: "id_ID"))))"
            )
        }
    }
}

extension EducationStage {
    /** "SD / MI" … "S1 / D4". */
    var title: LocalizedStringResource {
        switch self {
        case .primary: "plan.education.stage.primary"
        case .juniorHigh: "plan.education.stage.juniorHigh"
        case .seniorHigh: "plan.education.stage.seniorHigh"
        case .bachelor: "plan.education.stage.bachelor"
        }
    }
}

extension EducationRegion {
    var title: LocalizedStringResource {
        switch self {
        case .jakarta: "plan.education.region.jakarta"
        case .java: "plan.education.region.java"
        case .outsideJava: "plan.education.region.outsideJava"
        case .abroad: "plan.education.region.abroad"
        }
    }
}

extension EducationSchool {
    var title: LocalizedStringResource {
        switch self {
        case .public: "plan.education.school.public"
        case .private: "plan.education.school.private"
        case .nationalPlus: "plan.education.school.nationalPlus"
        case .international: "plan.education.school.international"
        }
    }
}

extension FeePeriod {
    /** "Bulan", "Semester", "Tahun". */
    var title: LocalizedStringResource {
        switch self {
        case .month: "plan.education.feePeriod.month"
        case .semester: "plan.education.feePeriod.semester"
        case .year: "plan.education.feePeriod.year"
        }
    }

    /** "per bulan", "per semester", "per tahun". */
    var per: String {
        switch self {
        case .month: String(localized: "plan.education.per.month")
        case .semester: String(localized: "plan.education.per.semester")
        case .year: String(localized: "plan.education.per.year")
        }
    }
}

extension EducationStageValues {
    /** "Swasta · Jakarta · pangkal Rp23.000.000,00 · Rp2.000.000,00 per bulan". */
    var summary: LocalizedStringResource {
        let entry = (AmountInput.value(of: entryFee) ?? 0).rupiah.formatted(.rupiah)
        let fee = (AmountInput.value(of: fee) ?? 0).rupiah.formatted(.rupiah)
        return
            "plan.education.stage.summary \(String(localized: school.title)) \(String(localized: region.title)) \(entry) \(fee) \(feePeriod.per)"
    }
}
