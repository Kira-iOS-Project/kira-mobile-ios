/**
 The record routes Riwayat owns (CAT-07 to CAT-12): Riwayat Transaksi, Detail Transaksi, Riwayat
 Percakapan and Impor Mutasi, on the history service of `RecordComposition`. Kira Peduli, which
 every one of them links to, is `AppRoute.unavailable(.care)` until that area is built.
 */
import Features
import SwiftUI

struct RecordRoute: View {
    let route: AppRoute
    let onOpen: (AppRoute) -> Void
    @Environment(\.recordComposition) private var composition
    @Environment(\.dismiss) private var dismiss

    /** Whether `route` is one of Riwayat's. */
    static func handles(_ route: AppRoute) -> Bool {
        switch route {
        case .history, .transaction, .conversation, .importStatement: true
        default: false
        }
    }

    var body: some View {
        if let history = (composition ?? .fallback)?.history {
            switch route {
            case .transaction(let id):
                TransactionDetailScreen(id: id, service: history, onOpen: open)
            case .conversation(let messageId):
                ConversationScreen(sourceMessageId: messageId, service: history)
            case .importStatement:
                StatementImportScreen(service: history, onOpen: open) { dismiss() }
            default:
                HistoryScreen(service: history, onOpen: open)
            }
        } else {
            RouteSlot(route: route, onOpen: onOpen)
        }
    }

    private func open(_ destination: HistoryDestination) {
        switch destination {
        case .help: onOpen(.unavailable(.care))
        }
    }
}
