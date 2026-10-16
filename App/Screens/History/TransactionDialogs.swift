/**
 The dialogs of Detail Transaksi, word for word from the boards: Hapus Transaksi Ini? (CAT-08b),
 Transaksi Dihapus (08c), Perubahan Tersimpan (08d) and Belum Berhasil Menyimpan (08e). Each
 button closes its dialog after its action; the model decides what closing means.
 */
import Domain
import Features
import SwiftUI

enum TransactionDialogs {
    /** The dialog over the screen: the delete's confirmation and outcome. */
    static func screen(_ model: TransactionDetailModel) -> KiraDialog {
        switch model.shownDialog {
        case .confirmDelete:
            KiraDialog(
                "transaction.delete.title", message: deleteMessage(model.phase.value?.transaction),
                art: .illustration(.care),
                primary: KiraButton("transaction.delete.confirm", variant: .destructive) {
                    Task { await model.confirmDelete() }
                },
                secondary: KiraButton("transaction.delete.cancel", variant: .secondary) {})
        case .deleted:
            KiraDialog(
                "transaction.deleted.title", message: deletedMessage(model.phase.value?.transaction),
                art: .illustration(.bloom), primary: KiraButton("transaction.deleted.back") {})
        case .failed:
            failure { Task { await model.confirmDelete() } }
        }
    }

    /** The dialog over the edit sheet: the save's outcome. */
    static func edit(_ model: TransactionDetailModel) -> KiraDialog {
        switch model.shownEditResult {
        case .saved:
            KiraDialog(
                "transaction.saved.title", message: "transaction.saved.body", art: .illustration(.bloom),
                primary: KiraButton("transaction.saved.done") {})
        case .failed:
            failure { Task { await model.save() } }
        }
    }

    /** "Belum Berhasil Menyimpan": Coba Lagi repeats the same action, Tutup keeps what was entered. */
    private static func failure(retry: @escaping () -> Void) -> KiraDialog {
        KiraDialog(
            "transaction.failed.title", message: "transaction.failed.body", art: .illustration(.umbrella),
            primary: KiraButton("transaction.failed.retry", action: retry),
            secondary: KiraButton("transaction.failed.close", variant: .secondary) {})
    }

    private static func deleteMessage(_ transaction: Domain.Transaction?) -> LocalizedStringResource {
        guard let transaction else { return "transaction.delete.bodyPlain" }
        let amount = RupiahFormatStyle().format(Decimal(transaction.amount))
        return "transaction.delete.body \(transaction.name) \(amount) \(String(localized: transaction.category.title))"
    }

    private static func deletedMessage(_ transaction: Domain.Transaction?) -> LocalizedStringResource {
        guard let transaction else { return "transaction.deleted.bodyPlain" }
        return "transaction.deleted.body \(String(localized: transaction.category.title))"
    }
}
