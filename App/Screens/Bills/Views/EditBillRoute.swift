/**
 Ubah Tagihan by id (`AppRoute.editBill`): there is no `GET /bills/{id}`, so it finds the bill in
 Tagihan & Cicilan's list, then shows the form; a list that cannot load shows Coba Lagi, and a bill
 no longer in it is BILL_NOT_FOUND.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct EditBillRoute: View {
    let id: String
    let bills: any BillService
    let editor: any BillEditorService
    let wallets: any WalletService
    let onOpen: (AppRoute) -> Void
    @State private var phase = Phase.loading
    @Environment(\.dismiss) private var dismiss

    private enum Phase {
        case loading
        case found(Bill)
        case failed(AppProblem)
    }

    var body: some View {
        switch phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(.surface)
                .toolbar(.hidden, for: .navigationBar)
                .task { await load() }
        case .found(let bill):
            EditBillScreen(
                id: bill.id, values: BillFormValues(bill: bill), editor: editor, wallets: wallets, onOpen: onOpen)
        case .failed(let problem):
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("bills.edit.title", leading: .back("bills.edit.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                LoadFailedView(title: "bills.edit.failed", problem: problem) {
                    phase = .loading
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .background(.surface)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func load() async {
        do {
            let overview = try await bills.bills()
            let bill = overview.sections.flatMap(\.bills).first { $0.id == id }
            phase = bill.map(Phase.found) ?? .failed(AppProblem(code: ProblemCode.billNotFound.rawValue))
        } catch {
            phase = .failed(AppProblem(error))
        }
    }
}
