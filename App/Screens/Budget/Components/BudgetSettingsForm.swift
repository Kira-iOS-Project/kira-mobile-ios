/**
 Atur Budget's form, top to bottom as on its board: Tanggal Gajian and the period it gives; the
 allocation summary; Per Kategori; Pos Tujuan when there is a Dana Darurat goal; the note on the
 averages; Simpan Budget.
 */
import Domain
import Features
import SwiftUI

struct BudgetSettingsForm: View {
    @Bindable var model: BudgetSettingsModel
    let setup: BudgetSetup
    @State private var picksPayday = false

    var body: some View {
        KiraSectionTitle("budget.set.payday")
        BudgetPaydayRow(payday: model.payday, isPicking: picksPayday) { picksPayday = true }
            .kiraPaydayPicker(isPresented: $picksPayday, payday: $model.payday)
        Text("budget.set.payday.note \(BudgetPeriodText.range(model.period))")
            .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            .padding(.horizontal, KiraSpacing.space1)
        BudgetAllocationSummary(
            allocated: model.allocated, income: setup.income, unallocated: model.unallocated,
            instalments: setup.instalments)
        KiraSectionTitle("budget.set.categories", trailing: .note("budget.set.categories.note"))
            .padding(.top, KiraSpacing.space2)
        ForEach(setup.categories, id: \.self) { category in
            BudgetCategoryField(
                category: category, average: setup.averages[category] ?? 0,
                amount: Binding(get: { model.amounts[category] ?? "" }, set: { model.amounts[category] = $0 }))
        }
        if let deposit = setup.goalDeposit {
            KiraListGroup("budget.set.goal", footer: "budget.set.goal.footer") {
                KiraListRow(Text("budget.set.goal.emergency"), leading: .category(.emergency), trailing: .none) {
                    KiraTag("budget.set.goal.tag", tone: .pandan, icon: .lock)
                }
                .subtitle(Text("budget.set.goal.subtitle")).amount(KiraAmount(deposit.rupiah))
            }
        }
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            KiraIcon(.calculator, size: 16).accessibilityHidden(true)
            Text("budget.set.averages.note")
        }
        .font(.footnote).foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
        KiraButton("budget.set.save") { Task { await model.save() } }.block().disabled(model.isSaving)
            .padding(.top, KiraSpacing.space2)
    }
}

/** Tanggal Gajian's row: "Setiap Tanggal 25" between the calendar and the chevron; it opens the picker. */
private struct BudgetPaydayRow: View {
    let payday: Payday
    let isPicking: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: KiraSpacing.space3) {
                KiraIcon(.calendar, size: 22).foregroundStyle(.pandan)
                PaydayName(payday: payday).font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronDown, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space4)
            .frame(minHeight: 52)
            .background(.surfaceRaised, in: RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
                    .strokeBorder(isPicking ? Color.pandan : .hairline, lineWidth: 1.5)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("budget.set.payday"))
        .accessibilityValue(PaydayName(payday: payday).text)
    }
}

/** Teralokasi out of the income, the salary icon beside it, and the ribbon of what is left. */
private struct BudgetAllocationSummary: View {
    let allocated: Int
    let income: Int
    let unallocated: Int
    let instalments: Int

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("budget.set.allocated").font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
                    KiraAmount(allocated.rupiah, size: .large)
                    Text("budget.set.income \(Text(income.rupiah, format: .rupiah))")
                        .font(.footnote).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraCategoryIcon(.salary, size: 52).accessibilityHidden(true)
            }
            KiraProgressRibbon(value: Double(allocated), target: Double(income)).caption(caption)
        }
        .padding(EdgeInsets(top: 18, leading: 18, bottom: 16, trailing: 18))
        .kiraCard()
        .accessibilityElement(children: .combine)
    }

    private var caption: LocalizedStringResource {
        let left = Text(unallocated.rupiah, format: .rupiah)
        return instalments > 0
            ? "budget.set.unallocated.instalments \(left) \(Text(instalments.rupiah, format: .rupiah))"
            : "budget.set.unallocated \(left)"
    }
}

/** One category: its icon, then its amount, with "Rata-rata 3 bulan" under it. */
private struct BudgetCategoryField: View {
    let category: TransactionCategory
    let average: Int
    @Binding var amount: String

    var body: some View {
        HStack(alignment: .top, spacing: KiraSpacing.space3) {
            KiraCategoryIcon(category.tile, size: 40).padding(.top, 26).accessibilityHidden(true)
            KiraField(category.title, text: $amount)
                .prefix("budget.set.currency").suffix("budget.set.cents").amount()
                .hint("budget.set.average \(Text(average.rupiah, format: .rupiah))")
                .keyboardType(.numberPad)
        }
    }
}
