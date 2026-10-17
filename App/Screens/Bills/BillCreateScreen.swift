import APIClient
import Domain
import Features
import SwiftUI

/** UNG-07: create a recurring bill and keep the form until the server confirms it. */
struct BillCreateScreen: View {
    @State private var model: BillCreateModel
    @State private var isShowingSavedDialog = false
    @Environment(\.dismiss) private var dismiss
    private let onOpenHelp: () -> Void

    init(service: any BillsService, onOpenHelp: @escaping () -> Void) {
        _model = State(initialValue: BillCreateModel(service: service))
        self.onOpenHelp = onOpenHelp
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("bills.create.title", leading: .back("bills.back") { dismiss() }) {
                    KiraHelpButton(.icon, action: onOpenHelp)
                }
                Text("bills.create.lede")
                    .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                BillCreateInputFields(model: model)
                BillCreateScheduleFields(model: model)
                BillCreateDebtField(model: model)
                saveProblem
                saveButton
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
        .onChange(of: model.savedBill) { _, bill in
            isShowingSavedDialog = bill != nil
        }
        .kiraDialog(isPresented: savedBillPresented) {
            savedDialog
        }
    }

    private var savedBillPresented: Binding<Bool> {
        Binding(
            get: { isShowingSavedDialog },
            set: {
                isShowingSavedDialog = $0
                if !$0 { dismiss() }
            }
        )
    }

    private var savedDialog: KiraDialog {
        guard let bill = model.savedBill else {
            return KiraDialog(
                "bills.create.saved.title", message: "bills.create.saved.bill \(model.name)",
                art: .illustration(.bloom),
                primary: KiraButton("bills.create.done") {})
        }
        let message: LocalizedStringResource =
            switch bill.kind {
            case .bill: "bills.create.saved.bill \(bill.name)"
            case .debtInstallment: "bills.create.saved.debt \(bill.name)"
            }
        return KiraDialog(
            "bills.create.saved.title", message: message, art: .illustration(.bloom),
            primary: KiraButton("bills.create.done") {})
    }

    @ViewBuilder private var saveProblem: some View {
        if let problem = model.saveProblem {
            BillCreateProblem(problem: problem)
        }
    }

    private var saveButton: some View {
        KiraButton("bills.create.save") { Task { await model.save() } }
            .block()
            .disabled(model.isSaving)
    }
}

private struct BillCreateProblem: View {
    let problem: AppProblem

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            KiraNotice(.warning, title: "bills.create.failed.title", message: problem.message)
            if problem.knownCode == nil { Text(problem.reference).font(.footnote).foregroundStyle(.inkMuted) }
        }
    }
}
