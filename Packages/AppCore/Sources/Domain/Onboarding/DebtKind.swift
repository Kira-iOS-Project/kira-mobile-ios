/**
 Jenis utang (ONB-11): the backend's `DEBT_KIND` values. Paylater, online loans and credit cards
 are consumer debt; a vehicle instalment, a mortgage and a family loan are not.
 */
package enum DebtKind: String, CaseIterable, Hashable, Sendable {
    /** Paylater. */
    case paylater
    /** Pinjol. */
    case onlineLoan = "online_loan"
    /** Kartu Kredit. */
    case creditCard = "credit_card"
    /** Cicilan Kendaraan. */
    case vehicle
    /** KPR. */
    case mortgage
    /** Pinjaman Keluarga. */
    case familyLoan = "family_loan"

    /** Whether the consumer-debt indicator counts it. */
    package var isConsumer: Bool {
        switch self {
        case .paylater, .onlineLoan, .creditCard: true
        case .vehicle, .mortgage, .familyLoan: false
        }
    }
}
