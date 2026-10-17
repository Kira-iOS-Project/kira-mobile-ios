/**
 Hapus Tujuan's dialogs over Detail Tujuan: "Hapus Tujuan Ini?" with the goal's name, "Tujuan
 Dihapus", and "Belum Berhasil Menghapus" with Coba Lagi. Each button closes its dialog after its
 action; the model decides what closing means (closing "Tujuan Dihapus" leaves the screen).
 */
import Domain
import Features
import SwiftUI

extension View {
    /** `model`'s delete dialog while one is open. */
    func goalDeleteDialog(_ model: GoalDetailModel) -> some View {
        kiraDialog(
            isPresented: Binding(get: { model.deleteDialog != nil }, set: { if !$0 { model.deleteDialogClosed() } })
        ) {
            GoalDeleteDialog.dialog(model)
        }
    }
}

private enum GoalDeleteDialog {
    @MainActor
    static func dialog(_ model: GoalDetailModel) -> KiraDialog {
        switch model.shownDeleteDialog {
        case .confirm:
            KiraDialog(
                "plan.delete.title", message: "plan.delete.body \(model.phase.value?.summary.name ?? "")",
                art: .illustration(.care),
                primary: KiraButton("plan.delete.confirm", variant: .destructive) {
                    Task { await model.confirmDelete() }
                },
                secondary: KiraButton("plan.delete.cancel", variant: .secondary) {})
        case .deleted:
            KiraDialog(
                "plan.deleted.title", message: "plan.deleted.body", art: .illustration(.bloom),
                primary: KiraButton("plan.deleted.back") {})
        case .failed(let problem):
            KiraDialog(
                "plan.delete.failed", message: problem.failureMessage, art: .illustration(.umbrella),
                primary: KiraButton("plan.delete.retry") { Task { await model.confirmDelete() } },
                secondary: KiraButton("plan.delete.close", variant: .secondary) {})
        }
    }
}
