/**
 What Tambah Tagihan (UNG-07) and Ubah Tagihan (UNG-07c) send: the bill's name, its amount (an
 estimate when it varies), its category, how often it repeats from its first due date, and the debt
 account it pays off when it is a cicilan (`POST /bills`, `PATCH /bills/{id}`).
 */
package struct BillDraft: Hashable, Sendable {
    /** "Nama", trimmed. */
    package var name: String
    /** "Jumlah", in whole rupiah. */
    package var amount: Int
    /** "Kategori". */
    package var category: BillCategory
    /** "Ulangi". */
    package var repeats: BillRepeat
    /** "Tanggal": the first due date; monthly repeats on its day, yearly on its day and month. */
    package var dueOn: CalendarDay
    /** "Ini Cicilan Utang": the debt account it pays, nil for a plain bill. */
    package var debtId: String?

    /** A draft of these fields. */
    package init(
        name: String, amount: Int, category: BillCategory, repeats: BillRepeat, dueOn: CalendarDay,
        debtId: String? = nil
    ) {
        self.name = name
        self.amount = amount
        self.category = category
        self.repeats = repeats
        self.dueOn = dueOn
        self.debtId = debtId
    }
}

/** The form's four category tiles, with the ledger's expense ids the API takes. */
package enum BillCategory: String, CaseIterable, Hashable, Sendable {
    /** "Tagihan". */
    case bills
    /** "Hiburan". */
    case entertainment
    /** "Kesehatan". */
    case health
    /** "Lainnya". */
    case other = "other_expense"
}
