/**
 How a transaction's category shows on every screen (Catat, Riwayat, Detail Transaksi, Impor
 Mutasi): the design system's tile and the name a person reads. The boards' names win over the
 tiles' own ("Makan & Minum", not "Makan"; Bonus on the savings tile); coffee keeps its own name,
 "Kopi", so the Makan & Minum filter and the rows it shows agree.
 */
import Domain
import SwiftUI

nonisolated extension TransactionCategory {
    /** The design system's tile. */
    var tile: KiraCategory {
        switch self {
        case .food: .food
        case .coffee: .coffee
        case .transport: .transport
        case .shopping, .business: .shopping
        case .bills: .bills
        case .paylaterInstalment: .paylater
        case .savingsDeposit, .bonus: .savings
        case .insurance: .protection
        case .entertainment: .entertainment
        case .health: .health
        case .education: .education
        case .household: .home
        case .otherExpense, .otherIncome: .other
        case .salary: .salary
        }
    }

    /** The name a person reads. */
    var title: LocalizedStringResource {
        switch self {
        case .food: "ledger.category.food"
        case .coffee: "ledger.category.coffee"
        case .transport: "ledger.category.transport"
        case .shopping: "ledger.category.shopping"
        case .bills: "ledger.category.bills"
        case .paylaterInstalment: "ledger.category.paylaterInstalment"
        case .savingsDeposit: "ledger.category.savingsDeposit"
        case .insurance: "ledger.category.insurance"
        case .entertainment: "ledger.category.entertainment"
        case .health: "ledger.category.health"
        case .education: "ledger.category.education"
        case .household: "ledger.category.household"
        case .otherExpense, .otherIncome: "ledger.category.other"
        case .salary: "ledger.category.salary"
        case .bonus: "ledger.category.bonus"
        case .business: "ledger.category.business"
        }
    }
}
