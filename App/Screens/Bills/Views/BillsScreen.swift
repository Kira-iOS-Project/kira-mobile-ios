/**
 Tagihan & Cicilan (UNG-06, board Tagihan): how many recurring bills and what they cost a month,
 then 7 Hari ke Depan, Bulan Ini and Bulan Depan with each row's tag, and Tambah Tagihan. A bill row
 opens Ubah Tagihan, an instalment its debt (Detail Utang). It loads again whenever it reappears,
 so a bill added, changed or deleted shows at once.
 */
import Domain
import Features
import SwiftUI

struct BillsScreen: View {
    @State private var model: BillsModel
    private let onAdd: () -> Void
    private let onEdit: (Bill) -> Void
    private let onOpenDebt: (String) -> Void
    private let onHelp: () -> Void
    @Environment(\.dismiss) private var dismiss

    init(
        service: any BillService, onAdd: @escaping () -> Void, onEdit: @escaping (Bill) -> Void,
        onOpenDebt: @escaping (String) -> Void, onHelp: @escaping () -> Void
    ) {
        _model = State(initialValue: BillsModel(service: service))
        self.onAdd = onAdd
        self.onEdit = onEdit
        self.onOpenDebt = onOpenDebt
        self.onHelp = onHelp
    }

    var body: some View {
        GeometryReader { screen in
            ScrollView {
                VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                    KiraNavBar("bills.title", leading: .back("bills.back") { dismiss() }) {
                        KiraHelpButton(.icon, action: onHelp)
                    }
                    content
                    Spacer(minLength: 0)
                    KiraButton("bills.add", action: onAdd).icon(.plus).block()
                }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.vertical, KiraSpacing.space2)
                .frame(maxWidth: .infinity, minHeight: screen.size.height, alignment: .top)
            }
        }
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 36, y: 40).accessibilityHidden(true)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { Task { await model.load() } }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            BillsContent(overview: BillsPreviewData.board, model: model, open: { _ in })
                .redacted(reason: .placeholder).disabled(true)
        case .empty:
            BillsSummary(count: 0, monthlyTotal: 0)
        case .loaded(let overview):
            BillsContent(overview: overview, model: model, open: open)
        case .failed(let problem):
            LoadFailedView(title: "bills.failed", problem: problem) { Task { await model.load() } }
        }
    }

    private func open(_ bill: Bill) {
        if bill.kind == .instalment, let debtId = bill.debtId {
            onOpenDebt(debtId)
        } else {
            onEdit(bill)
        }
    }
}
