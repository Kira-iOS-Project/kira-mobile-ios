import Domain

/** Read the signed-in person's held-money and debt accounts. */
extension KiraAPI {
    package func getWallets() async throws -> [Wallet] {
        try await client.listWallets().wallets()
    }

    package func getDebts() async throws -> [Wallet] {
        try await client.listDebts().debts()
    }
}
