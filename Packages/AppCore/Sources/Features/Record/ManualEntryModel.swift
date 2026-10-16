import Domain
import Foundation
import Observation

/**
 Catat Manual (CAT-04): a form without chat and without AI quota. The type switches the category
 grid (CAT-04d), the category starts at the last one used, the date at today. Simpan shows
 "Transaksi Tersimpan" (CAT-04b); a lost connection shows "Belum Berhasil Menyimpan" (CAT-04c),
 keeps every field, and Coba Lagi resends with the same `clientId`, so it never saves twice.
 */
@MainActor
@Observable
package final class ManualEntryModel {
    /** The board's expense grid (CatatManual) and income grid (CatatManualPemasukan). */
    package static let expenseCategories: [TransactionCategory] = [
        .food, .transport, .coffee, .shopping, .bills, .paylaterInstalment, .savingsDeposit, .insurance,
    ]
    /** The income grid. */
    package static let incomeCategories: [TransactionCategory] = [.salary, .bonus, .business, .otherIncome]

    /** Pengeluaran or Pemasukan. */
    package internal(set) var type: TransactionType = .expense
    /** The chosen tile. */
    package internal(set) var category: TransactionCategory
    /** The name; empty saves the category's name. */
    package var name = ""
    /** The optional note (Catatan). */
    package var note = ""
    /** The day of the transaction, today by default. */
    package var day: Date
    /** Whether the date picker is open under Tanggal. */
    package var isPickingDay = false
    /** Whether the save is on its way to the API. */
    package internal(set) var isSaving = false
    /** "Transaksi Tersimpan" is up. */
    package var showsSaved = false
    /** Why the last save did not go through: CAT-04c for the connection. */
    package var failure: RecordFailure?
    /** The form has done its work and closes. */
    package internal(set) var isClosed = false
    private var amountDigits = ""
    private let profile: RecordProfile
    private let dependencies: RecordDependencies
    private let clientId: String
    private let onSaved: (ManualSaveResult) -> Void

    /** The form for `profile`; `onSaved` receives the saved transaction and its chat message. */
    package init(
        profile: RecordProfile, dependencies: RecordDependencies, onSaved: @escaping (ManualSaveResult) -> Void
    ) {
        self.profile = profile
        self.dependencies = dependencies
        self.onSaved = onSaved
        self.clientId = dependencies.makeId()
        self.day = dependencies.clock.now
        self.category = Self.defaultCategory(for: .expense, profile: profile)
    }

    /** The grid of the chosen type. */
    package var categories: [TransactionCategory] {
        type == .income ? Self.incomeCategories : Self.expenseCategories
    }

    /** The amount in whole rupiah; the view shows it with ",00" (`KiraAmount`). */
    package var amount: Int { AmountInput.value(of: amountDigits) }

    /** What the hidden number field holds: digits only. */
    package var amountText: String {
        get { amountDigits }
        set { amountDigits = AmountInput.digits(of: newValue) }
    }

    /** Whether Simpan may run: an amount above zero. */
    package var canSave: Bool { !isSaving && amount > 0 }

    /** Switches Pengeluaran and Pemasukan, and the grid with its default. */
    package func select(_ type: TransactionType) {
        guard type != self.type else { return }
        self.type = type
        category = Self.defaultCategory(for: type, profile: profile)
    }

    /** Chooses a tile. */
    package func select(_ category: TransactionCategory) {
        self.category = category
    }

    /** Simpan, and Coba Lagi after a failure. */
    package func save() async {
        guard canSave else { return }
        failure = nil
        isSaving = true
        defer { isSaving = false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let input = ManualTransactionInput(
            clientId: clientId, type: type, amount: amount, category: category,
            name: trimmedName.isEmpty ? dependencies.categoryName(category) : trimmedName,
            occurredAt: occurredAt, note: trimmedNote.isEmpty ? nil : trimmedNote)
        do {
            onSaved(try await dependencies.service.saveManual(input))
            showsSaved = true
        } catch {
            failure = RecordFailure(error)
        }
    }

    /** "Selesai" on "Transaksi Tersimpan" closes the form. */
    package func finish() {
        showsSaved = false
        isClosed = true
    }

    /** Today keeps the time of now; another day is noon in WIB, which no time zone moves. */
    var occurredAt: Date {
        let calendar = ChatTimeline.calendar
        let now = dependencies.clock.now
        if calendar.isDate(day, inSameDayAs: now) { return now }
        return calendar.startOfDay(for: day).addingTimeInterval(12 * 3_600)
    }

    /** The last category of the type when the grid has it, else the grid's first. */
    static func defaultCategory(for type: TransactionType, profile: RecordProfile) -> TransactionCategory {
        let grid = type == .income ? incomeCategories : expenseCategories
        let last = type == .income ? profile.lastIncomeCategory : profile.lastExpenseCategory
        return last.flatMap { grid.contains($0) ? $0 : nil } ?? grid[0]
    }
}
