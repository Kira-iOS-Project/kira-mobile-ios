/**
 The fields Tambah Tagihan and Ubah Tagihan share: Nama, Jumlah (grouped while typing, with the
 estimate hint), Kategori as four tiles, Ulangi, Tanggal (opens Pilih Tanggal), and Ini Cicilan
 Utang, whose toggle lists the debt accounts from Dompet to link. Tanggal is BillDateField.
 */
import Domain
import Features
import SwiftUI

struct BillFormFields: View {
    @Bindable var model: BillFormModel

    var body: some View {
        KiraField("bills.add.name", text: $model.name, prompt: "bills.add.name.prompt")
        KiraField("bills.add.amount", text: $model.amount, prompt: "bills.add.amount.prompt")
            .prefix("bills.add.currency").suffix("bills.add.cents").amount().hint("bills.add.amount.hint")
            .keyboardType(.numberPad)
        BillCategoryTiles(selection: $model.category)
        VStack(alignment: .leading, spacing: 6) {
            Text("bills.add.repeat").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            KiraSegmented(
                "bills.add.repeat",
                options: BillRepeat.allCases.map { KiraSegmented.Option(id: $0, title: $0.title) },
                selection: $model.repeats)
        }
        BillDateField(dueOn: $model.dueOn, repeats: model.repeats)
        BillDebtLink(model: model)
    }
}

/** Kategori: Tagihan, Hiburan, Kesehatan, Lainnya, each an illustration over its name; one chosen. */
private struct BillCategoryTiles: View {
    @Binding var selection: BillCategory
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("bills.add.category").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
                .accessibilityAddTraits(.isHeader)
            /** Four to a row as on the board; two at the accessibility sizes so each name keeps one line. */
            let columns = typeSize.isAccessibilitySize ? 2 : 4
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: KiraSpacing.space2), count: columns),
                spacing: KiraSpacing.space2
            ) {
                ForEach(BillCategory.allCases, id: \.self, content: tile)
            }
        }
    }

    private func tile(_ category: BillCategory) -> some View {
        let isOn = category == selection
        return Button {
            selection = category
        } label: {
            VStack(spacing: 6) {
                KiraCategoryIcon(category.ledger.tile).accessibilityHidden(true)
                Text(category.ledger.title)
                    .font(.caption.weight(isOn ? .bold : .medium)).kiraLineHeight(16, size: 12)
                    .foregroundStyle(isOn ? Color.pandan : .inkMuted).multilineTextAlignment(.center)
            }
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .background(
                isOn ? Color.pandanSoft : .clear,
                in: RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
                    .strokeBorder(isOn ? Color.pandan : .clear, lineWidth: 1.5)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }
}

/** Hubungkan ke Akun Utang: the toggle, then the debt accounts to choose from while it is on. */
private struct BillDebtLink: View {
    @Bindable var model: BillFormModel

    var body: some View {
        KiraListGroup("bills.add.debt.group") {
            KiraListRow(Text("bills.add.debt"), leading: .icon(.link), trailing: .toggle($model.isInstalment))
                .subtitle(Text("bills.add.debt.subtitle"))
            if model.isInstalment {
                if model.debts.isEmpty {
                    KiraListRow(Text("bills.add.debt.none"), leading: .icon(.info), trailing: .none)
                } else {
                    ForEach(model.debts) { debt in
                        KiraListRow(Text(debt.name), leading: .icon(.card), trailing: .check(model.debtId == debt.id)) {
                            model.debtId = debt.id
                        }
                    }
                }
            }
        }
    }
}

extension BillCategory {
    /** The ledger category whose tile and name the form shows. */
    var ledger: TransactionCategory {
        switch self {
        case .bills: .bills
        case .entertainment: .entertainment
        case .health: .health
        case .other: .otherExpense
        }
    }
}

extension BillRepeat {
    /** "Sekali", "Bulanan", "Tahunan". */
    var title: LocalizedStringResource {
        switch self {
        case .once: "bills.add.repeat.once"
        case .monthly: "bills.add.repeat.monthly"
        case .yearly: "bills.add.repeat.yearly"
        }
    }
}
