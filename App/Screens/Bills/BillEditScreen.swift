import Domain
import Features
import SwiftUI

/** UNG-07c: edit only the future schedule for one ordinary recurring bill. */
struct BillEditScreen: View {
    @State private var model: BillEditModel
    @Environment(\.dismiss) private var dismiss
    @State private var showsSaveFailure = false
    @State private var showsSaveSuccess = false
    @State private var showsDeleteConfirmation = false
    @State private var showsDeleteFailure = false
    private let onOpenHelp: () -> Void

    init(id: String, service: any BillEditService, onOpenHelp: @escaping () -> Void) {
        _model = State(initialValue: BillEditModel(id: id, service: service))
        self.onOpenHelp = onOpenHelp
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("bills.edit.title", leading: .back("bills.back") { dismiss() }) {
                    KiraHelpButton(.icon, action: onOpenHelp)
                }
                Text("bills.edit.lede")
                    .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                content
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
        .onChange(of: model.saveProblem != nil) { _, failed in showsSaveFailure = failed }
        .onChange(of: model.hasSaved) { _, saved in showsSaveSuccess = saved }
        .onChange(of: model.deleteProblem != nil) { _, failed in showsDeleteFailure = failed }
        .onChange(of: model.hasDeleted) { _, deleted in if deleted { dismiss() } }
        .kiraDialog(isPresented: $showsSaveFailure) { saveFailureDialog }
        .kiraDialog(isPresented: $showsSaveSuccess) { saveSuccessDialog }
        .kiraDialog(isPresented: $showsDeleteConfirmation) { deleteConfirmationDialog }
        .kiraDialog(isPresented: $showsDeleteFailure) { deleteFailureDialog }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView { Text("bills.loading") }.frame(maxWidth: .infinity)
        case .empty:
            KiraNotice(.info, message: "bills.edit.unsupported")
        case .loaded:
            BillEditForm(model: model) { showsDeleteConfirmation = true }
        case .failed(let problem):
            LoadFailedView(title: "bills.edit.loadFailed", problem: problem) { Task { await model.load() } }
        }
    }

    private var saveFailureDialog: KiraDialog {
        KiraDialog(
            "bills.edit.saveFailed.title", message: model.saveProblem?.message ?? "bills.edit.saveFailed.body",
            art: .failure,
            primary: KiraButton("bills.edit.retry") { Task { await model.save() } },
            secondary: KiraButton("bills.edit.close", variant: .secondary) {})
    }

    private var saveSuccessDialog: KiraDialog {
        KiraDialog(
            "bills.edit.saved.title", message: "bills.edit.saved.body", art: .illustration(.bloom),
            primary: KiraButton("bills.edit.saved.done") { dismiss() })
    }

    private var deleteConfirmationDialog: KiraDialog {
        KiraDialog(
            "bills.edit.delete.title", message: "bills.edit.delete.body", art: .illustration(.care),
            primary: KiraButton("bills.edit.delete.confirm", variant: .destructive) {
                Task { await model.delete() }
            },
            secondary: KiraButton("bills.edit.delete.cancel", variant: .secondary) {})
    }

    private var deleteFailureDialog: KiraDialog {
        KiraDialog(
            "bills.edit.deleteFailed.title", message: model.deleteProblem?.message ?? "bills.edit.deleteFailed.body",
            art: .failure,
            primary: KiraButton("bills.edit.retry") { Task { await model.delete() } },
            secondary: KiraButton("bills.edit.close", variant: .secondary) {})
    }
}
