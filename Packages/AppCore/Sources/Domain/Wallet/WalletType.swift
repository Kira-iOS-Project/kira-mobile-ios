/** Finance account kinds; only the six UNG-02 choices can be added in the app. */
package enum WalletType: String, CaseIterable, Hashable, Sendable {
    case bank
    case ewallet = "e_wallet"
    case cash
    case creditCard = "credit_card"
    case paylater
    case onlineLoan = "pinjol"
    case vehicle
    case mortgage
    case familyLoan = "family_loan"
    case other

    package static let selectableCases: [WalletType] = [.bank, .ewallet, .cash, .creditCard, .paylater, .onlineLoan]

    /** Whether this account's amount is an outstanding liability. */
    package var isDebt: Bool {
        switch self {
        case .creditCard, .paylater, .onlineLoan, .vehicle, .mortgage, .familyLoan: true
        case .bank, .ewallet, .cash, .other: false
        }
    }
}
