/**
 Gallery page for dialogs: success, failure, the Atur Budget save failure and success, a
 confirmation that deletes and one that does not, and round-icon art, shown inline on the scrim or
 presented over the whole window.
 */
#if DEBUG
    import APIClient
    import Domain
    import SwiftUI

    struct GalleryDialogs: View {
        @State private var isConfirming = false
        @State private var budgetSaveFailure: AppProblem?
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var budgetAmount = "350000"
        @State private var didRetryBudgetSave = false
        @State private var isBudgetSaveSuccessPresented = false
        @State private var isConfirmingBillDelete = false

        var body: some View {
            GallerySection(title: "gallery.section.dialogPresented") {
                KiraButton("gallery.dialog.open", variant: .secondary) { isConfirming = true }
                    .kiraDialog(isPresented: $isConfirming) {
                        KiraDialog(
                            "gallery.dialog.unsubscribe.title", message: "gallery.dialog.unsubscribe.body",
                            art: .illustration(.care),
                            primary: KiraButton("gallery.dialog.unsubscribe", variant: .destructive) {},
                            secondary: KiraButton("gallery.dialog.keep", variant: .secondary) {})
                    }
            }
            GallerySection(title: "gallery.section.dialogBillDelete") {
                KiraButton("gallery.dialog.billDelete.open", variant: .secondary) {
                    isConfirmingBillDelete = true
                }
                .billDeleteDialog(
                    isPresented: $isConfirmingBillDelete, name: "Internet Rumah", amount: 350_000, repeats: .monthly
                ) {}
                BillDeleteDialog.dialog(name: "Asuransi Motor", amount: 420_000, repeats: .yearly) {}.onScrim()
                BillDeleteDialog.dialog(name: "Servis Laptop", amount: 275_000, repeats: .once) {}.onScrim()
            }
            GallerySection(title: "gallery.section.dialogSuccess") {
                KiraDialog(
                    "gallery.dialog.saved.title", message: "gallery.dialog.saved.body", art: .illustration(.bloom),
                    primary: KiraButton("gallery.dialog.done") {}
                )
                .onScrim()
                KiraButton("gallery.dialog.budgetSuccess.open", variant: .secondary) {
                    isBudgetSaveSuccessPresented = true
                }
                .budgetSaveSuccessDialog(isPresented: $isBudgetSaveSuccessPresented)
            }
            GallerySection(title: "gallery.section.dialogFailure") {
                KiraDialog(
                    "gallery.dialog.failed.title", message: "gallery.dialog.failed.body", art: .illustration(.umbrella),
                    primary: KiraButton("gallery.dialog.retry") {},
                    secondary: KiraButton("gallery.dialog.close", variant: .secondary) {}
                )
                .onScrim()
            }
            GallerySection(title: "gallery.section.dialogBudgetFailure") {
                KiraField("gallery.dialog.budgetFailure.amount", text: $budgetAmount).prefix("gallery.field.rupiah")
                    .amount()
                Text(
                    didRetryBudgetSave
                        ? "gallery.dialog.budgetFailure.retried" : "gallery.dialog.budgetFailure.notRetried"
                )
                .font(.footnote)
                .foregroundStyle(.inkMuted)
                KiraButton("gallery.dialog.budgetFailure.open", variant: .secondary) {
                    budgetSaveFailure = .connectionLost
                }
                .budgetSaveFailureDialog(failure: $budgetSaveFailure) { didRetryBudgetSave = true }
            }
            GallerySection(title: "gallery.section.dialogConfirm") {
                KiraDialog(
                    "gallery.dialog.delete.title", message: "gallery.dialog.delete.body", art: .illustration(.care),
                    primary: KiraButton("gallery.dialog.delete", variant: .destructive) {},
                    secondary: KiraButton("gallery.dialog.cancel", variant: .secondary) {}
                )
                .onScrim()
                KiraDialog(
                    "gallery.dialog.download.title", message: "gallery.dialog.download.body",
                    art: .illustration(.shield), primary: KiraButton("gallery.dialog.download") {},
                    secondary: KiraButton("gallery.dialog.cancel", variant: .secondary) {}
                )
                .onScrim()
            }
            GallerySection(title: "gallery.section.dialogIcon") {
                KiraDialog(
                    "gallery.dialog.linked.title", message: "gallery.dialog.linked.body", art: .success,
                    primary: KiraButton("gallery.dialog.done") {}
                )
                .onScrim()
                KiraDialog(
                    "gallery.dialog.offline.title", message: "gallery.dialog.offline.body", art: .failure,
                    primary: KiraButton("gallery.dialog.retry") {},
                    secondary: KiraButton("gallery.dialog.close", variant: .secondary) {}
                )
                .onScrim()
            }
        }
    }

    extension View {
        /** The dialog as it sits over a screen: on the scrim, 24 pt from the edges. */
        fileprivate func onScrim() -> some View {
            padding(.horizontal, KiraSpacing.space6)
                .padding(.vertical, KiraSpacing.space8)
                .background(.scrim, in: RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous))
        }
    }

    #Preview { GalleryDialogs().galleryPage() }
#endif
