/**
 What travels to and from the API for an import (`POST /imports`, `POST /imports/{id}/commit`), and
 the sample file Impor Mutasi offers ("Unduh Contoh CSV"). Only the parsed rows are sent, with
 masked descriptions and a suggested category each; the file itself stays on the device.
 */

/** One parsed row as it is sent: the amount keeps its sign (negative = money out). */
package struct ImportUploadRow: Hashable, Sendable {
    package let day: CalendarDay
    package let description: String
    package let amount: Int
    package let category: TransactionCategory
}

/** The parsed file as it is sent. */
package struct ImportUpload: Hashable, Sendable {
    package let fileName: String
    package let fileSize: Int
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
    package let id: String
    package let day: CalendarDay
    package let description: String
    package let amount: Int
    package let type: TransactionType
    package let category: TransactionCategory
    /** Same WIB day, amount and type as a transaction already saved. */
    package let isDuplicate: Bool

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
    package let id: String
    package let dateFrom: CalendarDay
    package let dateTo: CalendarDay
    package let rows: [ImportPreviewRow]

    package init(id: String, dateFrom: CalendarDay, dateTo: CalendarDay, rows: [ImportPreviewRow]) {
        self.id = id
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.rows = rows
    }
}

/** A row to save, with the category the person settled on. */
package struct ImportCommitRow: Hashable, Sendable {
    package let id: String
    package let category: TransactionCategory

    package init(id: String, category: TransactionCategory) {
        self.id = id
        self.category = category
    }
}

/** How many rows were saved and how many were left out. */
package struct ImportCommitResult: Hashable, Sendable {
    package let savedCount: Int
    package let skippedCount: Int

    package init(savedCount: Int, skippedCount: Int) {
        self.savedCount = savedCount
        self.skippedCount = skippedCount
    }
}

/** The sample file "Unduh Contoh CSV" gives: the header and the board's three example rows. */
package enum StatementTemplate {
    package static let fileName = "contoh-mutasi-kira.csv"
    package static let text = """
        tanggal,keterangan,nominal
        2026-09-26,Kopi Susu,-22000
        2026-09-29,Makan Siang,-27000
        2026-09-30,Gaji,7500000

        """
}
