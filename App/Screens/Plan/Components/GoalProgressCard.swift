/**
 Terkumpul (REN-05): what is saved and its share of the target, the bar with the milestones under it,
 and the next milestone with what is still missing, worked out by the engine.
 */
import Domain
import SwiftUI

struct GoalProgressCard: View {
    let goal: GoalDetail
    let progress: Double
    let next: (milestone: GoalMilestone, shortfall: Int)?
    let targetMultiple: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text("plan.detail.saved").kiraFont(.overline).foregroundStyle(.inkMuted)
                HStack(alignment: .firstTextBaseline, spacing: KiraSpacing.space2) {
                    KiraAmount(Decimal(goal.summary.savedAmount), size: .large)
                    Text(progress, format: .percent.precision(.fractionLength(0)))
                        .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
            }
            KiraProgressRibbon(value: Double(goal.summary.savedAmount), target: Double(goal.summary.targetAmount))
                .milestones(
                    goal.milestones.map {
                        KiraProgressRibbon.Milestone(
                            position: Double($0.amount), label: $0.label(targetMultiple: targetMultiple))
                    })
            if let next {
                Text(nextLine(next))
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    .padding(.top, KiraSpacing.space3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, KiraSpacing.space4)
        .kiraCard()
        .accessibilityElement(children: .contain)
    }

    /** "Tonggak berikutnya 3× (Rp12.600.000,00), kurang Rp7.800.000,00. Perkiraan dari mesin." */
    private func nextLine(_ next: (milestone: GoalMilestone, shortfall: Int)) -> LocalizedStringResource {
        let label = String(localized: next.milestone.label(targetMultiple: targetMultiple))
        let amount = next.milestone.amount.rupiah
        return "plan.detail.next \(label) \(amount, format: .rupiah) \(next.shortfall.rupiah, format: .rupiah)"
    }
}

/** The milestone last reached, with Kuku: no confetti, no streak, no countdown. */
struct GoalMilestoneCard: View {
    let milestone: GoalMilestone
    let progress: Double

    var body: some View {
        HStack(spacing: 14) {
            KiraMascot(.happy, size: 88, isFramed: false).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text(milestone.reachedTitle).font(.body.weight(.bold)).kiraLineHeight(22, size: 17)
                    .foregroundStyle(.ink)
                Text(milestone.reachedLine).font(.subheadline).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.inkMuted)
                KiraHandNote(
                    "plan.detail.note \(progress, format: .percent.precision(.fractionLength(0)))", size: .small
                )
                .padding(.top, KiraSpacing.space1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 14)
        .padding(.leading, 14)
        .padding(.trailing, KiraSpacing.space4)
        .kiraCard(.pandanSoft, border: .pandanLine)
        .accessibilityElement(children: .combine)
    }
}
