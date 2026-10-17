import Domain

/** Read the signed-in person's held-money and debt accounts. */
extension KiraAPI {
    package func getWalletOverview() async throws -> WalletOverview {
        try await client.listWallets().walletOverview()
    }
}
