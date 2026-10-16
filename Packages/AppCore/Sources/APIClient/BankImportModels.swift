/**
 Impor Mutasi (CAT-11, CAT-12), a Kira Plus feature: the rows the device parsed from a bank CSV,
 the rows kept for review with their duplicate flag, the choices sent back, and the result.
 Dates are `YYYY-MM-DD`; amounts are whole rupiah.
 */
import Domain

/** One row parsed from the CSV, sent for review. */
package struct BankImportUploadRowDTO: Hashable, Sendable {
    /** `YYYY-MM-DD`. */
    package let date: String
    /** The bank's description. */
    package let description: String
    /** Signed: negative is money out. */
    package let amount: Int
    /** A category of the direction the sign gives. */
    package let category: TransactionCategory

    /** A row to send. */
    package init(date: String, description: String, amount: Int, category: TransactionCategory) {
        self.date = date
        self.description = description
        self.amount = amount
        self.category = category
    }

    func row() throws -> Components.Schemas.BankImportInput.RowsPayloadPayload {
        .init(date: date, description: description, amount: amount, category: try bridged(category))
    }
}

/** One row kept for review (Tinjau Hasil Impor). */
package struct BankImportRowDTO: Hashable, Sendable {
    /** The row's id, sent back to save it. */
    package let id: String
    /** `YYYY-MM-DD`. */
    package let date: String
    /** The bank's description. */
    package let description: String
    /** Always positive; `type` says which way it went. */
    package let amount: Int
    /** Which way the money went. */
    package let type: TransactionType
    /** Its category. */
    package let category: TransactionCategory
    /** Looks already recorded: same date, amount and type ("Mungkin Dobel"). */
    package let isDuplicate: Bool

    init(_ row: Components.Schemas.BankImportRow) throws {
        id = row.id
        date = row.date
        description = row.description
        amount = row.amount
        type = try bridged(row._type)
        category = try bridged(row.category)
        isDuplicate = row.isDuplicate
    }
}

/** An import kept for review. */
package struct BankImportDTO: Hashable, Sendable {
    /** The import's id, for the commit. */
    package let id: String
    /** How many rows the file held. */
    package let rowCount: Int
    /** The first date in the file. */
    package let dateFrom: String
    /** The last date in the file. */
    package let dateTo: String
    /** The rows, in file order. */
    package let rows: [BankImportRowDTO]

    init(_ bankImport: Components.Schemas.BankImport) throws {
        id = bankImport.id
        rowCount = bankImport.rowCount
        dateFrom = bankImport.dateFrom
        dateTo = bankImport.dateTo
        rows = try bankImport.rows.map(BankImportRowDTO.init)
    }
}

/** A reviewed row to save, with the category chosen in review. */
package struct BankImportChoiceDTO: Hashable, Sendable {
    /** The row's id. */
    package let id: String
    /** The category to save it under. */
    package let category: TransactionCategory

    /** A choice to send. */
    package init(id: String, category: TransactionCategory) {
        self.id = id
        self.category = category
    }
}

/** How many rows were saved and skipped. */
package struct BankImportResultDTO: Hashable, Sendable {
    /** Rows saved as transactions. */
    package let savedCount: Int
    /** Rows left out. */
    package let skippedCount: Int
}
