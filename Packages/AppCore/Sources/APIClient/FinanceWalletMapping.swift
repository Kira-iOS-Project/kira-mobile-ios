import Domain

extension Operations.ListWallets.Output {
    func wallets() throws -> [Wallet] {
        switch self {
        case .ok(let response):
            try response.body.json.items.map {
                Wallet(id: $0.id, name: $0.name, type: try walletType($0._type.rawValue), balance: $0.balance)
            }
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

extension Operations.ListDebts.Output {
    func debts() throws -> [Wallet] {
        switch self {
        case .ok(let response): try response.body.json.items.map(mapDebtWallet)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

func walletType(_ rawValue: String) throws -> WalletType {
    switch rawValue {
    case "cash": .cash
    case "bank": .bank
    case "ewallet", "e_wallet": .ewallet
    case "credit_card": .creditCard
    case "paylater": .paylater
    case "online_loan", "pinjol": .onlineLoan
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
