/** The Atur Budget editor for income, category allocations, and payday. */
import Domain
import Features
import SwiftUI

struct BudgetEditorForm: View {
    @State private var model: BudgetEditorModel
    private let onSaved: () -> Void
    private let onCancel: () -> Void

    init(
        budget: BudgetOverview, service: any BudgetService, onSaved: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        _model = State(initialValue: BudgetEditorModel(budget: budget, service: service))
        self.onSaved = onSaved
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            if case .loaded = model.phase {
                ScrollView {
                    VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                        incomeField
                        BudgetPaydayMenu(payday: model.payday) { model.setPayday($0) }
                        if model.isOverallocated { BudgetOverallocationNotice() }
                        KiraSectionTitle("budget.categories")
                        ForEach(expenseCategories, id: \.self) { category in categoryField(category) }
                    }
                    .padding(.top, KiraSpacing.space2).padding(.bottom, KiraSpacing.space4)
                }
                .scrollBounceBehavior(.basedOnSize)
                actions
            }
        }
        .budgetSaveSuccessDialog(isPresented: saveSuccessPresented)
        .task { await model.loadAverages() }
    }

    private var expenseCategories: [TransactionCategory] {
        TransactionCategory.allCases.filter { $0.type == .expense }
    }

    private var incomeField: some View {
        KiraField(
            "budget.income",
            text: Binding(
                get: { model.incomeText }, set: { model.setIncomeText($0) })
        )
        .amount().prefix("transaction.field.currency").suffix("transaction.field.cents")
        .keyboardType(.numberPad)
    }

    private func amountBinding(_ category: TransactionCategory) -> Binding<String> {
        Binding(get: { model.amountText(for: category) }, set: { model.setAmountText($0, for: category) })
    }

    private func categoryField(_ category: TransactionCategory) -> some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            KiraField("budget.category.field \(category.title)", text: amountBinding(category))
                .amount().prefix("transaction.field.currency").suffix("transaction.field.cents")
                .keyboardType(.numberPad)
            if let average = model.averageAmount(for: category) {
                HStack {
                    Text("budget.average.periods \(model.averagePeriods)")
                        .font(.caption).foregroundStyle(.inkMuted)
                    Spacer(minLength: KiraSpacing.space2)
                    KiraAmount(Decimal(average), size: .small)
                }
                .padding(.horizontal, KiraSpacing.space3).accessibilityElement(children: .combine)
            }
        }
    }

    private var actions: some View {
        KiraButtonPair(
            secondary: KiraButton("budget.edit.cancel", variant: .secondary, size: .small, action: onCancel),
            primary: KiraButton("budget.edit.save", size: .small) { Task { await save() } }
        )
        .disabled(isSaving).padding(.vertical, KiraSpacing.space2)
    }

    private var isSaving: Bool {
        if case .saving = model.saveState { return true }
        return false
    }

    private func save() async {
        await model.save()
    }

    private var saveSuccessPresented: Binding<Bool> {
        Binding(
            get: {
                if case .saved = model.saveState { return true }
                return false
            },
            set: { presented in
                guard !presented else { return }
                model.dismissResult()
                onSaved()
            })
    }
}
