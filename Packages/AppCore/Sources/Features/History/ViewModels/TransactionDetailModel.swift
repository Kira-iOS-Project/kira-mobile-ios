import APIClient
import Domain
import Observation

/**
 Detail Transaksi (CAT-08) and its dialogs: delete asks first (08b) and reports success (08c);
 an edit saves from the "Ubah Transaksi" sheet and reports success (08d); a failed save or
 delete keeps what the person entered and offers Coba Lagi (08e). The edit's dialogs show over the
 sheet, the delete's over the screen. Every change calls `onChange`, so Riwayat reloads.
 */
@MainActor
@Observable
package final class TransactionDetailModel {
    /** A dialog over the screen. */
    package enum Dialog: Hashable, Sendable {
        /** "Hapus Transaksi Ini?" */
        case confirmDelete
        /** "Transaksi Dihapus" */
        case deleted
        /** "Belum Berhasil Menyimpan", after a failed delete */
        case failed
    }

    /** A dialog over the edit sheet. */
    package enum EditResult: Hashable, Sendable {
        /** "Perubahan Tersimpan" */
        case saved
        /** "Belum Berhasil Menyimpan" */
        case failed
    }

    /** The transaction's id. */
    package let id: String
    /** The transaction and its source message once loaded. */
    package private(set) var phase: ScreenPhase<TransactionDetail> = .loading
    /** The open edit sheet's fields; nil while it is closed. */
    package var editor: TransactionEditor?
    /** The dialog over the screen; nil when none is open. */
    package private(set) var dialog: Dialog? {
        didSet { if let dialog { shownDialog = dialog } }
    }
    /** The dialog to draw, kept while a closing dialog fades out. */
    package private(set) var shownDialog = Dialog.confirmDelete
    /** The dialog over the edit sheet; nil when none is open. */
    package private(set) var editResult: EditResult? {
        didSet { if let editResult { shownEditResult = editResult } }
    }
    /** The edit dialog to draw, kept while a closing dialog fades out. */
    package private(set) var shownEditResult = EditResult.saved
    /** Whether a save or a delete is under way. */
    package private(set) var isWorking = false
    /** True once the person leaves after deleting; the screen then goes back to Riwayat. */
    package private(set) var isClosed = false

    private let service: any HistoryService
    private let onChange: @MainActor () -> Void

    /** A detail of transaction `id`; `onChange` runs after each saved edit or delete. */
    package init(id: String, service: any HistoryService, onChange: @escaping @MainActor () -> Void = {}) {
        self.id = id
        self.service = service
        self.onChange = onChange
    }

    /** Loads the transaction and its source message. */
    package func load() async {
        do {
            phase = .loaded(try await service.transaction(id: id))
        } catch {
            phase = .failed(historyProblem(error))
        }
    }

    /** Opens the edit sheet on the saved values. */
    package func startEditing() {
        guard let detail = phase.value else { return }
        editor = TransactionEditor(detail.transaction)
    }

    /** Sends what changed; nothing changed closes the sheet. A failure keeps the sheet's fields. */
    package func save() async {
        guard let editor, let detail = phase.value, editor.isValid, !isWorking else { return }
        let change = editor.change(from: detail.transaction)
        guard !change.isEmpty else {
            self.editor = nil
            return
        }
        isWorking = true
        defer { isWorking = false }
        do {
            let updated = try await service.update(id: id, change: change)
            phase = .loaded(detail.replacing(updated))
            editResult = .saved
            onChange()
        } catch {
            editResult = .failed
        }
    }

    /** The edit dialog closed: after a save the sheet closes too; after a failure it stays. */
    package func editResultClosed() {
        if editResult == .saved { editor = nil }
        editResult = nil
    }

    /** Asks before deleting. */
    package func requestDelete() {
        dialog = .confirmDelete
    }

    /** Deletes after the confirmation, or again after a failure. */
    package func confirmDelete() async {
        dialog = nil
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await service.delete(id: id)
            dialog = .deleted
            onChange()
        } catch {
            dialog = .failed
        }
    }

    /** A dialog closed; closing "Transaksi Dihapus" leaves for Riwayat. */
    package func dialogClosed() {
        if dialog == .deleted { isClosed = true }
        dialog = nil
    }
}
