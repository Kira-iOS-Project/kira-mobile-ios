/**
 How a transaction's category and source show: the design system's tile and the name a person
 reads. The board's names win over the tiles' own ("Makan & Minum", not "Makan"); coffee keeps
 its own name, "Kopi", so the Makan & Minum filter and the rows it shows agree.
 */
import Domain
import SwiftUI

extension TransactionCategory {
    /** The design system's tile. */
    var artwork: KiraCategory {
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

extension TransactionSource {
    /** The end of a Riwayat row's subtitle: "dari chat", "manual", "struk", "impor". */
    var rowLabel: LocalizedStringResource {
        switch self {
        case .chat: "history.source.chat"
        case .manual: "history.source.manual"
        case .receipt: "history.source.receipt"
        case .bankImport: "history.source.import"
        }
    }

    /** The Sumber row's value on Detail Transaksi. */
    var detailLabel: LocalizedStringResource {
        switch self {
        case .chat: "transaction.source.chat"
        case .manual: "transaction.source.manual"
        case .receipt: "transaction.source.receipt"
        case .bankImport: "transaction.source.import"
        }
    }
}
