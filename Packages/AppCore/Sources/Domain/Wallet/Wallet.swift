/** A wallet or debt account returned for the signed-in person. */
import Foundation

package struct Wallet: Identifiable, Hashable, Sendable {
    /** The server id of this wallet or debt account. */
    package let id: String
    /** The person's name for the account. */
    package var name: String
    /** The kind of held-money or debt account. */
    package var type: WalletType
    /** The held balance or remaining debt in whole rupiah. */
    package var balance: Int
    /** The next installment date, when this debt has a schedule. */
    package var nextDueAt: Date?
    /** Whether the server marks the next installment due within ten days. */
    package var dueSoon: Bool

    /** Creates an account row from a server result or local preview. */
    package init(
        id: String, name: String, type: WalletType, balance: Int, nextDueAt: Date? = nil, dueSoon: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.nextDueAt = nextDueAt
        self.dueSoon = dueSoon
    }
}
