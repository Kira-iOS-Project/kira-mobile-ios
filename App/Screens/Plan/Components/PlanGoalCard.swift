/**
 One goal in Tujuanmu (REN-01): its icon and name, the target and when it is reached ("Target 6× ·
 tercapai April 2029" for the emergency fund), what is saved of the target, and the progress with
 the monthly deposit. The whole card is one button to Detail Tujuan.
 */
import Domain
import SwiftUI

struct PlanGoalCard: View {
    let goal: GoalSummary
    var targetMultiple: Double?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: KiraSpacing.space3) {
                    KiraCategoryIcon(goal.kind.category)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name).font(.body.weight(.semibold)).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                        Text(meta).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
                }
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        KiraAmount(Decimal(goal.savedAmount), size: .medium)
                        Text("plan.goal.of \(goal.targetAmount.rupiah, format: .rupiah)")
                            .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                            .monospacedDigit()
                    }
                    KiraProgressRibbon(value: Double(goal.savedAmount), target: Double(goal.targetAmount))
                        .caption("plan.goal.deposit \(goal.monthlyDeposit.rupiah, format: .rupiah)")
                }
            }
            .padding(.vertical, KiraSpacing.space4)
            .padding(.leading, KiraSpacing.space4)
            .padding(.trailing, 14)
            .kiraCard()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityAddTraits(.isButton)
    }

    /** "Target 6× · tercapai April 2029", or "Tercapai April 2029" without a multiple. */
    private var meta: LocalizedStringResource {
        let date = goal.targetDate.date
        guard let targetMultiple else { return "plan.goal.reached \(date, format: .kiraMonthYear)" }
        return "plan.goal.reached.multiple \(targetMultiple, format: .kiraMultiple) \(date, format: .kiraMonthYear)"
    }

    /** "Dana Darurat, terkumpul Rp4.800.000,00 dari Rp25.200.000,00. Buka detail". */
    private var label: LocalizedStringResource {
        let saved = goal.savedAmount.rupiah
        let target = goal.targetAmount.rupiah
        return "plan.goal.label \(goal.name) \(saved, format: .rupiah) \(target, format: .rupiah)"
    }
}
