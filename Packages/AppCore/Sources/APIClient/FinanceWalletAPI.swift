import Domain

/** Read the signed-in person's held-money and debt accounts. */
extension KiraAPI {
    /** `GET /api/wallets`: the accounts and the server's held and debt totals. */
    package func getWalletOverview() async throws -> WalletOverview {
        try await client.listWallets().walletOverview()
    }
}
