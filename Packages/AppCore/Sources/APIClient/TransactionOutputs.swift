/** How each transaction operation's generated output becomes a value or an `AppProblem`. */
extension Operations.CreateTransaction.Output {
    func saved() throws -> ManualTransactionSavedDTO {
        switch self {
        case .created(let response): return try ManualTransactionSavedDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.ListTransactions.Output {
    func page() throws -> TransactionPageDTO {
        switch self {
        case .ok(let response): return try TransactionPageDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.SummarizeTransactions.Output {
    func summary() throws -> TransactionSummaryDTO {
        switch self {
        case .ok(let response): return TransactionSummaryDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.GetTransaction.Output {
    func detail() throws -> TransactionDetailDTO {
        switch self {
        case .ok(let response): return try TransactionDetailDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.UpdateTransaction.Output {
    func transaction() throws -> TransactionDTO {
        switch self {
        case .ok(let response): return try TransactionDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.DeleteTransaction.Output {
    func deleted() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.UndoTransactionBatch.Output {
    func message() throws -> ChatMessageDTO {
        switch self {
        case .ok(let response): return try ChatMessageDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
