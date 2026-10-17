/**
 The frame of every Tujuan Baru form (boards TujuanDP … TujuanLainnya): "Tujuan Baru" with the goal
 as subtitle, the back button to the goal picker and the help button to Kira Peduli; the goal's
 26 pt title and line beside its large category icon; the form; then "Hanya Simulasi" and Hitung,
 pinned to the bottom when the form is short.
 */
import SwiftUI

struct GoalFormFrame<Content: View>: View {
    let goal: LocalizedStringResource
    let lead: LocalizedStringResource
    let category: KiraCategory
    var canCalculate = true
    let onCalculate: () -> Void
    let onHelp: () -> Void
    @ViewBuilder let content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    KiraNavBar(
                        "plan.goal.form.title", subtitle: goal, leading: .back("plan.goal.form.back") { dismiss() }
                    ) {
                        KiraHelpButton(.icon, action: onHelp)
                    }
                    header
                    content
                    Spacer(minLength: 0)
                    VStack(spacing: KiraSpacing.space3) {
                        KiraNotice(
                            .simulation, title: "plan.goal.simulation.title", message: "plan.goal.form.simulation")
                        KiraButton("plan.goal.form.calculate", action: onCalculate).block().disabled(!canCalculate)
                    }
                    .padding(.top, KiraSpacing.space2)
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space2)
                .padding(.bottom, KiraSpacing.space2)
                .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }

    /** The goal's name and line, the large category icon beside them. */
    private var header: some View {
        HStack(alignment: .center, spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text(goal)
                    .font(KiraFont.display(26, .heavy, relativeTo: .title))
                    .kiraLineHeight(31, size: 26, natural: 1.26, relativeTo: .title)
                    .tracking(-0.65)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(lead).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraCategoryIcon(category, size: 52).accessibilityHidden(true)
        }
        .padding(.leading, KiraSpacing.space1)
    }
}

/**
 "Strategi Investasimu", the part every goal form shares: Target Investasi per Bulan (rupiah, grouped
 while typing) and Return Investasi in percent per year, with the kind's hint under it.
 */
struct GoalStrategyFields: View {
    @Binding var deposit: String
    @Binding var annualReturn: String
    var returnLabel: LocalizedStringResource = "plan.goal.return"
    var returnHint: LocalizedStringResource? = "plan.goal.return.hint"

    var body: some View {
        KiraSectionTitle("plan.goal.strategy").padding(.top, KiraSpacing.space2)
        KiraField("plan.goal.deposit", text: $deposit)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount()
            .keyboardType(.numberPad)
        returnField
    }

    @ViewBuilder private var returnField: some View {
        let field = KiraField(returnLabel, text: $annualReturn).suffix("plan.goal.perYear")
        if let returnHint {
            field.hint(returnHint).keyboardType(.decimalPad)
        } else {
            field.keyboardType(.decimalPad)
        }
    }
}
