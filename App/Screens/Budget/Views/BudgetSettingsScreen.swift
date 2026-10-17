/**
 Atur Budget (UNG-05, KIR-39, board AturBudget): Tanggal Gajian (its picker, UNG-05d, is the shared
 Pilih Tanggal Gajian) and the period it gives; Teralokasi out of the income; Per Kategori, each
 amount beside its three-period average; Pos Tujuan, the Dana Darurat deposit Rencana sets; then
 "Simpan Budget", with Budget Tersimpan (UNG-05b) or Belum Berhasil Menyimpan (UNG-05c) over it.
 */
import Domain
import Features
import SwiftUI

struct BudgetSettingsScreen: View {
    @State private var model: BudgetSettingsModel
    let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(model: BudgetSettingsModel, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "budget.set.title", subtitle: BudgetPeriodText.range(model.period),
                    leading: .back("budget.set.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.vertical, KiraSpacing.space2)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 36, y: -22)
                    .accessibilityHidden(true)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .budgetSaveSuccessDialog(isPresented: saved)
        .budgetSaveFailureDialog(failure: $model.failure) { Task { await model.save() } }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        case .loaded(let setup):
            BudgetSettingsForm(model: model, setup: setup)
        }
    }

    /** Budget Tersimpan; Selesai closes it and goes back to Budget. */
    private var saved: Binding<Bool> {
        Binding(
            get: { model.showsSaved },
            set: {
                model.showsSaved = $0
                if !$0 { dismiss() }
            })
    }
}

/** "25 September – 24 Oktober 2026": the year once when both ends share it. */
enum BudgetPeriodText {
    static func range(_ period: PayPeriod) -> LocalizedStringResource {
        let end = period.end.date.formatted(.kiraDate)
        let start =
            period.start.year == period.end.year
            ? period.start.date.formatted(.kiraDayMonth) : period.start.date.formatted(.kiraDate)
        return "budget.set.period \(start) \(end)"
    }
}
