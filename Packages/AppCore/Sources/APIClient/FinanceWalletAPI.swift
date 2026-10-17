import Domain

/** Read the signed-in person's held-money and debt accounts. */
extension KiraAPI {
    package func getWalletOverview() async throws -> WalletOverview {
        try await client.listWallets().walletOverview()
    }

    /** Creates a held-money or debt account through the shared wallet endpoint. */
    package func createWallet(type: WalletType, name: String, balance: Int) async throws -> Wallet {
        let body = try createWalletInput(type: type, name: name, balance: balance)
        return try await client.createWallet(body: .json(body)).wallet()
    }
}
