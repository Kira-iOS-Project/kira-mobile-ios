/** Impor Mutasi (tag Catat; CAT-11, CAT-12), a Kira Plus feature. */
extension KiraAPI {
    /** Keeps the parsed rows for review; at most three months per file. */
    package func createBankImport(
        fileName: String, fileSize: Int, rows: [BankImportUploadRowDTO]
    ) async throws -> BankImportDTO {
        let body = Components.Schemas.BankImportInput(
            fileName: fileName, fileSize: fileSize, rows: try rows.map { try $0.row() })
        return try await client.createBankImport(body: .json(body)).bankImport()
    }

    /** Saves the chosen rows once; a second commit answers the first one's counts. */
    package func commitBankImport(id: String, rows: [BankImportChoiceDTO]) async throws -> BankImportResultDTO {
        let body = Components.Schemas.BankImportCommit(
            rows: try rows.map { .init(id: $0.id, category: try bridged($0.category)) })
        return try await client.commitBankImport(path: .init(id: id), body: .json(body)).result()
    }
}

extension Operations.CreateBankImport.Output {
    func bankImport() throws -> BankImportDTO {
        switch self {
        case .created(let response): return try BankImportDTO(response.body.json)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .forbidden(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.CommitBankImport.Output {
    func result() throws -> BankImportResultDTO {
        switch self {
        case .ok(let response):
            let result = try response.body.json
            return BankImportResultDTO(savedCount: result.savedCount, skippedCount: result.skippedCount)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
