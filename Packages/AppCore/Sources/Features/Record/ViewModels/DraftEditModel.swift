import Domain
import Foundation
import Observation

/**
 Ubah Transaksi (CAT-02): one draft of a card, edited in a sheet over the chat. Simpan sends the
 whole list with this draft changed and shows "Perubahan Tersimpan" (CAT-02c); Hapus dari Draf
 asks first (CAT-02b) and removes only this draft, nothing is saved to the records yet.
 */
@MainActor
@Observable
package final class DraftEditModel: Identifiable {
    /** The categories the sheet offers for an expense and for income, in the board's order. */
    static let expenseChoices: [TransactionCategory] = [.transport, .food, .shopping, .otherExpense]
    static let incomeChoices: [TransactionCategory] = [.salary, .bonus, .business, .otherIncome]

    /** The draft's id. */
    package let id: String
    /** The time of the person's message, for "Draf · dari pesan 12.41 WIB". */
    package let sourceTime: Date
    /** When the draft happened: "Kamis, 15 Oktober 2026 · 12.41 WIB". */
    package let occurredAt: Date
    /** The draft's name as the person edits it. */
    package var name: String
    /** The chosen category. */
    package internal(set) var category: TransactionCategory
    /** The category chips, the draft's own first. */
    package let categories: [TransactionCategory]
    /** Whether a change is on its way to the API. */
    package internal(set) var isSaving = false
    /** "Perubahan Tersimpan" is up. */
    package var showsSaved = false
    /** "Hapus dari Draf?" is up. */
    package var confirmsDelete = false
    /** The sheet has done its work and closes. */
    package internal(set) var isClosed = false
    /** Why the last save or delete did not go through. */
    package var failure: RecordFailure?
    private var amountDigits: String
    private let message: ChatMessage
    private let item: DraftItem
    private let service: any RecordService
    private let onUpdated: (ChatMessage) -> Void

    /** The sheet for `item` of `message`; `onUpdated` receives the message the API returns. */
    package init(
        item: DraftItem, in message: ChatMessage, sourceTime: Date, service: any RecordService,
        onUpdated: @escaping (ChatMessage) -> Void
    ) {
        self.id = item.id
        self.item = item
        self.message = message
        self.sourceTime = sourceTime
        self.occurredAt = item.occurredAt
        self.name = item.name
        self.category = item.category
        self.amountDigits = AmountInput.digits(of: String(item.amount))
        let choices = item.type == .income ? Self.incomeChoices : Self.expenseChoices
        self.categories = [item.category] + choices.filter { $0 != item.category }
        self.service = service
        self.onUpdated = onUpdated
    }

    /** The amount as the field shows it, "18.000"; only digits stay when the person types. */
    package var amountText: String {
        get { AmountInput.grouped(amountDigits) }
        set { amountDigits = AmountInput.digits(of: newValue) }
    }

    /** Whether Simpan may run: a name and an amount above zero. */
    package var canSave: Bool {
        !isSaving && AmountInput.amount(amountDigits) != nil
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /** Chooses a category chip. */
    package func select(_ category: TransactionCategory) {
        self.category = category
    }

    /** Sends the list with this draft changed, then shows "Perubahan Tersimpan". */
    package func save() async {
        guard canSave, let amount = AmountInput.amount(amountDigits) else { return }
        var changed = item
        changed.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        changed.amount = amount
        changed.category = category
        let drafts = (message.drafts ?? []).map { $0.id == item.id ? changed : $0 }
        if await update(drafts) { showsSaved = true }
    }

    /** "Selesai" on "Perubahan Tersimpan". */
    package func finish() {
        showsSaved = false
        isClosed = true
    }

    /** "Hapus dari Draf": asks first. */
    package func requestDelete() {
        confirmsDelete = true
    }

    /** "Hapus" on the confirmation: the list without this draft; an empty list discards the card. */
    package func delete() async {
        confirmsDelete = false
        if await update((message.drafts ?? []).filter { $0.id != item.id }) { isClosed = true }
    }

    private func update(_ drafts: [DraftItem]) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            onUpdated(try await service.updateDrafts(messageId: message.id, drafts: drafts))
            return true
        } catch {
            failure = RecordFailure(error)
            return false
        }
    }
}
