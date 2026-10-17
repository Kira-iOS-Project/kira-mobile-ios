import Domain
import Features
import Foundation

actor PreviewWalletService: WalletService {
    private var accounts = WalletPreviewData.accounts

    func overview() async throws -> WalletOverview {
        try await pause()
        return WalletOverview(accounts: accounts)
    }

    func createWallet(type: WalletType, name: String, balance: Int) async throws -> Wallet {
        try await pause()
        let wallet = Wallet(id: UUID().uuidString, name: name, type: type, balance: balance)
        accounts.append(wallet)
        return wallet
    }

    private func pause() async throws {
        try await Task.sleep(for: .milliseconds(180))
    }
}
