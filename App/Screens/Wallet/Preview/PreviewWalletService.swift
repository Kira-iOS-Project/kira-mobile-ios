import Domain
import Features
import Foundation

actor PreviewWalletService: WalletService {
    private let accounts = WalletPreviewData.accounts

    func wallets() async throws -> [Wallet] {
        try await pause()
        return accounts.filter { !$0.type.isDebt }
    }

    func debts() async throws -> [Wallet] {
        try await pause()
        return accounts.filter { $0.type.isDebt }
    }

    private func pause() async throws {
        try await Task.sleep(for: .milliseconds(180))
    }
}
