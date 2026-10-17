/**
 The dialog over the quiz when Lihat Hasil's save failed, in the words of every failed submit
 (`SheetFailureText`): the connection's sentence when the request got no answer, the problem's own
 (`problem.<CODE>`), or the generic one with the reference. The answers stay; Coba Lagi sends them
 again once the dialog is down, Tutup only closes it.
 */
import APIClient
import SwiftUI

extension View {
    /** Belum Berhasil Menyimpan while `failure` holds the save's problem; Coba Lagi runs `onRetry`. */
    func riskSaveFailureDialog(failure: Binding<AppProblem?>, onRetry: @escaping () -> Void) -> some View {
        modifier(RiskSaveFailure(failure: failure, onRetry: onRetry))
    }
}

/** Keeps the problem shown while the dialog fades, and starts Coba Lagi's retry after it. */
private struct RiskSaveFailure: ViewModifier {
    @Binding var failure: AppProblem?
    let onRetry: () -> Void
    @State private var shown = AppProblem.connectionLost
    @State private var retryPending = false

    private let text = SheetFailureText(title: "plan.risk.failure.title", connection: "problem.connection")

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
