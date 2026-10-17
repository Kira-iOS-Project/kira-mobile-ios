import Foundation

/** A recurrence the bill editor can save. */
package enum BillRepeatInterval: String, CaseIterable, Hashable, Sendable {
    /** Every week. */
    case weekly
    /** Every month. */
    case monthly
    /** Every year. */
    case yearly
}

/** Editable values for an ordinary recurring bill. */
package struct BillEditDraft: Hashable, Sendable {
    /** The bill schedule to update. */
    package let id: String
    /** The display name. */
    package var name: String
    /** The amount field's typed digits. */
    package var amountText: String
    /** The expense category. */
    package var category: TransactionCategory
    /** The next scheduled due date. */
    package var nextDueDate: CalendarDay
    /** The recurrence interval. */
    package var repeatInterval: BillRepeatInterval

    /** Starts with the server's current values; debt installments are opened in debt detail. */
    package init?(bill: RecurringBill) {
        guard bill.kind == .bill,
            let category = TransactionCategory(rawValue: bill.category), category.type == .expense,
            let interval = BillRepeatInterval(rawValue: bill.repeatInterval)
        else { return nil }
        id = bill.id
        name = bill.name
        amountText = AmountInput.text(for: bill.amount)
        self.category = category
        nextDueDate = bill.nextDueDate
        repeatInterval = interval
    }

    /** The complete future schedule sent by PATCH, or nil for invalid form values. */
    package var update: BillScheduleUpdate? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, let amount = AmountInput.amount(amountText), category.type == .expense else {
            return nil
        }
        return BillScheduleUpdate(
            name: trimmedName, amount: amount, category: category,
            nextDueDate: nextDueDate, repeatInterval: repeatInterval)
    }
}

/** Validated future-schedule fields accepted by the update endpoint. */
package struct BillScheduleUpdate: Hashable, Sendable {
    /** The normalized display name. */
    package let name: String
    /** The amount in whole rupiah. */
    package let amount: Int
    /** The expense category. */
    package let category: TransactionCategory
    /** The next scheduled due date. */
    package let nextDueDate: CalendarDay
    /** The recurrence interval. */
    package let repeatInterval: BillRepeatInterval

    /** A validated update assembled from the editor draft. */
    package init(
        name: String, amount: Int, category: TransactionCategory,
        nextDueDate: CalendarDay, repeatInterval: BillRepeatInterval
    ) {
        self.name = name
        self.amount = amount
        self.category = category
        self.nextDueDate = nextDueDate
        self.repeatInterval = repeatInterval
    }
}
