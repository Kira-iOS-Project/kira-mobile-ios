/** Finance account kinds; only the six UNG-02 choices can be added in the app. */
package enum WalletType: String, CaseIterable, Hashable, Sendable {
    /** A bank account. */
    case bank
    /** An e-wallet. */
    case ewallet = "e_wallet"
    /** Cash on hand. */
    case cash
    /** A credit card's balance owed. */
    case creditCard = "credit_card"
    /** A paylater account. */
    case paylater
    /** An online loan (pinjol). */
    case onlineLoan = "pinjol"
    /** A vehicle instalment. */
    case vehicle
    /** A mortgage (KPR). */
    case mortgage
    /** Money owed to family. */
    case familyLoan = "family_loan"
    /** Any other account. */
    case other

    /** The six kinds Tambah Dompet (UNG-02) offers, in its order. */
    package static let selectableCases: [WalletType] = [.bank, .ewallet, .cash, .creditCard, .paylater, .onlineLoan]

    /** Whether this account's amount is an outstanding liability. */
    package var isDebt: Bool {
        switch self {
        case .creditCard, .paylater, .onlineLoan, .vehicle, .mortgage, .familyLoan: true
        case .bank, .ewallet, .cash, .other: false
        }
    }
}
