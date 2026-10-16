import Domain
import Observation

/**
 Tinjau Hasil Impor (CAT-12, 12b, 12c): the stored rows split into "Mungkin Dobel" (unchecked, the
 server found a saved transaction on the same day with the same amount and type) and "Siap
 Disimpan" (checked). The person checks rows and changes categories, then saves the checked ones
 at once; a retry after a failure never saves twice, as the commit is idempotent.
 */
@MainActor
@Observable
package final class ImportReviewModel {
    /** A dialog over the review. */
    package enum Dialog: Hashable, Sendable {
        /** "39 Transaksi Tersimpan" */
        case saved(ImportCommitResult)
        /** "Impor Belum Berhasil" */
        case failed
    }

    /** How many "Siap Disimpan" rows show before the "Transaksi Lainnya" row. */
    package static let readyPreviewCount = 5

    /** The stored import under review. */
    package let preview: ImportPreview
    /** The file's name, under the title. */
    package let fileName: String
    /** The ids of the rows to save. */
    package private(set) var checked: Set<String>
    /** Whether the folded ready rows are shown. */
    package private(set) var isReadyExpanded = false
    /** The row whose sheet is open. */
    package var editingRowId: String?
    /** The open dialog; nil when none is. */
    package private(set) var dialog: Dialog? {
        didSet { if let dialog { shownDialog = dialog } }
    }
    /** The dialog to draw, kept while a closing dialog fades out. */
    package private(set) var shownDialog = Dialog.failed
    /** Whether the rows are being saved. */
    package private(set) var isSaving = false
    /** True once the person leaves after saving; the flow then returns to Riwayat. */
    package private(set) var isFinished = false

    private var categories: [String: TransactionCategory] = [:]
    private let service: any HistoryService

    /** A review of `preview`, read from `fileName`. */
    package init(preview: ImportPreview, fileName: String, service: any HistoryService) {
        self.preview = preview
        self.fileName = fileName
        self.service = service
        checked = Set(preview.rows.filter { !$0.isDuplicate }.map(\.id))
    }

    /** The rows under "Mungkin Dobel". */
    package var duplicates: [ImportPreviewRow] { preview.rows.filter(\.isDuplicate) }
    /** The rows under "Siap Disimpan". */
    package var ready: [ImportPreviewRow] { preview.rows.filter { !$0.isDuplicate } }
    /** The ready rows shown above the "Transaksi Lainnya" row, or all of them once opened. */
    package var visibleReady: [ImportPreviewRow] {
        isReadyExpanded ? ready : Array(ready.prefix(Self.readyPreviewCount))
    }
    /** The ready rows folded into the "Transaksi Lainnya" row. */
    package var hiddenReady: [ImportPreviewRow] { Array(ready.dropFirst(visibleReady.count)) }
    /** How many rows the save button counts. */
    package var checkedCount: Int { checked.count }
    /** The row whose sheet is open, if any. */
    package var editingRow: ImportPreviewRow? { preview.rows.first { $0.id == editingRowId } }

    /** Whether `row` will be saved. */
    package func isChecked(_ row: ImportPreviewRow) -> Bool { checked.contains(row.id) }

    /** The category the row will be saved with. */
    package func category(of row: ImportPreviewRow) -> TransactionCategory {
        categories[row.id] ?? row.category
    }

    /** The categories `row`'s sheet offers: those of its direction. */
    package func categories(for row: ImportPreviewRow) -> [TransactionCategory] {
        TransactionCategory.allCases.filter { $0.type == row.type }
    }

    /** Checks or unchecks `row`. */
    package func toggle(_ row: ImportPreviewRow) {
        if checked.remove(row.id) == nil { checked.insert(row.id) }
    }

    /** Files `row` under `category`. */
    package func setCategory(_ category: TransactionCategory, for row: ImportPreviewRow) {
        categories[row.id] = category
    }

    /** Shows the ready rows folded into "Transaksi Lainnya". */
    package func showAllReady() {
        isReadyExpanded = true
    }

    /** Saves the checked rows with their categories. */
    package func save() async {
        dialog = nil
        guard checkedCount > 0, !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        let rows = preview.rows.filter(isChecked).map { ImportCommitRow(id: $0.id, category: category(of: $0)) }
        do {
            dialog = .saved(try await service.commit(importId: preview.id, rows: rows))
        } catch {
            dialog = .failed
        }
    }

    /** A dialog closed; closing the saved one leaves for Riwayat. */
    package func dialogClosed() {
        if case .saved = dialog { isFinished = true }
        dialog = nil
    }
}
