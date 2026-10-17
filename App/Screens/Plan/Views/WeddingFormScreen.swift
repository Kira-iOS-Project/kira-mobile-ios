/**
 REN-02d, Tujuan Baru · Menikah (board TujuanMenikah): Anggaran Pernikahan (Rinci or Sederhana; the
 example budgets and their sources; the twelve rows, each opening its price sheet; Total Anggaran),
 Mimpimu and Strategi Investasimu. Hitung opens the result (REN-04e).
 */
import Domain
import Features
import SwiftUI

struct WeddingFormScreen: View {
    @State private var model: WeddingFormModel
    @State private var result: WeddingGoal?
    private let service: any GoalService
    private let onOpen: (AppRoute) -> Void

    init(service: any GoalService, model: WeddingFormModel = WeddingFormModel(), onOpen: @escaping (AppRoute) -> Void) {
        self.service = service
        self.onOpen = onOpen
        _model = State(initialValue: model)
    }

    var body: some View {
        GoalFormFrame(
            goal: "plan.wedding.goal", lead: "plan.wedding.lead", category: .wedding, canCalculate: model.canCalculate,
            onCalculate: { result = model.result }, onHelp: { onOpen(.care) },
            content: {
                KiraSectionTitle("plan.wedding.budget").padding(.top, KiraSpacing.space2)
                WeddingBudgetFields(model: model)
                KiraSectionTitle("plan.goal.dream").padding(.top, KiraSpacing.space2)
                KiraField("plan.wedding.years", text: $model.years).suffix("plan.goal.yearsAhead")
                    .keyboardType(.numberPad)
                KiraField("plan.wedding.inflation", text: $model.inflation).suffix("plan.goal.perYear")
                    .keyboardType(.decimalPad)
                KiraField("plan.wedding.present", text: $model.present)
                    .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
                GoalStrategyFields(deposit: $model.deposit, annualReturn: $model.annualReturn)
            }
        )
        .navigationDestination(isPresented: showsResult) {
            if let result {
                WeddingResultScreen(goal: result, preset: model.preset, service: service, onOpen: onOpen)
            }
        }
        .kiraSheet(isPresented: editing, title: model.editing?.title ?? "plan.wedding.venue") {
            WeddingItemSheet(model: model)
        }
    }

    private var showsResult: Binding<Bool> {
        Binding(get: { result != nil }, set: { if !$0 { result = nil } })
    }

    private var editing: Binding<Bool> {
        Binding(get: { model.editing != nil }, set: { if !$0 { model.cancelEdit() } })
    }
}

/** Tipe Budgeting, then Rinci's examples and rows or Sederhana's total. */
private struct WeddingBudgetFields: View {
    @Bindable var model: WeddingFormModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("plan.wedding.budgeting")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            KiraSegmented(
                "plan.wedding.budgeting",
                options: [
                    .init(id: WeddingFormModel.Budgeting.detailed, title: "plan.wedding.detailed"),
                    .init(id: WeddingFormModel.Budgeting.simple, title: "plan.wedding.simple"),
                ],
                selection: $model.budgeting)
        }
        switch model.budgeting {
        case .detailed: detailed
        case .simple:
            KiraField("plan.wedding.total", text: $model.simpleTotal)
                .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
        }
    }

    @ViewBuilder private var detailed: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("plan.wedding.examples")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            KiraFlowRow {
                ForEach(WeddingPreset.allCases, id: \.self) { preset in
                    KiraChip(preset.title, isSelected: model.preset == preset) { model.use(preset) }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("plan.wedding.examples.label"))
            Text("plan.wedding.examples.source")
                .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
        }
        KiraListGroup(footer: "plan.wedding.rows.footer") {
            ForEach(model.items, id: \.kind) { item in
                row(item)
            }
            KiraListRow(Text("plan.wedding.total"), leading: .icon(.calculator))
                .amount(KiraAmount(model.total.rupiah))
        }
        .accessibilityLabel(Text("plan.wedding.rows"))
    }

    private func row(_ item: WeddingItem) -> some View {
        let row = KiraListRow(Text(item.kind.title), trailing: .chevron) { model.edit(item.kind) }
            .amount(KiraAmount(item.total.rupiah))
        guard item.kind.isPerGuest else { return row }
        return row.subtitle(Text("plan.wedding.perGuest \(item.guests) \(GoalCopy.rupiah(item.price))"))
    }
}

/** A row's price sheet: the price (and the guests for a per-guest row), Batal and Simpan. */
private struct WeddingItemSheet: View {
    @Bindable var model: WeddingFormModel

    var body: some View {
        VStack(spacing: 14) {
            if model.editing?.isPerGuest == true {
                KiraField("plan.wedding.guests", text: $model.editGuests).suffix("plan.wedding.pax")
                    .keyboardType(.numberPad)
                KiraField("plan.wedding.pricePerGuest", text: $model.editPrice)
                    .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
            } else {
                KiraField("plan.wedding.price", text: $model.editPrice)
                    .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
            }
            KiraButtonPair(
                secondary: KiraButton("plan.wedding.cancel", variant: .secondary) { model.cancelEdit() },
                primary: KiraButton("plan.wedding.save") { model.saveEdit() })
        }
    }
}
