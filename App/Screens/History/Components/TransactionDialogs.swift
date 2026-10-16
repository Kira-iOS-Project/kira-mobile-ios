/**
 The dialogs of Detail Transaksi, word for word from the boards: Hapus Transaksi Ini? (CAT-08b),
 Transaksi Dihapus (08c), Perubahan Tersimpan (08d) and Belum Berhasil Menyimpan (08e) after a
 failed delete; the failed edit's dialog is the sheet's (`kiraSheet(_:…)`). Each button closes its
 dialog after its action; the model decides what closing means.
 */
import APIClient
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
        case .failed(let problem):
            KiraDialog(
                "transaction.failed.title", message: failedMessage(problem), art: .illustration(.umbrella),
                primary: KiraButton("transaction.failed.retry") { Task { await model.confirmDelete() } },
                secondary: KiraButton("transaction.failed.close", variant: .secondary) {})
        }
    }

    /** "Perubahan Tersimpan", over the edit sheet. */
    static var saved: KiraDialog {
        KiraDialog(
            "transaction.saved.title", message: "transaction.saved.body", art: .illustration(.bloom),
            primary: KiraButton("transaction.saved.done") {})
    }

    /** The failed delete's sentence: the board's for a lost connection, else the API's problem. */
    private static func failedMessage(_ problem: AppProblem) -> LocalizedStringResource {
        if problem.isConnectionLoss { return "transaction.failed.body" }
        if problem.showsReference { return "sheet.failure.reference \(problem.reference)" }
        return problem.message
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
