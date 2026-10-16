/** How Riwayat and Detail Transaksi name where a transaction was recorded from. */
import Domain
import SwiftUI

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
