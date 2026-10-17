import Domain
import Foundation

/** KIR-41's idempotent recurring-bill creation operation. */
extension KiraAPI {
    package func createBill(_ request: BillCreateRequest) async throws -> RecurringBill {
        try await client.createBill(body: .json(createBillInput(request))).bill()
    }
}

func createBillInput(_ request: BillCreateRequest) throws -> Components.Schemas.CreateBillInput {
    guard let category = Components.Schemas.CreateBillInput.CategoryPayload(rawValue: request.category.rawValue)
    else { throw AppProblem() }
    let repeatInterval: Components.Schemas.CreateBillInput.RepeatIntervalPayload
    switch request.repeatInterval {
    case .weekly: repeatInterval = .weekly
    case .monthly: repeatInterval = .monthly
    case .yearly: repeatInterval = .yearly
    }
    return Components.Schemas.CreateBillInput(
        name: request.name, amount: request.amount, category: category, nextDueDate: request.nextDueDate.iso,
        repeatInterval: repeatInterval,
        linkedDebtAccountId: request.linkedDebtAccountID, clientId: request.clientID.uuidString.lowercased())
}

extension Operations.CreateBill.Output {
    func bill() throws -> RecurringBill {
        switch self {
        case .created(let response): try recurringBill(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}
