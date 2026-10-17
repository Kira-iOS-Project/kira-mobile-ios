import APIClient
import Domain
import Foundation
import Observation

/** Dompet (UNG-01): one list of held money and debt, with due-soon and masked-balance behavior. */
@MainActor
@Observable
package final class WalletsModel {
    package private(set) var phase: ScreenPhase<WalletOverview> = .loading
    package private(set) var hidesBalances = false
    package private(set) var highlightedWalletID: String?

    private let service: any WalletService
    private let now: @Sendable () -> Date
    private let calendar: Calendar

    package init(
        service: any WalletService, now: @escaping @Sendable () -> Date = { Date() }, calendar: Calendar? = nil
    ) {
        self.service = service
        self.now = now
        self.calendar = calendar ?? Self.jakartaCalendar
    }

    /** Loads the user's wallets and liabilities together. */
    package func load() async {
        do {
            let overview = try await service.overview()
            phase = overview.accounts.isEmpty ? .empty : .loaded(overview)
        } catch {
            if phase.value == nil { phase = .failed(walletProblem(error)) }
        }
    }

    /** Masks every balance together, including liabilities. */
    package func toggleBalances() {
        hidesBalances.toggle()
    }

    /** Adds a successfully saved account to the visible list and highlights its row. */
    package func walletAdded(_ wallet: Wallet) {
        highlightedWalletID = wallet.id
        guard let current = phase.value else {
            phase = .loaded(WalletOverview(accounts: [wallet]))
            return
        }
        let accounts = current.accounts.filter { $0.id != wallet.id } + [wallet]
        phase = .loaded(WalletOverview(accounts: accounts))
    }

    /** Applies the server's debt balance after a payment is recorded. */
    package func debtUpdated(_ detail: DebtDetail) {
        guard let current = phase.value else { return }
        let accounts = current.accounts.map { $0.id == detail.account.id ? detail.account : $0 }
        phase = .loaded(WalletOverview(accounts: accounts))
    }

    /** Whether this account's next due date is today through `days` days away in the chosen calendar. */
    package func isDueSoon(_ wallet: Wallet, within days: Int = 10) -> Bool {
        guard wallet.type.isDebt, days >= 0 else { return false }
        if wallet.dueSoon { return true }
        guard let due = wallet.nextDueAt else { return false }
        let today = calendar.startOfDay(for: now())
        let dueDay = calendar.startOfDay(for: due)
        guard let difference = calendar.dateComponents([.day], from: today, to: dueDay).day else { return false }
        return (0...days).contains(difference)
    }

    private static var jakartaCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(identifier: "Asia/Jakarta") {
            calendar.timeZone = timeZone
        }
        return calendar
    }
}

/** The API's problem, or its generic code when the thrown error is not an AppProblem. */
func walletProblem(_ error: any Error) -> AppProblem {
    (error as? AppProblem) ?? AppProblem()
}
