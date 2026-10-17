/** A due date and status returned by the debt repayment schedule. */
import Foundation

package struct DebtInstallment: Identifiable, Hashable, Sendable {
    package let id: String
    package let dueAt: Date
    package let amount: Int
    package let status: Status

    package enum Status: String, Hashable, Sendable {
        case upcoming
        case dueSoon
        case paid
        case onTime = "on_time"
        case late
    }

    package init(id: String, dueAt: Date, amount: Int, status: Status) {
        self.id = id
        self.dueAt = dueAt
        self.amount = amount
        self.status = status
    }
}
