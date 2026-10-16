import Domain
import Foundation

/**
 The fields of the "Ubah Transaksi" sheet, the same fields as the draft sheet of Catat (CAT-02):
 Nama, Jumlah (digits, grouped as typed), Kategori and Tanggal, plus Catatan. Wallets do not exist
 yet, so Dompet is left out. Only what changed is sent.
 */
package struct TransactionEditor: Hashable, Sendable {
    /** The transaction's direction, which the edit keeps. */
    package let type: TransactionType
    /** The Nama field. */
    package var name: String
    /** The amount as the field shows it, "18.000"; anything but digits is dropped as typed. */
    package var amountText: String {
        didSet {
            let grouped = AmountInput.grouped(amountText)
            if grouped != amountText { amountText = grouped }
        }
    }
    /** The chosen Kategori chip. */
    package var category: TransactionCategory
    /** The Tanggal field. */
    package var occurredAt: Date
    /** The Catatan field; empty for none. */
    package var note: String

    /** The fields filled from `transaction`. */
    package init(_ transaction: Transaction) {
        type = transaction.type
        name = transaction.name
        amountText = AmountInput.text(for: transaction.amount)
        category = transaction.category
        occurredAt = transaction.occurredAt
        note = transaction.note ?? ""
    }

    /** The categories the sheet offers: those of the transaction's direction. */
    package var categories: [TransactionCategory] {
        TransactionCategory.allCases.filter { $0.type == type }
    }

    /** Whether Simpan may send: a name and an amount above zero. */
    package var isValid: Bool {
        !trimmedName.isEmpty && AmountInput.amount(amountText) != nil
    }

    /** The fields that differ from `transaction`; empty when nothing changed. */
    package func change(from transaction: Transaction) -> TransactionChange {
        let amount = AmountInput.amount(amountText)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return TransactionChange(
            name: trimmedName == transaction.name ? nil : trimmedName,
            amount: amount == transaction.amount ? nil : amount,
            category: category == transaction.category ? nil : category,
            occurredAt: occurredAt == transaction.occurredAt ? nil : occurredAt,
            note: trimmedNote == (transaction.note ?? "") ? nil : trimmedNote)
    }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
}
