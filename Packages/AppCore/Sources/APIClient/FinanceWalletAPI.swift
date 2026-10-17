import Domain

/** Read the signed-in person's held-money and debt accounts, and add one. */
extension KiraAPI {
    /** The held-money and debt accounts in one owner-scoped response (`GET /api/wallets`). */
    package func getWalletOverview() async throws -> WalletOverview {
        try await client.listWallets().walletOverview()
    }

    /** A wallet, or a debt account for a credit card, paylater or pinjol (`POST /api/wallets`). */
    package func createWallet(_ draft: WalletDraft) async throws {
        try await client.createWallet(body: .json(Components.Schemas.CreateWalletInput(draft))).created()
    }
}

extension Components.Schemas.CreateWalletInput {
    /** The draft as the API takes it: a balance for money held, the debt left for a debt account. */
    init(_ draft: WalletDraft) {
        switch draft.type {
        case .creditCard: self.init(value2: .init(name: draft.name, _type: .creditCard, remainingDebt: draft.amount))
        case .paylater: self.init(value2: .init(name: draft.name, _type: .paylater, remainingDebt: draft.amount))
        case .onlineLoan: self.init(value2: .init(name: draft.name, _type: .pinjol, remainingDebt: draft.amount))
        case .bank: self.init(value1: .init(name: draft.name, _type: .bank, balance: draft.amount))
        case .ewallet: self.init(value1: .init(name: draft.name, _type: .ewallet, balance: draft.amount))
        case .cash: self.init(value1: .init(name: draft.name, _type: .cash, balance: draft.amount))
        case .vehicle, .mortgage, .familyLoan, .other:
            self.init(value1: .init(name: draft.name, _type: .other, balance: draft.amount))
        }
    }
}

extension Operations.CreateWallet.Output {
    func created() throws {
        switch self {
        case .created: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
