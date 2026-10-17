import Domain

extension Operations.ListWallets.Output {
    func walletOverview() throws -> WalletOverview {
        switch self {
        case .ok(let response):
            let result = try response.body.json
            let wallets = try result.items.map {
                Wallet(id: $0.id, name: $0.name, type: try walletType($0._type.rawValue), balance: $0.balance)
            }
            let debts = try result.debts.map(mapDebtWallet)
            return WalletOverview(accounts: wallets + debts)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

extension Operations.CreateWallet.Output {
    func wallet() throws -> Wallet {
        switch self {
        case .created(let response):
            let result = try response.body.json
            if let row = result.value1 {
                return Wallet(
                    id: row.id, name: row.name, type: try walletType(row._type.rawValue), balance: row.balance)
            }
            if let row = result.value2 { return try mapDebtWallet(row) }
            throw AppProblem()
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

func createWalletInput(type: WalletType, name: String, balance: Int) throws -> Components.Schemas.CreateWalletInput {
    let wallet = Components.Schemas.CreateWalletInput.Value1Payload.self
    let debt = Components.Schemas.CreateWalletInput.Value2Payload.self
    switch type {
    case .cash:
        return Components.Schemas.CreateWalletInput(value1: wallet.init(name: name, _type: .cash, balance: balance))
    case .bank:
        return Components.Schemas.CreateWalletInput(value1: wallet.init(name: name, _type: .bank, balance: balance))
    case .ewallet:
        return Components.Schemas.CreateWalletInput(
            value1: wallet.init(name: name, _type: .eWallet, balance: balance))
    case .other:
        return Components.Schemas.CreateWalletInput(value1: wallet.init(name: name, _type: .other, balance: balance))
    case .creditCard:
        return Components.Schemas.CreateWalletInput(
            value2: debt.init(name: name, _type: .creditCard, remainingDebt: balance))
    case .paylater:
        return Components.Schemas.CreateWalletInput(
            value2: debt.init(name: name, _type: .paylater, remainingDebt: balance))
    case .onlineLoan:
        guard let kind = Components.Schemas.CreateWalletInput.Value2Payload._TypePayload(rawValue: type.rawValue)
        else { throw AppProblem() }
        return Components.Schemas.CreateWalletInput(value2: debt.init(name: name, _type: kind, remainingDebt: balance))
    case .vehicle, .mortgage, .familyLoan: throw AppProblem()
    }
}

func walletType(_ rawValue: String) throws -> WalletType {
    switch rawValue {
    case "cash": .cash
    case "bank": .bank
    case "ewallet", "e_wallet": .ewallet
    case "credit_card": .creditCard
    case "paylater": .paylater
    case "online_loan", WalletType.onlineLoan.rawValue: .onlineLoan
    case "vehicle": .vehicle
    case "mortgage": .mortgage
    case "family_loan": .familyLoan
    case "other": .other
    default: throw AppProblem()
    }
}

func mapDebtWallet(_ row: Components.Schemas.DebtSummary) throws -> Wallet {
    Wallet(
        id: row.id, name: row.name, type: try walletType(row.kind.rawValue), balance: row.remainingAmount,
        nextDueAt: row.nextInstallment.flatMap { CalendarDay(iso: $0.dueDate)?.start }, dueSoon: row.dueSoon)
}
