import APIClient
import Domain
import Features
import Foundation

struct WalletCreateInput: Hashable, Sendable {
    let type: WalletType
    let name: String
    let balance: Int
}

struct DebtPaymentInput: Hashable, Sendable {
    let debtID: String
    let request: DebtPaymentRequest
}

actor FakeWalletService: WalletService {
    enum Failure: Hashable, Sendable { case overview, create, detail, payment }

    private var walletRows: [Wallet]
    private var debtRows: [Wallet]
    private var failures: Set<Failure> = []
    private var delay: Duration = .zero
    private var lastCreate: WalletCreateInput?
    private var debtDetails: [String: DebtDetail]
    private var lastPayment: DebtPaymentInput?

    init(wallets: [Wallet] = [], debts: [Wallet] = [], details: [DebtDetail] = []) {
        walletRows = wallets
        debtRows = debts
        debtDetails = Dictionary(uniqueKeysWithValues: details.map { ($0.account.id, $0) })
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

    func debt(id: String) async throws -> DebtDetail {
        try await waitAndFail(.detail)
        guard let detail = debtDetails[id] else { throw AppProblem() }
        return detail
    }

    func payDebt(id: String, request: DebtPaymentRequest) async throws -> DebtDetail {
        lastPayment = DebtPaymentInput(debtID: id, request: request)
        try await waitAndFail(.payment)
        guard let detail = debtDetails[id] else { throw AppProblem() }
        let remaining = max(0, detail.account.balance - request.amount)
        let account = Wallet(
            id: detail.account.id, name: detail.account.name, type: detail.account.type,
            balance: remaining, nextDueAt: detail.account.nextDueAt, dueSoon: detail.account.dueSoon)
        let payment = DebtPayment(
            id: request.paymentId.uuidString, paidAt: Date(timeIntervalSince1970: 1_800_000_000),
            amount: request.amount, timing: .onTime)
        let updated = DebtDetail(
            account: account, originalAmount: detail.originalAmount,
            paidInstallments: detail.paidInstallments, totalInstallments: detail.totalInstallments,
            schedule: detail.schedule, payments: [payment] + detail.payments, scoreEstimate: detail.scoreEstimate)
        debtDetails[id] = updated
        debtRows = debtRows.map { $0.id == id ? account : $0 }
        return updated
    }

    func recordedPayment() -> DebtPaymentInput? { lastPayment }

    private func waitAndFail(_ operation: Failure) async throws {
        if delay != .zero { try await Task.sleep(for: delay) }
        if failures.contains(operation) { throw AppProblem(code: "ROUTE_NOT_FOUND") }
    }
}
