/** Budget per Kategori (KIR-38, board Budget): this pay period's money left and each category's use. */
import APIClient
import Features
import SwiftUI

struct BudgetScreen: View {
    @State private var model: BudgetModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any BudgetService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: BudgetModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                BudgetOverviewContent(budget: .placeholder) { _ in }
                    .redacted(reason: .placeholder).disabled(true)
            case .empty:
                BudgetEmptyContent(retry: reload)
            case .loaded(let budget):
                BudgetOverviewContent(budget: budget, onOpen: onOpen)
            case .failed(let problem):
                LoadFailedView(
                    title: "budget.failed", leading: .back("budget.back") { dismiss() }, problem: problem, retry: reload
                )
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
            KiraButton("budget.retry", action: retry)
        }
        .padding(KiraSpacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
