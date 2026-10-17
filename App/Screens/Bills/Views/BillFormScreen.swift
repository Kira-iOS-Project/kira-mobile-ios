/**
 Tambah Tagihan (UNG-07, board TambahTagihan) and Ubah Tagihan (UNG-07c, board UbahTagihan): Nama,
 Jumlah with its estimate hint, the four category tiles, Ulangi, Tanggal and Ini Cicilan Utang with
 the debt account it pays. Tambah closes with X and ends on Tagihan Tersimpan (UNG-07b); Ubah goes
 back, saves with Simpan Perubahan and deletes after Hapus Tagihan Ini? (UNG-07d). A failed save or
 delete shows Belum Berhasil Menyimpan with the form kept.
 */
import Domain
import Features
import SwiftUI

/** Tambah Tagihan: an empty form; Selesai on Tagihan Tersimpan calls `onSaved` and closes it. */
struct AddBillScreen: View {
    let editor: any BillEditorService
    let wallets: any WalletService
    let onOpen: (AppRoute) -> Void
    var onSaved: () -> Void = {}

    var body: some View {
        BillFormScreen(
            model: BillFormModel(mode: .create, editor: editor, wallets: wallets), onOpen: onOpen,
            onDone: onSaved)
    }
}

/** Ubah Tagihan of `values`; goes back after a save or a delete, calling `onDone`. */
struct EditBillScreen: View {
    let id: String
    let values: BillFormValues
    let editor: any BillEditorService
    let wallets: any WalletService
    let onOpen: (AppRoute) -> Void
    var onDone: () -> Void = {}

    var body: some View {
        BillFormScreen(
            model: BillFormModel(mode: .edit(id: id), values: values, editor: editor, wallets: wallets),
            onOpen: onOpen, onDone: onDone)
    }
}

struct BillFormScreen: View {
    @State private var model: BillFormModel
    let onOpen: (AppRoute) -> Void
    let onDone: () -> Void
    @State private var isConfirmingDelete = false
    @State private var showsSaved = false
    @Environment(\.dismiss) private var dismiss

    init(model: BillFormModel, onOpen: @escaping (AppRoute) -> Void, onDone: @escaping () -> Void) {
        _model = State(initialValue: model)
        self.onOpen = onOpen
        self.onDone = onDone
    }

    private var isEditing: Bool { model.mode != .create }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                navBar
                BillFormFields(model: model)
                actions.padding(.top, KiraSpacing.space2)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space4)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 34, y: -29)
                    .accessibilityHidden(true)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.loadDebts() }
        .onChange(of: model.saved) { _, saved in
            guard saved else { return }
            if isEditing { finish() } else { showsSaved = true }
        }
        .onChange(of: model.deleted) { _, deleted in if deleted { finish() } }
        .billSavedDialog(isPresented: $showsSaved, onDone: finish)
        .billDeleteDialog(
            isPresented: $isConfirmingDelete, name: model.name, amount: AmountInput.value(of: model.amount) ?? 0,
            repeats: model.repeats
        ) {
            Task { await model.delete() }
        }
        .billFailureDialog(failure: $model.failure) { Task { await model.retry() } }
    }

    private var navBar: some View {
        KiraNavBar(
            isEditing ? "bills.edit.title" : "bills.add.title",
            subtitle: isEditing ? "bills.edit.subtitle \(model.name)" : "bills.add.subtitle",
            leading: isEditing ? .back("bills.edit.back") { dismiss() } : .close("bills.add.close") { dismiss() }
        ) {
            KiraHelpButton(.icon) { onOpen(.care) }
        }
    }

    /** Simpan Tagihan; on Ubah, Simpan Perubahan above Hapus Tagihan. */
    @ViewBuilder private var actions: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraButton(isEditing ? "bills.edit.save" : "bills.add.save") { Task { await model.save() } }
                .block().disabled(!model.canSave)
            if isEditing {
                KiraButton("bills.edit.delete", variant: .destructive) { isConfirmingDelete = true }
                    .icon(.trash).block().disabled(model.isWorking)
            }
        }
    }

    private func finish() {
        onDone()
        dismiss()
    }
}
