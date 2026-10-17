/**
 Tangga Keuanganmu (REN-01): the four steps the engine reports, each with its number badge, title
 and line. A step in progress carries "Sedang Berjalan" (with what the API names, "Paylater A"), a
 done one "Sudah Aman"; step 2 shows the emergency fund's progress. Step 4 is a suggestion, never
 locked. The note under it says the order is a guide, not a rule.
 */
import Domain
import SwiftUI

struct PlanLadderCard: View {
    let ladder: [LadderStep]
    let emergency: GoalSummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                    Text("plan.ladder.overline").kiraFont(.overline).foregroundStyle(.pandan)
                    Text("plan.ladder.title").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                    Text("plan.ladder.body").font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIllustration(.stairs, size: 80).padding(.top, -4).padding(.trailing, -4)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(ladder, id: \.step) { step in
                    PlanLadderRow(step: step, emergency: emergency, isLast: step.step == ladder.last?.step)
                }
            }
            Text("plan.ladder.note").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.top, KiraSpacing.space3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, KiraSpacing.space4)
        .kiraCard()
    }
}

/** One step: its badge on the line that joins the steps, and its words. */
private struct PlanLadderRow: View {
    let step: LadderStep
    let emergency: GoalSummary?
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            PlanLadderBadge(step: step)
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title).font(.body.weight(.semibold)).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                if let line = step.line {
                    Text(line).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
                if step.key == .emergencyFund, let emergency, emergency.targetAmount > 0 {
                    KiraProgressRibbon(value: Double(emergency.savedAmount), target: Double(emergency.targetAmount))
                        .padding(.top, 10)
                } else if let tag = step.tag {
                    tag.padding(.top, KiraSpacing.space2)
                }
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(step.accessibilityLabel)
        }
        .padding(.bottom, isLast ? 0 : 20)
        .background(alignment: .topLeading) {
            if !isLast {
                RoundedRectangle(cornerRadius: 1).fill(.line).frame(width: 2)
                    .padding(.top, 36).padding(.bottom, 4).padding(.leading, 15)
                    .accessibilityHidden(true)
            }
        }
    }
}

/** The step's 32 pt badge: its number, or a check once done. */
private struct PlanLadderBadge: View {
    let step: LadderStep

    var body: some View {
        Group {
            if step.status == .done {
                KiraIcon(.check, size: 18, weight: .bold).foregroundStyle(.healthy)
            } else {
                Text(step.step, format: .number).font(KiraFont.display(15, .heavy, relativeTo: .subheadline))
                    .foregroundStyle(numberColor)
            }
        }
        .frame(width: 32, height: 32)
        .background(fill, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .strokeBorder(border, lineWidth: border == .clear ? 0 : 1)
        }
        .accessibilityHidden(true)
    }

    /** In progress: solid pandan; next: pandan-soft; done: healthy; step 4, a suggestion: muted. */
    private var fill: Color {
        switch (step.status, step.key) {
        case (.current, _): .pandan
        case (.done, _): .healthySoft
        case (.todo, .investing): .surfaceMuted
        case (.todo, _): .pandanSoft
        }
    }

    private var border: Color {
        switch (step.status, step.key) {
        case (.current, _): .clear
        case (.done, _): .healthyLine
        case (.todo, .investing): .hairline
        case (.todo, _): .pandanLine
        }
    }

    private var numberColor: Color {
        switch (step.status, step.key) {
        case (.current, _): .onPandan
        case (.todo, .investing): .inkMuted
        default: .pandan
        }
    }
}
