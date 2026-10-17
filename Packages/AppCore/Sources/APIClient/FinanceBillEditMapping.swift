import Domain

extension Operations.GetBill.Output {
    func bill() throws -> RecurringBill {
        switch self {
        case .ok(let response): try recurringBill(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

extension Operations.UpdateBill.Output {
    func bill() throws -> RecurringBill {
        switch self {
        case .ok(let response): try recurringBill(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

func billUpdateInput(_ update: BillScheduleUpdate) throws -> Components.Schemas.UpdateBillInput {
    guard update.category.type == .expense,
        let category = Components.Schemas.UpdateBillInput.CategoryPayload(rawValue: update.category.rawValue),
        let interval = Components.Schemas.UpdateBillInput.RepeatIntervalPayload(
            rawValue: update.repeatInterval.rawValue)
    else { throw AppProblem() }
    return .init(
        name: update.name, amount: update.amount, category: category,
        nextDueDate: update.nextDueDate.iso, repeatInterval: interval)
}
