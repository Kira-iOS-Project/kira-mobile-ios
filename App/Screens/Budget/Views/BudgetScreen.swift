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
                BudgetEmptyContent(onSetUp: { onOpen(.editBudget) }, onBack: { dismiss() })
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
        /** Again on each return, so a budget just set in Atur Budget shows at once. */
        .task { await model.load() }
    }

    private func reload() { Task { await model.load() } }
}

/**
 No budget yet: what a budget does here and "Atur Budget" (UNG-05), which sets the income, the
 payday and each category's share; the way back the loaded screen shows (Kembali ke Beranda).
 */
private struct BudgetEmptyContent: View {
    let onSetUp: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            KiraNavBar("budget.title", leading: .back("budget.back") { onBack() })
            Spacer(minLength: KiraSpacing.space4)
            VStack(spacing: KiraSpacing.space2) {
                KiraIllustration(.piggyBank, size: 120).padding(.bottom, KiraSpacing.space2)
                Text("budget.empty")
                    .font(KiraFont.display(24, .heavy, relativeTo: .title2)).tracking(-0.4)
                    .foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                Text("budget.empty.body")
                    .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                    .frame(maxWidth: 300)
            }
            .multilineTextAlignment(.center)
            Spacer(minLength: KiraSpacing.space4)
            KiraButton("budget.empty.setUp", action: onSetUp).icon(.settings).block()
                .padding(.bottom, KiraSpacing.space2)
        }
        .padding(.horizontal, KiraSpacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
