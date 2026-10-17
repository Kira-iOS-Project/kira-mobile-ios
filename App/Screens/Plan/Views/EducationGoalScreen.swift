/**
 Tujuan Baru · Pendidikan Anak (REN-02c, board TujuanPendidikan): Tentang Anakmu, Rencana Pendidikan
 (Jenjang Awal and Akhir, then each stage's costs, a tap opening Atur Jenjang), Kondisi Keuanganmu,
 then the strategy with Sudah Tahu Mau Investasi di Mana?. Hitung opens Hasil Simulasi without saving.
 */
import Domain
import Features
import SwiftUI

struct EducationGoalScreen: View {
    @State private var model: EducationGoalModel
    @State private var result: EducationGoalOutcome?
    @State private var editing: EducationStage?
    let onOpen: (AppRoute) -> Void
    /** Jadikan Pos Budget on the result: the caller creates the goal. */
    var onBudget: (EducationGoalOutcome) -> Void = { _ in }

    init(
        model: EducationGoalModel = EducationGoalModel(), onOpen: @escaping (AppRoute) -> Void,
        onBudget: @escaping (EducationGoalOutcome) -> Void = { _ in }
    ) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
        self.onBudget = onBudget
    }

    var body: some View {
        GoalFormFrame(
            goal: "plan.education.title", lead: "plan.education.lead", category: .education,
            canCalculate: model.canCalculate, onCalculate: { result = model.outcome }, onHelp: { onOpen(.care) }
        ) {
            EducationChildFields(model: model)
            EducationStageFields(model: model, onEdit: { editing = $0 })
            EducationMoneyFields(model: model)
            EducationStrategyFields(model: model)
        }
        .navigationDestination(isPresented: Binding(get: { result != nil }, set: { if !$0 { result = nil } })) {
            if let result { EducationGoalResultScreen(outcome: result, onOpen: onOpen) { onBudget(result) } }
        }
        .navigationDestination(isPresented: Binding(get: { editing != nil }, set: { if !$0 { editing = nil } })) {
            if let editing {
                EducationStageScreen(stage: editing, values: model.values(for: editing)) { model.save($0, for: editing) }
            }
        }
    }
}

/** Tentang Anakmu: Nama Anak beside Usia Saat Ini. */
private struct EducationChildFields: View {
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
private struct EducationStageFields: View {
    @Bindable var model: EducationGoalModel
    let onEdit: (EducationStage) -> Void

    var body: some View {
        KiraSectionTitle("plan.education.plan").padding(.top, KiraSpacing.space2)
        WeightedRow(weights: [1, 1], spacing: 10) {
            StagePicker(label: "plan.education.first", selection: $model.firstStage)
            StagePicker(label: "plan.education.last", selection: $model.lastStage)
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
private struct StagePicker: View {
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
private struct EducationMoneyFields: View {
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
private struct EducationStrategyFields: View {
    @Bindable var model: EducationGoalModel

    var body: some View {
        KiraSectionTitle("plan.goal.strategy").padding(.top, KiraSpacing.space2)
        KiraField("plan.goal.deposit", text: $model.deposit)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        VStack(alignment: .leading, spacing: 6) {
            Text("plan.education.knows").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            KiraSegmented(
                "plan.education.knows",
                options: [.init(id: false, title: "plan.education.knows.no"), .init(id: true, title: "plan.education.knows.yes")],
                selection: $model.knowsWhere)
        }
        if model.knowsWhere {
            KiraField("plan.education.return", text: $model.annualReturn).suffix("plan.goal.perYear")
                .hint("plan.education.return.hint").keyboardType(.decimalPad)
        }
    }
}

/**
 Atur Jenjang (REN-02i, board TujuanPendidikanJenjang): Daerah and Jenis Sekolah, Uang Pangkal, Uang
 Sekolah and how often it is paid, Biaya Lain-lain; Batal beside Simpan Jenjang. The chips label the
 stage; the board gives no price table per region and school, so the figures stay as typed.
 */
struct EducationStageScreen: View {
    let stage: EducationStage
    @State var values: EducationStageValues
    let onSave: (EducationStageValues) -> Void
    @Environment(\.dismiss) private var dismiss

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
                    chips("plan.education.region", EducationRegion.allCases, selection: $values.region, title: \.title)
                    chips("plan.education.school", EducationSchool.allCases, selection: $values.school, title: \.title)
                    KiraField("plan.education.entryFee", text: $values.entryFee)
                        .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
                    KiraField("plan.education.fee", text: $values.fee)
                        .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("plan.education.feePeriod").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                            .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
                        KiraSegmented(
                            "plan.education.feePeriod",
                            options: [FeePeriod.month, .semester, .year].map { .init(id: $0, title: $0.title) },
                            selection: $values.feePeriod)
                    }
                    KiraField("plan.education.other", text: $values.otherRate).suffix("plan.education.other.suffix")
                        .hint("plan.education.other.hint").keyboardType(.decimalPad)
                    Spacer(minLength: 0)
                    VStack(spacing: KiraSpacing.space3) {
                        KiraNotice(
                            .info,
                            message: "plan.education.stage.notice \(String(localized: stage.shortTitle)) \(String(localized: values.school.title).lowercased()) \(String(localized: values.region.title))"
                        )
                        WeightedRow(weights: [1, 1.3], spacing: 10) {
                            KiraButton("plan.education.stage.cancel", variant: .secondary) { dismiss() }.block()
                            KiraButton("plan.education.stage.save") {
                                onSave(values)
                                dismiss()
                            }
                            .block().disabled(!values.isValid)
                        }
                    }
                    .padding(.top, KiraSpacing.space2)
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

    private func chips<Choice: Hashable>(
        _ label: LocalizedStringResource, _ choices: [Choice], selection: Binding<Choice>,
        title: KeyPath<Choice, LocalizedStringResource>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            KiraFlowRow(spacing: 8) {
                ForEach(choices, id: \.self) { choice in
                    KiraChip(choice[keyPath: title], isSelected: selection.wrappedValue == choice) {
                        selection.wrappedValue = choice
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(label))
        }
    }
}

extension EducationStage {
    /** "SD", "SMP", "SMA", "S1", as Atur Jenjang's notice names them. */
    var shortTitle: LocalizedStringResource {
        switch self {
        case .primary: "plan.education.stage.primary.short"
        case .juniorHigh: "plan.education.stage.juniorHigh.short"
        case .seniorHigh: "plan.education.stage.seniorHigh.short"
        case .bachelor: "plan.education.stage.bachelor.short"
        }
    }
}
