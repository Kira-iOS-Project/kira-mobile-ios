import APIClient
import Domain
import Observation

/**
 Detail Transaksi (CAT-08) and its dialogs: delete asks first (08b) and reports success (08c);
 an edit saves from the "Ubah Transaksi" sheet and reports success (08d) over it; a failed save
 closes the sheet for its failure dialog (08e), whose Coba Lagi opens it again on the same fields
 and saves. A failed delete shows the API's problem over the screen with Coba Lagi. Every change
 calls `onChange`, so Riwayat reloads.
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
        /** "Belum Berhasil Menyimpan", after a failed delete, with the API's problem */
        case failed(AppProblem)
    }

    /** The transaction's id. */
    package let id: String
    /** The transaction and its source message once loaded. */
    package private(set) var phase: ScreenPhase<TransactionDetail> = .loading
    /** The edit sheet's fields; nil once the sheet is closed with no failure dialog left. */
    package var editor: TransactionEditor?
    /** The edit sheet, and the failure of its last save. */
    package var editSheet = SheetSubmission() {
        didSet { if !editSheet.isOpen && editSheet.failure == nil { editor = nil } }
    }
    /** The dialog over the screen; nil when none is open. */
    package private(set) var dialog: Dialog? {
        didSet { if let dialog { shownDialog = dialog } }
    }
    /** The dialog to draw, kept while a closing dialog fades out. */
    package private(set) var shownDialog = Dialog.confirmDelete
    /** "Perubahan Tersimpan" is up over the edit sheet. */
    package private(set) var showsSaved = false
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
        editSheet.open()
    }

    /** Sends what changed; nothing changed closes the sheet. A failure closes it and keeps its fields. */
    package func save() async {
        guard let editor, let detail = phase.value, editor.isValid, !isWorking else { return }
        let change = editor.change(from: detail.transaction)
        guard !change.isEmpty else {
            editSheet.close()
            return
        }
        isWorking = true
        defer { isWorking = false }
        do {
            let updated = try await service.update(id: id, change: change)
            phase = .loaded(detail.replacing(updated))
            showsSaved = true
            onChange()
        } catch {
            editSheet.fail(error)
        }
    }

    /** Coba Lagi on the save's failure dialog: the sheet opens again on its fields and saves. */
    package func retryEdit() async {
        editSheet.open()
        await save()
    }

    /** "Perubahan Tersimpan" closed: the sheet closes with it. */
    package func savedClosed() {
        showsSaved = false
        editSheet.close()
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
            dialog = .failed(historyProblem(error))
        }
    }

    /** A dialog closed; closing "Transaksi Dihapus" leaves for Riwayat. */
    package func dialogClosed() {
        if dialog == .deleted { isClosed = true }
        dialog = nil
    }
}
