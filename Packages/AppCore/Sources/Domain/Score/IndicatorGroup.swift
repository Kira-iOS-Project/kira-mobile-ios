/** The three sub-scores of the Kira Score (HasilCekAwal: Tabung, Utang, Lindungi). */
package enum IndicatorGroup: String, CaseIterable, Hashable, Sendable {
    /** Tabung: emergency fund and savings ratio. */
    case save = "save_group"
    /** Utang: instalments, consumer debt and debt to assets. */
    case debt = "debt_group"
    /** Lindungi: protection cover. */
    case protect = "protect_group"
}
