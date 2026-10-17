/**
 The dialogs over Tambah Tagihan and Ubah Tagihan: Tagihan Tersimpan (UNG-07b) once the server has
 the new bill, and Belum Berhasil Menyimpan when a save or delete failed, in the words of a failed
 sheet submit (`SheetFailureText`): the connection sentence, the problem's own (`problem.<CODE>`), or
 the generic one with the reference. Coba Lagi sends again once the dialog is down; Tutup closes it.
 */
import APIClient
import SwiftUI

extension View {
    /** Tagihan Tersimpan while `isPresented` is true; Selesai runs `onDone`. */
    func billSavedDialog(isPresented: Binding<Bool>, onDone: @escaping () -> Void) -> some View {
        kiraDialog(isPresented: isPresented) {
            KiraDialog(
                "bills.add.saved.title", message: "bills.add.saved.message", art: .illustration(.bloom),
                primary: KiraButton("bills.add.saved.done", action: onDone))
        }
    }

    /** Belum Berhasil Menyimpan while `failure` holds the problem; Coba Lagi runs `onRetry` after it closes. */
    func billFailureDialog(failure: Binding<AppProblem?>, onRetry: @escaping () -> Void) -> some View {
        modifier(BillFailure(failure: failure, onRetry: onRetry))
    }
}

/** Keeps the problem shown while the dialog fades, and starts Coba Lagi's retry after it. */
private struct BillFailure: ViewModifier {
    @Binding var failure: AppProblem?
    let onRetry: () -> Void
    @State private var shown = AppProblem.connectionLost
    @State private var retryPending = false

    private let text = SheetFailureText(title: "bills.add.failure.title", connection: "bills.add.failure.message")

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
