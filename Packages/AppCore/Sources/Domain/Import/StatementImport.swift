/**
 What travels to and from the API for an import (`POST /imports`, `POST /imports/{id}/commit`), and
 the sample file Impor Mutasi offers ("Unduh Contoh CSV"). Only the parsed rows are sent, with
 masked descriptions and a suggested category each; the file itself stays on the device.
 */

/** One parsed row as it is sent: the amount keeps its sign (negative = money out). */
package struct ImportUploadRow: Hashable, Sendable {
    /** The row's day. */
    package let day: CalendarDay
    /** The bank's description, account numbers masked. */
    package let description: String
    /** Whole rupiah; negative for money out. */
    package let amount: Int
    /** The suggested category. */
    package let category: TransactionCategory
}

/** The parsed file as it is sent. */
package struct ImportUpload: Hashable, Sendable {
    /** The file's name. */
    package let fileName: String
    /** The file's size in bytes. */
    package let fileSize: Int
    /** The rows with their suggested categories. */
    package let rows: [ImportUploadRow]

    /** The statement's rows with a suggested category each. */
    package init(statement: BankStatement, fileName: String, fileSize: Int) {
        self.fileName = fileName
        self.fileSize = fileSize
        rows = statement.rows.map { row in
            ImportUploadRow(
                day: row.day, description: row.description, amount: row.amount,
                category: CategorySuggestion.category(for: row.description, type: row.type))
        }
    }
}

/** A stored row the server checked for duplicates; the amount is absolute, `type` gives the way. */
package struct ImportPreviewRow: Identifiable, Hashable, Sendable {
    /** The stored row's id. */
    package let id: String
    /** The row's day. */
    package let day: CalendarDay
    /** The bank's description, account numbers masked. */
    package let description: String
    /** Whole rupiah, never negative. */
    package let amount: Int
    /** Money out or money in. */
    package let type: TransactionType
    /** The suggested category. */
    package let category: TransactionCategory
    /** Same WIB day, amount and type as a transaction already saved. */
    package let isDuplicate: Bool

    /** A stored row with the given fields. */
    package init(
        id: String, day: CalendarDay, description: String, amount: Int, type: TransactionType,
        category: TransactionCategory, isDuplicate: Bool
    ) {
        self.id = id
        self.day = day
        self.description = description
        self.amount = amount
        self.type = type
        self.category = category
        self.isDuplicate = isDuplicate
    }
}

/** The import the server stored, waiting for the person to choose what to save. */
package struct ImportPreview: Identifiable, Hashable, Sendable {
    /** The stored import's id. */
    package let id: String
    /** The first day of the rows. */
    package let dateFrom: CalendarDay
    /** The last day of the rows. */
    package let dateTo: CalendarDay
    /** The stored rows, in the file's order. */
    package let rows: [ImportPreviewRow]

    /** A stored import. */
    package init(id: String, dateFrom: CalendarDay, dateTo: CalendarDay, rows: [ImportPreviewRow]) {
        self.id = id
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.rows = rows
    }
}

/** A row to save, with the category the person settled on. */
package struct ImportCommitRow: Hashable, Sendable {
    /** The stored row's id. */
    package let id: String
    /** The category to save it under. */
    package let category: TransactionCategory

    /** A row to save under `category`. */
    package init(id: String, category: TransactionCategory) {
        self.id = id
        self.category = category
    }
}

/** How many rows were saved and how many were left out. */
package struct ImportCommitResult: Hashable, Sendable {
    /** How many rows became transactions. */
    package let savedCount: Int
    /** How many rows were left out. */
    package let skippedCount: Int

    /** The outcome of a save. */
    package init(savedCount: Int, skippedCount: Int) {
        self.savedCount = savedCount
        self.skippedCount = skippedCount
    }
}

/** The sample file "Unduh Contoh CSV" gives: the header and the board's three example rows. */
package enum StatementTemplate {
    /** The name the shared file gets. */
    package static let fileName = "contoh-mutasi-kira.csv"
    /** The file's contents. */
    package static let text = """
        tanggal,keterangan,nominal
        2026-09-26,Kopi Susu,-22000
        2026-09-29,Makan Siang,-27000
        2026-09-30,Gaji,7500000

        """
}
