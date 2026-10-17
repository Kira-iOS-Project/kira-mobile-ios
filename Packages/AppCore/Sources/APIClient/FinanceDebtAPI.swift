import Domain

/** UNG-03 Detail Utang: one of the signed-in person's debt accounts in full. */
extension KiraAPI {
    /** `GET /debts/{id}` (`getDebt`); 404 `PAYOFF_DEBT_NOT_FOUND` for a debt gone or someone else's. */
    package func getDebt(id: String) async throws -> DebtDetail {
        try await client.getDebt(path: .init(id: id)).debtDetail()
    }
}

extension Operations.GetDebt.Output {
    func debtDetail() throws -> DebtDetail {
        switch self {
        case .ok(let response): return try DebtDetail(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension DebtDetail {
    /** The debt as the API sent it; a kind or a day this app cannot read is a problem without a code. */
    init(_ body: Components.Schemas.DebtDetail) throws {
        guard let kind = DebtKind(rawValue: body.kind.rawValue) else { throw AppProblem() }
        self.init(
            id: body.id, name: body.name, kind: kind, remaining: body.remaining, totalAmount: body.totalAmount,
            paidAmount: body.paidAmount, instalmentsPaid: body.instalmentsPaid, instalmentsTotal: body.instalmentsTotal,
            monthlyInstalment: body.monthlyInstalment, dueDate: try body.dueDate.map(Self.day),
            payments: try body.payments.map {
                DebtInstalment(
                    id: $0.id, number: $0.number, amount: $0.amount, paidOn: try Self.day($0.paidOn), onTime: $0.onTime)
            },
            nextStep: try body.nextStep.map {
                DebtNextStep(
                    priority: $0.priority, priorityOf: $0.priorityOf, extraAmount: $0.extraAmount,
                    payOn: try $0.payOn.map(Self.day), monthsEarlier: $0.monthsEarlier, scoreBefore: $0.scoreBefore,
                    scoreAfter: $0.scoreAfter)
            })
    }

    private static func day(_ text: String) throws -> CalendarDay {
        guard let day = CalendarDay(iso: text) else { throw AppProblem() }
        return day
    }
}
