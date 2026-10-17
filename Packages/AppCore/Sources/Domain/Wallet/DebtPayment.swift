/** A recorded payment and whether it arrived on time. */
import Foundation

package struct DebtPayment: Identifiable, Hashable, Sendable {
    package let id: String
    package let paidAt: Date
    package let amount: Int
    package let timing: Timing

    package enum Timing: String, Hashable, Sendable {
        case onTime = "on_time"
        case late
    }

    package init(id: String, paidAt: Date, amount: Int, timing: Timing) {
        self.id = id
        self.paidAt = paidAt
        self.amount = amount
        self.timing = timing
    }
}
