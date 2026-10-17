/** Budget (KIR-38): current allocations and spending in the server-resolved period. */
import APIClient
import Features
import SwiftUI

struct BudgetScreen: View {
    @State private var model: BudgetModel
    @State private var isEditing = false
    private let service: any BudgetService

    init(service: any BudgetService) {
        self.service = service
        _model = State(initialValue: BudgetModel(service: service))
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                BudgetOverviewContent(budget: .placeholder, onEdit: {})
                    .redacted(reason: .placeholder).disabled(true)
            case .empty:
                BudgetEmptyContent(retry: reload)
            case .loaded(let budget):
                BudgetOverviewContent(budget: budget) { isEditing = true }
                    .kiraSheet(isPresented: $isEditing, title: "budget.edit.title", subtitle: "budget.edit.subtitle") {
                        BudgetEditorForm(
                            budget: budget, service: service,
                            onSaved: {
                                isEditing = false
                                reload()
                            }, onCancel: { isEditing = false })
                    }
            case .failed(let problem):
                LoadFailedView(title: "budget.failed", problem: problem, retry: reload)
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    private func reload() { Task { await model.load() } }
}

private struct BudgetEmptyContent: View {
    let retry: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.care, size: 112)
            Text("budget.empty").font(.headline).foregroundStyle(.ink)
            KiraButton("budget.retry", action: retry).icon(.refresh)
        }
        .padding(KiraSpacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
