/**
 Tambah Dompet (UNG-02), the sheet over Dompet: Jenis, Nama, Saldo Sekarang (the debt left for a debt
 account), the privacy note, and "Simpan Dompet". A missing name or debt stays inline in the sheet; a
 failed save closes it into the failure dialog (`SubmissionSheet`), and a saved one into "Dompet
 Ditambahkan" (UNG-02b), after which Dompet loads again.
 */
import Features
import SwiftUI

extension View {
    /** The sheet and its two dialogs; `onAdded` runs once "Dompet Ditambahkan" is closed. */
    func addWalletSheet(_ model: AddWalletModel, onAdded: @escaping () -> Void) -> some View {
        modifier(AddWalletPresentation(model: model, onAdded: onAdded))
    }
}

private struct AddWalletPresentation: ViewModifier {
    @Bindable var model: AddWalletModel
    let onAdded: () -> Void

    func body(content: Content) -> some View {
        content
            .kiraSheet(
                $model.sheet, title: "wallet.add.title", subtitle: "wallet.add.subtitle", top: 142,
                failureTitle: "wallet.add.failed", onRetry: { Task { await model.save() } },
                content: { AddWalletForm(model: model) }
            )
            .kiraDialog(isPresented: $model.showsAdded, onDismiss: onAdded) {
                KiraDialog(
                    "wallet.add.added.title", message: "wallet.add.added.body", art: .illustration(.bloom),
                    primary: KiraButton("wallet.add.added.done") {})
            }
    }
}

/** The sheet's form, top to bottom as the board lays it. */
private struct AddWalletForm: View {
    @Bindable var model: AddWalletModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                WalletTypeGrid(model: model)
                KiraField("wallet.add.name", text: $model.name)
                    .error(model.issues.contains(.missingName) ? "wallet.add.name.missing" : nil)
                KiraField("wallet.add.amount", text: $model.amountText, prompt: "wallet.add.amount.prompt")
                    .prefix("wallet.add.currency").suffix("wallet.add.cents").amount()
                    .hint("wallet.add.amount.hint")
                    .error(model.issues.contains(.missingDebt) ? "wallet.add.debt.missing" : nil)
                KiraNotice(.privacy, message: "wallet.add.privacy")
                KiraButton("wallet.add.save") { Task { await model.save() } }.block()
                    .padding(.top, KiraSpacing.space1)
            }
            .padding(.bottom, KiraSpacing.space2)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
