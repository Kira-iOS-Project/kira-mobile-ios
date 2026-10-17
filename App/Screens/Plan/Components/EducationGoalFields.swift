/**
 The sections of Tujuan Baru · Pendidikan Anak (board TujuanPendidikan): Tentang Anakmu, Rencana
 Pendidikan with its stage range and Biaya per jenjang, Kondisi Keuanganmu, and the strategy with
 Sudah Tahu Mau Investasi di Mana? (Belum hides the return and counts 0%).
 */
import Domain
import Features
import SwiftUI

/** Tentang Anakmu: Nama Anak beside Usia Saat Ini. */
struct EducationChildFields: View {
    @Bindable var model: EducationGoalModel

    var body: some View {
        KiraSectionTitle("plan.education.child").padding(.top, KiraSpacing.space2)
        WeightedRow(weights: [1, 1], spacing: 10) {
            KiraField("plan.education.childName", text: $model.childName)
            KiraField("plan.education.childAge", text: $model.childAge).suffix("plan.education.years")
                .keyboardType(.numberPad)
        }
    }
}

/** Rencana Pendidikan: the stage range, then Biaya per jenjang. */
struct EducationStageFields: View {
    @Bindable var model: EducationGoalModel
    let onEdit: (EducationStage) -> Void

    var body: some View {
        KiraSectionTitle("plan.education.plan").padding(.top, KiraSpacing.space2)
        WeightedRow(weights: [1, 1], spacing: 10) {
            EducationStagePicker(label: "plan.education.first", selection: $model.firstStage)
            EducationStagePicker(label: "plan.education.last", selection: $model.lastStage)
        }
        KiraListGroup("plan.education.costs", footer: "plan.education.costs.footer") {
            ForEach(model.stages, id: \.self) { stage in
                KiraListRow(Text(stage.title), leading: .icon(.book), trailing: .chevron) { onEdit(stage) }
                    .subtitle(Text(model.values(for: stage).summary))
            }
        }
    }
}

/** A read-only field with a chevron that opens the four stages. */
private struct EducationStagePicker: View {
    let label: LocalizedStringResource
    @Binding var selection: EducationStage

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                ForEach(EducationStage.allCases, id: \.self) { Text($0.title).tag($0) }
            } label: {
                Text(label)
            }
        } label: {
            KiraField(label, text: .constant(String(localized: selection.title))).icon(.chevronDown)
                .allowsHitTesting(false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(selection.title))
    }
}

/** Kondisi Keuanganmu: income, what is collected, and education inflation. */
struct EducationMoneyFields: View {
    @Bindable var model: EducationGoalModel

    var body: some View {
        KiraSectionTitle("plan.education.money").padding(.top, KiraSpacing.space2)
        KiraField("plan.education.income", text: $model.income)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        KiraField("plan.education.present", text: $model.present)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        KiraField("plan.education.inflation", text: $model.inflation).suffix("plan.goal.perYear")
            .hint("plan.education.inflation.hint").keyboardType(.decimalPad)
    }
}

/** Strategi Investasimu with Sudah Tahu Mau Investasi di Mana? between deposit and return. */
struct EducationStrategyFields: View {
    @Bindable var model: EducationGoalModel

    var body: some View {
        KiraSectionTitle("plan.goal.strategy").padding(.top, KiraSpacing.space2)
        KiraField("plan.goal.deposit", text: $model.deposit)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        EducationLabeled("plan.education.knows") {
            KiraSegmented(
                "plan.education.knows",
                options: [
                    .init(id: false, title: "plan.education.knows.no"),
                    .init(id: true, title: "plan.education.knows.yes"),
                ],
                selection: $model.knowsWhere)
        }
        if model.knowsWhere {
            KiraField("plan.education.return", text: $model.annualReturn).suffix("plan.goal.perYear")
                .hint("plan.education.return.hint").keyboardType(.decimalPad)
        }
    }
}

/** A control under its muted label, as the boards draw Segmented and chip groups. */
struct EducationLabeled<Control: View>: View {
    let label: LocalizedStringResource
    @ViewBuilder let control: Control

    init(_ label: LocalizedStringResource, @ViewBuilder control: () -> Control) {
        self.label = label
        self.control = control()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            control
        }
    }
}
