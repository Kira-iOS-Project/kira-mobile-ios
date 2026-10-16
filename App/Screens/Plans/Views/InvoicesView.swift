/** Riwayat Tagihan (AKN-07e; board RiwayatTagihan): each payment with its month, day and method. */
import Domain
import Features
import SwiftUI

struct InvoicesView: View {
    @State private var model: InvoicesModel
    @Environment(\.dismiss) private var dismiss

    init(service: any PlansService) {
        _model = State(initialValue: InvoicesModel(service: service))
    }

    var body: some View {
        PlansScreenFrame {
            KiraNavBar("invoices.title", leading: .back("invoices.back") { dismiss() })
            PlansHeader("invoices.title", subtitle: "invoices.lede")
            content
            KiraNotice(.info, title: "plans.prototype", message: "invoices.prototype")
            Spacer(minLength: 0)
            KiraButton("invoices.done", variant: .secondary) { dismiss() }.block()
        }
        .task { await model.load() }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            PlansLoadingView()
        case .empty:
            KiraNotice(.info, message: "invoices.empty")
        case .failed(let problem):
            PlansProblemView(problem: problem) { Task { await model.load() } }
        case .loaded(let invoices):
            KiraListGroup("invoices.list") {
                ForEach(invoices) { row($0) }
            }
        }
    }

    private func row(_ invoice: Invoice) -> some View {
        let day = invoice.periodStart.date
        return KiraListRow(
            Text("invoices.row.title \(Text(invoice.plan.title)) \(day, format: .plansMonthYear)"),
            leading: .icon(.receipt)
        )
        .subtitle(Text("invoices.row.detail \(day, format: .plansFullDay) \(Text(invoice.paymentMethod.title))"))
        .amount(KiraAmount(Decimal(invoice.amount), size: .small))
    }
}
