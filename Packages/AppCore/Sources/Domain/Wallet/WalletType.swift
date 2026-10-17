/** Finance account kinds; only the six UNG-02 choices can be added in the app. */
package enum WalletType: String, CaseIterable, Hashable, Sendable {
    /** A bank deposit account. */
    case bank
    /** An e-wallet balance. */
    case ewallet = "e_wallet"
    /** Physical cash held by the person. */
    case cash
    /** A credit card liability. */
    case creditCard = "credit_card"
    /** A buy-now-pay-later liability. */
    case paylater
    /** An online loan liability. */
    case onlineLoan = "pinjol"
    /** A vehicle financing liability. */
    case vehicle
    /** A mortgage liability. */
    case mortgage
    /** A loan from a family member. */
    case familyLoan = "family_loan"
    /** A legacy account type retained for existing records. */
    case other

    /** The account kinds offered by the create-wallet form. */
    package static let selectableCases: [WalletType] = [.bank, .ewallet, .cash, .creditCard, .paylater, .onlineLoan]

    /** Whether this account's amount is an outstanding liability. */
    package var isDebt: Bool {
        switch self {
        case .creditCard, .paylater, .onlineLoan, .vehicle, .mortgage, .familyLoan: true
        case .bank, .ewallet, .cash, .other: false
        }
    }
}
