/** Pilih Fokus (ONB-09): what a person wants to fix first, which sets their first Beranda. */
package enum Focus: String, CaseIterable, Hashable, Sendable {
    /** "Tahu Uangku Lari ke Mana": recording spending, the default. */
    case trackSpending = "track_spending"
    /** "Keluar dari Utang": the debt plan. */
    case debtFree = "debt_free"
}
