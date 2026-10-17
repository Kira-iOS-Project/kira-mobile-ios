/**
 UNG-07 and UNG-07c for `ScreenLaunch`: Tambah Tagihan empty, Tambah Tagihan filled as on
 TambahTagihanDialogBerhasil (the tests tap Simpan Tagihan for Tagihan Tersimpan) and failing (for
 Belum Berhasil Menyimpan), and Ubah Tagihan of Internet Rumah (the tests tap Hapus Tagihan).
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct BillFormLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .billEdit:
                    EditBillScreen(
                        id: "internet", values: .internet, editor: PreviewBillEditorService(),
                        wallets: PreviewWalletService()
                    ) { _ in }
                case .billAddSaved: form(PreviewBillEditorService())
                case .billAddFailing: form(PreviewBillEditorService(fails: true))
                default:
                    AddBillScreen(editor: PreviewBillEditorService(), wallets: PreviewWalletService()) { _ in }
                }
            }
        }

        /** Tambah Tagihan with the board's Internet Rumah typed in, so Simpan Tagihan is on. */
        private func form(_ editor: PreviewBillEditorService) -> some View {
            var values = BillFormValues.internet
            values.amount = 350_000
            return BillFormScreen(
                model: BillFormModel(mode: .create, values: values, editor: editor, wallets: PreviewWalletService()),
                onOpen: { _ in }, onDone: {})
        }
    }
#endif
