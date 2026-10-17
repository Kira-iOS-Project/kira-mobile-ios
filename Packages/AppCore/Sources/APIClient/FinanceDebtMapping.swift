import Domain

extension Operations.GetDebtDetail.Output {
    func debtDetail() throws -> DebtDetail {
        switch self {
        case .ok(let response): try mapDebtDetail(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

extension Operations.RecordDebtPayment.Output {
    func recorded() throws -> Components.Schemas.DebtPaymentResult {
        switch self {
        case .ok(let response): try response.body.json
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

func mapDebtDetail(_ row: Components.Schemas.DebtDetail) throws -> DebtDetail {
    guard let scoreEstimate = row.scoreEstimate, scoreEstimate.isSimulated else { throw AppProblem() }
    let account = Wallet(
        id: row.id, name: row.name, type: try walletType(row.kind.rawValue), balance: row.remainingAmount,
        nextDueAt: row.nextInstallment.flatMap { CalendarDay(iso: $0.dueDate)?.start }, dueSoon: row.dueSoon)
    let schedule = try row.installmentSchedule.enumerated().map { index, item in
        guard let date = CalendarDay(iso: item.dueDate),
            let status = DebtInstallment.Status(rawValue: item.status.rawValue)
        else { throw AppProblem() }
        return DebtInstallment(
            id: "\(row.id)-\(date.iso)-\(index)", dueAt: date.start, amount: item.amount, status: status)
    }
    let payments = row.paymentHistory.map {
        DebtPayment(id: $0.id, paidAt: $0.date, amount: $0.amount, timing: $0.onTime ? .onTime : .late)
    }
    let total = row.installmentsTotal ?? schedule.count
    let remaining = row.installmentsRemaining ?? schedule.filter { $0.status != .paid }.count
    let estimate = DebtScoreEstimate(
        current: scoreEstimate.current, afterPayoff: scoreEstimate.afterPayoff)
    return DebtDetail(
        account: account, originalAmount: row.originalAmount,
        paidInstallments: max(0, total - remaining), totalInstallments: total, schedule: schedule,
        payments: payments, scoreEstimate: estimate, nextStep: row.nextStep)
}
