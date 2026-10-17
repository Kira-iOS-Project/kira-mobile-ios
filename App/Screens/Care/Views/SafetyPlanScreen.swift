/**
 PED-10, Rencana Keselamatanku (board RencanaKeselamatan): the five parts, each with its pencil to
 Isi Rencana Keselamatanku (PED-10c), the privacy notice and Simpan Rencana. "Rencana Tersimpan"
 (PED-10b) comes up over it after a save, and its Selesai goes back to Kira Peduli. A save that
 failed shows its dialog here, the form closed: Coba Lagi opens the form again on what was written.
 No help button, no mascot, no handwriting: a Kira Peduli screen.
 */
import Domain
import Features
import SwiftUI

struct SafetyPlanScreen: View {
    @State private var model: SafetyPlanModel
    @Environment(\.dismiss) private var dismiss

    init(service: any CareToolsService) {
        _model = State(initialValue: SafetyPlanModel(service: service))
    }

    var body: some View {
        CareScreenFrame(twigSize: 150) {
            SafetyPlanHeader(
                title: "care.plan.title", lead: "care.plan.lead", back: "care.plan.back"
            ) { dismiss() }
            content
        }
        .task { await model.load() }
        .navigationDestination(isPresented: formShown) {
            if let form = model.form { SafetyPlanFormScreen(form: form) }
        }
        .kiraDialog(isPresented: dialogShown) { dialog }
        .onChange(of: model.isFinished) { _, finished in
            if finished { dismiss() }
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .empty:
            plan(.empty)
        case .loaded(let plan):
            self.plan(plan)
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        }
    }

    private func plan(_ plan: SafetyPlan) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(spacing: 10) {
                ForEach(SafetyPlanPart.allCases, id: \.self) { part in
                    SafetyPlanRow(part: part, plan: plan) { model.edit(part) }
                }
            }
            KiraNotice(.privacy, message: "care.plan.notice")
            Spacer(minLength: 0)
            KiraButton("care.plan.save") { Task { await model.saveShown() } }.block()
                .disabled(model.isSaving)
        }
    }

    private var dialog: KiraDialog {
        switch model.shownDialog {
        case .saved:
            KiraDialog(
                "care.plan.saved.title", message: "care.plan.saved.body", art: .illustration(.bloom),
                primary: KiraButton("care.plan.saved.done") {})
        case .failed(let problem):
            KiraDialog(
                "care.plan.failed.title", message: problem.failureMessage, art: .illustration(.umbrella),
                primary: KiraButton("care.plan.failed.retry") { model.retry() },
                secondary: KiraButton("care.plan.failed.close", variant: .secondary) {})
        }
    }

    private var formShown: Binding<Bool> {
        Binding(get: { model.form != nil }, set: { if !$0 { model.form = nil } })
    }

    private var dialogShown: Binding<Bool> {
        Binding(get: { model.dialog != nil }, set: { if !$0 { model.dialogClosed() } })
    }
}

#if DEBUG
    #Preview {
        NavigationStack { SafetyPlanScreen(service: PreviewCareToolsService()) }
    }
#endif
