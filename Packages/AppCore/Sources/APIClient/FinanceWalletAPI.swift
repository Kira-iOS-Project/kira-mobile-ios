import Domain

/** Read the signed-in person's held-money and debt accounts, and add one. */
extension KiraAPI {
    /** `GET /api/wallets`: the accounts and the server's held and debt totals. */
    package func getWalletOverview() async throws -> WalletOverview {
        try await client.listWallets().walletOverview()
    }

    /** A wallet, or a debt account for a credit card, paylater or online loan (`POST /api/wallets`). */
    package func createWallet(_ draft: WalletDraft) async throws {
        try await client.createWallet(body: .json(Components.Schemas.CreateWalletInput(draft))).done()
    }
}

extension Components.Schemas.CreateWalletInput {
    /**
     The draft as the API takes it: the debt left for a debt account, a balance for money held.
     The kind is read by its wire value (WalletType's raw value); one the API has no name for is
     sent as other.
     */
    init(_ draft: WalletDraft) {
        let type = draft.type.rawValue
        if let debt = Value2Payload._TypePayload(rawValue: type) {
            self.init(value2: .init(name: draft.name, _type: debt, remainingDebt: draft.amount))
        } else {
            self.init(
                value1: .init(
                    name: draft.name, _type: Value1Payload._TypePayload(rawValue: type) ?? .other, balance: draft.amount
                ))
        }
    }
}

extension Operations.CreateWallet.Output {
    func done() throws {
        switch self {
        case .created: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
