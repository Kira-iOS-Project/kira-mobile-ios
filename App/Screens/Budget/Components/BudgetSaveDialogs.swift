/**
 The dialogs over Atur Budget (UNG-05) after "Simpan Budget". Budget Tersimpan (UNG-05b) once the
 server has the new allocations; Belum Berhasil Menyimpan (UNG-05c) when the save failed, in the
 words of a failed sheet submit (`SubmissionSheet`): the board's sentence for a lost connection, the
 problem's own (`problem.<CODE>`), or the generic one with the reference. The numbers stay on the
 screen behind it; Coba Lagi saves them again once the dialog is down, Tutup only closes it.
 */
import APIClient
import SwiftUI

extension View {
    /** Budget Tersimpan while `isPresented` is true; Selesai closes it. */
    func budgetSaveSuccessDialog(isPresented: Binding<Bool>) -> some View {
        kiraDialog(isPresented: isPresented) {
            KiraDialog(
                "budget.save.success.title", message: "budget.save.success.message", art: .illustration(.bloom),
                primary: KiraButton("budget.save.success.done") {})
        }
    }

    /**
     Belum Berhasil Menyimpan while `failure` holds the save's problem; Coba Lagi runs `onRetry` once
     the dialog's layer is down, so a second failure never meets this one on its way out.
     */
    func budgetSaveFailureDialog(failure: Binding<AppProblem?>, onRetry: @escaping () -> Void) -> some View {
        modifier(BudgetSaveFailure(failure: failure, onRetry: onRetry))
    }
}

/** Keeps the problem shown while the dialog fades, and starts Coba Lagi's retry after it. */
private struct BudgetSaveFailure: ViewModifier {
    @Binding var failure: AppProblem?
    let onRetry: () -> Void
    @State private var shown = AppProblem.connectionLost
    @State private var retryPending = false

    private let text = SheetFailureText(title: "budget.save.failure.title", connection: "budget.save.failure.message")

    func body(content: Content) -> some View {
        content
            .kiraDialog(isPresented: isPresented, onDismiss: gone) {
                KiraDialog(
                    text.title, message: text.message(for: shown), art: .illustration(.umbrella),
                    primary: KiraButton("sheet.failure.retry") { retryPending = true },
                    secondary: KiraButton("ds.close", variant: .secondary) {})
            }
            .onChange(of: failure, initial: true) { _, problem in
                if let problem { shown = problem }
            }
    }

    private var isPresented: Binding<Bool> {
        Binding(get: { failure != nil }, set: { if !$0 { failure = nil } })
    }

    private func gone() {
        guard retryPending else { return }
        retryPending = false
        onRetry()
    }
}
