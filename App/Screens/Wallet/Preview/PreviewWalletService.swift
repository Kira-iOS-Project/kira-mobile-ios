import Domain
import Features
import Foundation

actor PreviewWalletService: WalletService {
    private let accounts = WalletPreviewData.accounts

    func overview() async throws -> WalletOverview {
        try await pause()
        return WalletOverview(accounts: accounts)
    }

    private func pause() async throws {
        try await Task.sleep(for: .milliseconds(180))
    }
}
