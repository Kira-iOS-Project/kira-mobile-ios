import APIClient
import Domain
import Foundation
import Observation

/**
 Tambah Dompet (UNG-02): the kind (Bank, E-Wallet, Tunai, Kartu Kredit, Paylater, Pinjol; the last
 three are debt accounts), the name, and the amount now. An empty name, or a debt account without
 the debt left, stays inline; a failed save closes the sheet into its failure dialog, and Coba Lagi
 reopens it on what was typed. A saved one closes into "Dompet Ditambahkan".
 */
@MainActor
@Observable
package final class AddWalletModel {
    /** What the person must still fill in. */
    package enum Issue: Hashable, Sendable {
        /** No name. */
        case missingName
        /** A debt account without the debt left. */
        case missingDebt
    }

    /** The sheet: open, closed, or the problem of its last submit. */
    package var sheet = SheetSubmission()
    /** The chosen kind; E-Wallet first, as the board draws it. */
    package private(set) var type = WalletType.ewallet
    /** The name typed. */
    package var name = ""
    /** The amount typed, in whole-rupiah digits. */
    package var amountText = ""
    /** What the last "Simpan Dompet" found missing. */
    package private(set) var issues: Set<Issue> = []
    /** Whether "Dompet Ditambahkan" shows. */
    package var showsAdded = false

    @ObservationIgnored private let service: any WalletService

    /** A model that saves through `service`. */
    package init(service: any WalletService) {
        self.service = service
    }

    /** "Tambah Dompet": the sheet opens empty, on E-Wallet. */
    package func open() {
        type = .ewallet
        name = ""
        amountText = ""
        issues = []
        sheet.open()
    }

    /** A tile tap; the issues it can settle go. */
    package func select(_ type: WalletType) {
        self.type = type
        if !type.isDebt { issues.remove(.missingDebt) }
    }

    /** "Simpan Dompet", and again on Coba Lagi. */
    package func save() async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = Int(amountText.filter(\.isNumber)) ?? 0
        var found: Set<Issue> = []
        if trimmed.isEmpty { found.insert(.missingName) }
        if type.isDebt, amount < 1 { found.insert(.missingDebt) }
        issues = found
        guard found.isEmpty else { return }
        do {
            try await service.addWallet(WalletDraft(type: type, name: trimmed, amount: amount))
            sheet.close()
            showsAdded = true
        } catch {
            sheet.fail(error)
        }
    }
}
