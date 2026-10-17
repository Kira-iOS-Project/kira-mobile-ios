/** Detail Utang's words for Domain values: each debt kind's icon, and rupiah inside sentences. */
import Domain
import Foundation

extension DebtKind {
    /** The category icon of the debt's kind (DetailUtang's "paylater"). */
    var category: KiraCategory {
        switch self {
        case .paylater: .paylater
        case .onlineLoan: .onlineLoan
        case .creditCard: .card
        case .vehicle: .transport
        case .mortgage: .home
        case .familyLoan: .other
        }
    }
}

/** Figures Detail Utang writes inside sentences. */
enum DebtCopy {
    /** "Rp210.000,00". */
    static func rupiah(_ amount: Int) -> String {
        RupiahFormatStyle().format(amount.rupiah)
    }
}
