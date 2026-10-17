/** A wallet or debt account returned for the signed-in person. */
import Foundation

/** One row of Dompet: money held (bank, e-wallet, cash) or a debt account. */
package struct Wallet: Identifiable, Hashable, Sendable {
    /** The account's id. */
    package let id: String
    /** The name the person gave it, such as "BCA" or "Paylater A". */
    package var name: String
    /** Bank, e-wallet, cash, or one of the debt kinds. */
    package var type: WalletType
    /** Whole rupiah held, or, for a debt, still owed. */
    package var balance: Int
    /** A debt's next instalment day (start of the WIB day); nil for held money or no schedule. */
    package var nextDueAt: Date?

    /** An account and, for a debt, its next due day. */
    package init(id: String, name: String, type: WalletType, balance: Int, nextDueAt: Date? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.nextDueAt = nextDueAt
    }
}
