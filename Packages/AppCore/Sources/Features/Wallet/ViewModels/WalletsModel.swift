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

    /**
     Loads the user's wallets and liabilities together. A first load that fails shows the problem
     (a lost connection as such, Rule 12); a refresh that fails keeps the list already shown.
     */
    package func load() async {
        do {
            let overview = try await service.overview()
            phase = overview.accounts.isEmpty ? .empty : .loaded(overview)
        } catch {
            if phase.value == nil { phase = .failed(AppProblem(error)) }
        }
    }

    /** Masks every balance together, including liabilities. */
    package func toggleBalances() {
        hidesBalances.toggle()
    }

    /** Whether this account's next due date is today through `days` days away in the chosen calendar. */
    package func isDueSoon(_ wallet: Wallet, within days: Int = 10) -> Bool {
        guard wallet.type.isDebt, days >= 0 else { return false }
        if let dueSoon = wallet.dueSoon { return dueSoon }
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
