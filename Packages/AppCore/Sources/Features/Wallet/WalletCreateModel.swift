import APIClient
import Domain
import Foundation
import Observation

/** Tambah Dompet (UNG-02): validates and saves the balance the person enters. */
@MainActor
@Observable
package final class WalletCreateModel {
    package private(set) var phase: ScreenPhase<Wallet> = .empty
    package var name = ""
    package var amountText = ""
    package var type: WalletType = .bank
    package private(set) var showsFieldErrors = false

    private let service: any WalletService

    package init(service: any WalletService) {
        self.service = service
    }

    /** A save can start when the name and a whole-rupiah amount are present. */
    package var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && AmountInput.value(of: amountText) != nil
            && !isSaving
    }

    /** Whether the request is in flight. */
    package var isSaving: Bool {
        if case .loading = phase { return true }
        return false
    }

    /** Persists the new account; a failed request leaves the draft intact for retry. */
    package func save() async {
        showsFieldErrors = true
        guard canSave, let balance = AmountInput.value(of: amountText) else { return }
        phase = .loading
        do {
            let saved = try await service.createWallet(
                type: type, name: name.trimmingCharacters(in: .whitespacesAndNewlines), balance: balance)
            phase = .loaded(saved)
        } catch {
            phase = .failed(walletProblem(error))
        }
    }

    /** Starts a fresh sheet after the previous create flow was dismissed. */
    package func resetDraft() {
        phase = .empty
        name = ""
        amountText = ""
        type = .bank
        showsFieldErrors = false
    }
}
