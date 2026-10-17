/**
 Atur Jenjang (REN-02i, board TujuanPendidikanJenjang): Daerah and Jenis Sekolah, Uang Pangkal, Uang
 Sekolah and how often it is paid, Biaya Lain-lain; Batal beside Simpan Jenjang. The chips label the
 stage; the board gives no price table per region and school, so the figures stay as typed.
 */
import Domain
import Features
import SwiftUI

struct EducationStageScreen: View {
    let stage: EducationStage
    let onSave: (EducationStageValues) -> Void
    @State private var values: EducationStageValues
    @Environment(\.dismiss) private var dismiss

    init(stage: EducationStage, values: EducationStageValues, onSave: @escaping (EducationStageValues) -> Void) {
        self.stage = stage
        self.onSave = onSave
        _values = State(initialValue: values)
    }

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    KiraNavBar(
                        "plan.education.stage.title", subtitle: stage.title,
                        leading: .close("plan.education.stage.close") { dismiss() }
                    ) {
                        EmptyView()
                    }
                    fields
                    Spacer(minLength: 0)
                    footer.padding(.top, KiraSpacing.space2)
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.vertical, KiraSpacing.space2)
                .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder private var fields: some View {
        EducationChips("plan.education.region", choices: EducationRegion.allCases, selection: $values.region) {
            $0.title
        }
        EducationChips("plan.education.school", choices: EducationSchool.allCases, selection: $values.school) {
            $0.title
        }
        KiraField("plan.education.entryFee", text: $values.entryFee)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        KiraField("plan.education.fee", text: $values.fee)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        EducationLabeled("plan.education.feePeriod") {
            KiraSegmented(
                "plan.education.feePeriod",
                options: [FeePeriod.month, .semester, .year].map { .init(id: $0, title: $0.title) },
                selection: $values.feePeriod)
        }
        KiraField("plan.education.other", text: $values.otherRate).suffix("plan.education.other.suffix")
            .hint("plan.education.other.hint").keyboardType(.decimalPad)
    }

    private var footer: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraNotice(.info, message: notice)
            WeightedRow(weights: [1, 1.3], spacing: 10) {
                KiraButton("plan.education.stage.cancel", variant: .secondary) { dismiss() }.block()
                KiraButton("plan.education.stage.save") {
                    onSave(values)
                    dismiss()
                }
                .block().disabled(!values.isValid)
            }
        }
    }

    /** "Angka awal dari perkiraan rata-rata SD swasta di Jakarta. …" */
    private var notice: LocalizedStringResource {
        let stageName = String(localized: stage.shortTitle)
        let school = String(localized: values.school.title).lowercased()
        let region = String(localized: values.region.title)
        return "plan.education.stage.notice \(stageName) \(school) \(region)"
    }
}

/** One choice of Atur Jenjang as chips under its label. */
private struct EducationChips<Choice: Hashable>: View {
    let label: LocalizedStringResource
    let choices: [Choice]
    @Binding var selection: Choice
    let title: (Choice) -> LocalizedStringResource

    init(
        _ label: LocalizedStringResource, choices: [Choice], selection: Binding<Choice>,
        title: @escaping (Choice) -> LocalizedStringResource
    ) {
        self.label = label
        self.choices = choices
        _selection = selection
        self.title = title
    }

    var body: some View {
        EducationLabeled(label) {
            KiraFlowRow(spacing: 8) {
                ForEach(choices, id: \.self) { choice in
                    KiraChip(title(choice), isSelected: selection == choice) { selection = choice }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(label))
        }
    }
}
