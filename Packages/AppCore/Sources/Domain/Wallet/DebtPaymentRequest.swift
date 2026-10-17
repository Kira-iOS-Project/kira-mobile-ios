/** A debt payment command sent with the payoff API's idempotency key. */
import Foundation

package struct DebtPaymentRequest: Hashable, Sendable {
    package let paymentId: UUID
    package let amount: Int

    package init(paymentId: UUID = UUID(), amount: Int) {
        self.paymentId = paymentId
        self.amount = amount
    }
}
