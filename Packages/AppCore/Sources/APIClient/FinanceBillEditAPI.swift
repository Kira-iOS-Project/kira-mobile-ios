import Domain

/** KIR-121's owner-scoped bill detail and future-schedule update operations. */
extension KiraAPI {
    /** Loads the selected recurring bill for the edit form. */
    package func getBill(id: String) async throws -> RecurringBill {
        try await client.getBill(.init(path: .init(id: id))).bill()
    }

    /** Updates only the next bill schedule; recorded transactions are kept by the server. */
    package func updateBill(id: String, update: BillScheduleUpdate) async throws -> RecurringBill {
        let body = try billUpdateInput(update)
        return try await client.updateBill(
            .init(path: .init(id: id), body: .json(body))
        ).bill()
    }

    /** Cancels future occurrences without removing saved payments or transactions. */
    package func deleteBill(id: String) async throws {
        try await client.deleteBill(.init(path: .init(id: id))).deleted()
    }
}

extension Operations.DeleteBill.Output {
    func deleted() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}
