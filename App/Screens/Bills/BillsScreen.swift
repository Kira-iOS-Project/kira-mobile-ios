import Domain
import Features
import SwiftUI

/** UNG-06: recurring bills and linked debt installments sorted into upcoming periods. */
struct BillsScreen: View {
    private let service: any BillsService
    private let onOpenBill: (RecurringBill) -> Void
    @State private var model: BillsModel
    @Environment(\.dismiss) private var dismiss

    init(service: any BillsService, onOpenBill: @escaping (RecurringBill) -> Void) {
        self.service = service
        self.onOpenBill = onOpenBill
        _model = State(initialValue: BillsModel(service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                navBar
                switch model.phase {
                case .loading:
                    BillsLoadingView()
                case .empty:
                    BillsEmptyView()
                case .loaded(let content):
                    sections(content)
                case .failed(let problem):
                    LoadFailedView(title: "bills.failed", problem: problem) { Task { await model.load() } }
                }
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space10)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 48, y: -20)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    private var navBar: some View {
        KiraNavBar("bills.title", leading: .back("bills.back") { dismiss() }) {
            KiraHelpButton(.icon) {}
        }
    }

    @ViewBuilder private func sections(_ content: BillsContent) -> some View {
        ForEach(content.sections) { section in
            KiraListGroup(sectionTitle(section.kind)) {
                ForEach(section.bills) { bill in
                    row(bill)
                }
            }
        }
    }

    private func row(_ bill: RecurringBill) -> some View {
        KiraListRow(Text(bill.name), leading: .category(tile(for: bill)), action: { onOpenBill(bill) }) {
            if bill.isPaidThisPeriod {
                KiraTag("bills.paid", tone: .healthy)
            } else if bill.isDueSoon {
                KiraTag("bills.dueSoon", tone: .turmeric)
            }
        }
        .subtitle(Text("bills.due \(bill.nextDueDate.date.formatted(.kiraDate))"))
        .amount(KiraAmount(Decimal(bill.amount), size: .small))
    }

    private func tile(for bill: RecurringBill) -> KiraCategory {
        if bill.kind == .debtInstallment { return .paylater }
        return TransactionCategory(rawValue: bill.category)?.tile ?? .other
    }

    private func sectionTitle(_ kind: BillSection.Kind) -> LocalizedStringResource {
        switch kind {
        case .nextSevenDays: "bills.section.nextSevenDays"
        case .thisMonth: "bills.section.thisMonth"
        case .nextMonth: "bills.section.nextMonth"
        case .later: "bills.section.later"
        }
    }
}

private struct BillsLoadingView: View {
    var body: some View {
        KiraListGroup("bills.section.nextSevenDays") {
            ForEach(0..<3, id: \.self) { _ in
                KiraListRow(Text("bills.loading"), leading: .icon(.calendar))
                    .redacted(reason: .placeholder)
            }
        }
        .disabled(true)
    }
}

private struct BillsEmptyView: View {
    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraIllustration(.calendar, size: 112)
            Text("bills.empty.title").kiraFont(.title).foregroundStyle(.ink)
            Text("bills.empty.body")
                .font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, KiraSpacing.space8)
    }
}
