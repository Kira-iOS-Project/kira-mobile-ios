import APIClient
import Domain
import Features
import Foundation

actor FakeWalletService: WalletService {
    enum Failure: Hashable, Sendable { case overview, add }

    private var walletRows: [Wallet]
    private var debtRows: [Wallet]
    private var failures: Set<Failure> = []
    private var delay: Duration = .zero
    /** The drafts `addWallet` was sent. */
    private(set) var added: [WalletDraft] = []

    init(wallets: [Wallet] = [], debts: [Wallet] = []) {
        walletRows = wallets
        debtRows = debts
    }

    func configure(failures: Set<Failure> = [], delay: Duration = .zero) {
        self.failures = failures
        self.delay = delay
    }

    func overview() async throws -> WalletOverview {
        try await waitAndFail(.overview)
        return WalletOverview(accounts: walletRows + debtRows)
    }

    func addWallet(_ draft: WalletDraft) async throws {
        added.append(draft)
        try await waitAndFail(.add)
    }

    private func waitAndFail(_ operation: Failure) async throws {
        if delay != .zero { try await Task.sleep(for: delay) }
        if failures.contains(operation) { throw AppProblem(code: "ROUTE_NOT_FOUND") }
    }
}
