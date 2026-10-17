/** A wallet or debt account returned for the signed-in person. */
import Foundation

package struct Wallet: Identifiable, Hashable, Sendable {
    package let id: String
    package var name: String
    package var type: WalletType
    package var balance: Int
    package var nextDueAt: Date?
    package var dueSoon: Bool?

    package init(
        id: String, name: String, type: WalletType, balance: Int, nextDueAt: Date? = nil, dueSoon: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.nextDueAt = nextDueAt
        self.dueSoon = dueSoon
    }
}
