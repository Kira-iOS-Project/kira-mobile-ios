import APIClient
import Domain
import Features
import Foundation

struct WalletCreateInput: Hashable, Sendable {
    let type: WalletType
    let name: String
    let balance: Int
}

actor FakeWalletService: WalletService {
    enum Failure: Hashable, Sendable { case overview, create }

    private var walletRows: [Wallet]
    private var debtRows: [Wallet]
    private var failures: Set<Failure> = []
    private var delay: Duration = .zero
    private var lastCreate: WalletCreateInput?

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

    func createWallet(type: WalletType, name: String, balance: Int) async throws -> Wallet {
        try await waitAndFail(.create)
        let wallet = Wallet(id: "created-1", name: name, type: type, balance: balance)
        lastCreate = WalletCreateInput(type: type, name: name, balance: balance)
        if type.isDebt { debtRows.append(wallet) } else { walletRows.append(wallet) }
        return wallet
    }

    func createdInput() -> WalletCreateInput? { lastCreate }

    private func waitAndFail(_ operation: Failure) async throws {
        if delay != .zero { try await Task.sleep(for: delay) }
        if failures.contains(operation) { throw AppProblem(code: "ROUTE_NOT_FOUND") }
    }
}
