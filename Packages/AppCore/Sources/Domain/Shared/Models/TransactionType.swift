/** Which way money went: the backend's `TRANSACTION_TYPE` values. */
package enum TransactionType: String, CaseIterable, Codable, Sendable {
    /** Pengeluaran. */
    case expense
    /** Pemasukan. */
    case income
}
