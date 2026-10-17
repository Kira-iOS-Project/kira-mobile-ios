/**
 One question of Kenali Profil Risikomu (boards KuisRisiko to KuisRisiko5): the close button and
 Kira Peduli's, "Pertanyaan N dari 5", the ladder notice on the first question while the emergency
 fund is below its target, the question, four single-choice rows with the footer, then Kembali and
 Lanjut (Lihat Hasil on the last), 1 to 1.3. Lanjut waits for a choice, and for the save.
 */
import Domain
import Features
import SwiftUI

struct RiskQuestionView: View {
    let question: RiskQuestion
    let context: RiskQuizContext
    let model: RiskQuizModel
    let onOpen: (AppRoute) -> Void
    let onClose: () -> Void

    var body: some View {
        PlanScreenFrame {
            KiraNavBar("plan.risk.title", leading: .close("plan.risk.close", onClose)) {
                KiraHelpButton(.icon) { onOpen(.care) }
            }
            KiraStepProgress(
                current: question.number, total: RiskQuestion.total,
                label: "plan.risk.progress \(question.number) \(RiskQuestion.total)")
            if question == .goal, let ladder = context.ladder {
                let multiple = Self.multiple(ladder.multiple)
                let target = Self.multiple(Double(ladder.target))
                KiraNotice(
                    .info, title: "plan.risk.ladder.title", message: "plan.risk.ladder.body \(multiple) \(target)",
                    icon: .target)
            }
            PlanHeading(title: question.title, subtitle: question.subtitle(income: context.monthlyIncome))
            options
            Spacer(minLength: KiraSpacing.space2)
            PlanButtonRow(
                secondary: KiraButton("plan.risk.back", variant: .secondary) { model.back() },
                primary: KiraButton(question.next == nil ? "plan.risk.seeResult" : "plan.risk.next") {
                    Task { await model.next() }
                },
                isPrimaryDisabled: !model.canContinue)
        }
    }

    private var options: some View {
        let choice = model.choice(for: question)
        let labels = question.options(context.depositRanges)
        return KiraListGroup(footer: "plan.risk.footer") {
            ForEach(labels.indices, id: \.self) { index in
                KiraListRow(Text(labels[index]), trailing: .check(choice == index)) { model.choose(index) }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("plan.risk.options"))
    }

    /** A multiple as the board writes it: "1,1×", "6×". */
    private static func multiple(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)).locale(Locale(identifier: "id_ID"))) + "×"
    }
}
